import Foundation
import CoreLocation

class SwissEphemerisEngine: ObservableObject {
    static let shared = SwissEphemerisEngine()
    
    private let vsop87 = VSOP87Calculator()
    private let elp2000 = ELP2000Calculator()
    private let houseCalc = HouseCalculator()
    
    @Published var isCalculating = false
    @Published var lastCalculationTime: TimeInterval = 0
    
    func calculateChart(
        date: Date,
        utcOffset: Int,
        latitude: Double,
        longitude: Double,
        mode: CalculationMode
    ) -> ChartData {
        isCalculating = true
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let jd = calculateJulianDay(date: date, utcOffset: utcOffset)
        let t = (jd - 2451545.0) / 36525.0  // Julian centuries from J2000
        
        var positions: [PlanetPosition] = []
        
        // Calculate Sun position
        let sunPos = calculateSunPosition(jd: jd, t: t, mode: mode)
        positions.append(sunPos)
        
        // Calculate Moon position (only geocentric)
        if mode == .geocentric {
            let moonPos = calculateMoonPosition(jd: jd, t: t)
            positions.append(moonPos)
        }
        
        // Calculate planets
        let planetCalculations: [(PlanetType, VSOP87Calculator.PlanetVSOP87)] = [
            (.mercury, .mercury),
            (.venus, .venus),
            (.mars, .mars),
            (.jupiter, .jupiter),
            (.saturn, .saturn),
            (.uranus, .uranus),
            (.neptune, .neptune)
        ]
        
        for (planetType, vsopPlanet) in planetCalculations {
            let pos = calculatePlanetPosition(
                type: planetType,
                vsopPlanet: vsopPlanet,
                jd: jd,
                t: t,
                sunLongitude: sunPos.longitude,
                mode: mode
            )
            positions.append(pos)
        }
        
        // Calculate Pluto (simplified)
        let plutoPos = calculatePlutoPosition(jd: jd, t: t, sunLongitude: sunPos.longitude, mode: mode)
        positions.append(plutoPos)
        
        // Calculate Nodes (only geocentric)
        if mode == .geocentric {
            let (northNode, southNode) = calculateNodes(jd: jd, t: t)
            positions.append(northNode)
            positions.append(southNode)
        }
        
        // Calculate houses (only geocentric)
        var houseSystem: HouseSystem? = nil
        if mode == .geocentric {
            houseSystem = houseCalc.calculateHouses(
                jd: jd,
                latitude: latitude,
                longitude: longitude
            )
        }
        
        // Calculate aspects
        let aspects = AspectConfiguration.findAspects(between: positions, includeMinor: false)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        lastCalculationTime = endTime - startTime
        
        isCalculating = false
        
        return ChartData(
            date: date,
            utcOffset: utcOffset,
            latitude: latitude,
            longitude: longitude,
            locationName: mode == .heliocentric ? "Heliocéntrico" : "Geocéntrico",
            calculationMode: mode,
            planetPositions: positions.sorted { $0.longitude < $1.longitude },
            houseSystem: houseSystem,
            aspects: aspects
        )
    }
    
    private func calculateJulianDay(date: Date, utcOffset: Int) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: utcOffset * 3600)!
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minute = components.minute,
              let second = components.second else {
            return 2451545.0
        }
        
        var y = Double(year)
        var m = Double(month)
        let d = Double(day)
        
        if m <= 2 {
            y -= 1
            m += 12
        }
        
        let a = floor(y / 100)
        let b = 2 - a + floor(a / 4)
        
        let dayFraction = (Double(hour) + Double(minute) / 60 + Double(second) / 3600) / 24
        
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524.5 + dayFraction
    }
    
    private func calculateSunPosition(jd: Double, t: Double, mode: CalculationMode) -> PlanetPosition {
        // VSOP87 for Sun (Earth-centric, then convert)
        let (L, B, R) = vsop87.calculateEarth(t: t)
        
        var longitude = normalizeAngle(radiansToDegrees(L) + 180) // Sun is opposite Earth
        let latitude = -radiansToDegrees(B)
        let distance = R
        
        // Apply nutation
        let nutation = calculateNutation(t: t)
        longitude += nutation
        
        // Calculate speed
        let dt = 1.0 / 36525.0 // 1 day in centuries
        let (_, _, R2) = vsop87.calculateEarth(t: t + dt)
        let speed = (R2 - R) * 36525.0 // AU per Julian year
        
        return PlanetPosition(
            type: .sun,
            longitude: longitude,
            latitude: latitude,
            distance: distance,
            speed: speed,
            isRetrograde: false
        )
    }
    
    private func calculateMoonPosition(jd: Double, t: Double) -> PlanetPosition {
        let (longitude, latitude, distance) = elp2000.calculatePosition(jd: jd)
        
        // Moon's mean motion is about 13.176 degrees per day
        let speed = 13.176358 // degrees/day
        
        return PlanetPosition(
            type: .moon,
            longitude: normalizeAngle(longitude),
            latitude: latitude,
            distance: distance,
            speed: speed,
            isRetrograde: false
        )
    }
    
    private func calculatePlanetPosition(
        type: PlanetType,
        vsopPlanet: VSOP87Calculator.PlanetVSOP87,
        jd: Double,
        t: Double,
        sunLongitude: Double,
        mode: CalculationMode
    ) -> PlanetPosition {
        let (L, B, R) = vsop87.calculatePlanet(type: vsopPlanet, t: t)
        
        var longitude = radiansToDegrees(L)
        let latitude = radiansToDegrees(B)
        let distance = R
        
        // Apply light-time correction
        let lightTime = distance * 0.0057755183 // days per AU
        let tCorrected = t - lightTime / 36525.0
        
        let (L2, _, _) = vsop87.calculatePlanet(type: vsopPlanet, t: tCorrected)
        longitude = radiansToDegrees(L2)
        
        // For geocentric, need to calculate heliocentric to geocentric conversion
        if mode == .geocentric {
            // Simplified conversion - in real implementation would use full vector math
            longitude = normalizeAngle(longitude)
        }
        
        // Calculate speed and retrograde motion
        let dt = 1.0 / 36525.0
        let (L1, _, _) = vsop87.calculatePlanet(type: vsopPlanet, t: t - dt)
        let (L3, _, _) = vsop87.calculatePlanet(type: vsopPlanet, t: t + dt)
        
        let speedYesterday = radiansToDegrees(L2 - L1) * 36525.0
        let speedTomorrow = radiansToDegrees(L3 - L2) * 36525.0
        let speed = (speedYesterday + speedTomorrow) / 2
        let isRetrograde = speed < 0
        
        return PlanetPosition(
            type: type,
            longitude: normalizeAngle(longitude),
            latitude: latitude,
            distance: distance,
            speed: speed,
            isRetrograde: isRetrograde
        )
    }
    
    private func calculatePlutoPosition(jd: Double, t: Double, sunLongitude: Double, mode: CalculationMode) -> PlanetPosition {
        // Simplified Pluto calculation using periodic terms
        // More accurate: use DE440/DE441 ephemeris
        
        let T = t
        let L = 238.96 + 144.96 * T // Mean longitude
        let e = 0.24905 // Eccentricity
        let a = 39.48 // Semi-major axis
        
        // Solve Kepler's equation
        let M = degreesToRadians(L - 224.17) // Mean anomaly
        var E = M
        for _ in 0..<10 {
            E = M + e * sin(E)
        }
        
        let trueAnomaly = 2 * atan(sqrt((1 + e) / (1 - e)) * tan(E / 2))
        let longitude = normalizeAngle(radiansToDegrees(trueAnomaly) + 224.17)
        
        let distance = a * (1 - e * cos(E))
        
        // Pluto's orbital period is ~248 years
        let speed = 360.0 / (248.0 * 365.25) * 365.25 // degrees/day * days/year
        
        return PlanetPosition(
            type: .pluto,
            longitude: longitude,
            latitude: 0, // Simplified
            distance: distance,
            speed: speed,
            isRetrograde: false
        )
    }
    
    private func calculateNodes(jd: Double, t: Double) -> (PlanetPosition, PlanetPosition) {
        // Mean lunar node
        let omega = 125.044555 - 1934.1361849 * t + 0.0020762 * t * t
        
        let northNode = PlanetPosition(
            type: .northNode,
            longitude: normalizeAngle(omega),
            latitude: 0,
            distance: 0,
            speed: -0.053,
            isRetrograde: true
        )
        
        let southNode = PlanetPosition(
            type: .southNode,
            longitude: normalizeAngle(omega + 180),
            latitude: 0,
            distance: 0,
            speed: -0.053,
            isRetrograde: true
        )
        
        return (northNode, southNode)
    }
    
    private func calculateNutation(t: Double) -> Double {
        // Simplified nutation in longitude
        let omega = 125.04452 - 1934.136261 * t
        let L = 280.4665 + 36000.7698 * t
        let Lp = 218.3165 + 481267.8813 * t
        
        let deltaPsi = -17.20 * sin(degreesToRadians(omega))
                       - 1.32 * sin(2 * degreesToRadians(L))
                       - 0.23 * sin(2 * degreesToRadians(Lp))
                       + 0.21 * sin(2 * degreesToRadians(omega))
        
        return deltaPsi / 3600.0 // Convert arcseconds to degrees
    }
    
    private func normalizeAngle(_ angle: Double) -> Double {
        var result = angle.truncatingRemainder(dividingBy: 360)
        if result < 0 {
            result += 360
        }
        return result
    }
    
    private func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }
}
