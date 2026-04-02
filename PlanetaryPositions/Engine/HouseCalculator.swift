import Foundation

class HouseCalculator {
    
    // MARK: - House Systems
    
    enum HouseSystemType: String, CaseIterable, Identifiable {
        case placidus = "Placidus"
        case koch = "Koch"
        case equal = "Equal"
        case wholeSign = "Signos Enteros"
        case campanus = "Campanus"
        case regiomontanus = "Regiomontanus"
        case porphyry = "Porphyry"
        case morinus = "Morinus"
        
        var id: String { rawValue }
    }
    
    // MARK: - House Calculation
    
    func calculateHouses(
        jd: Double,
        latitude: Double,
        longitude: Double,
        system: HouseSystemType = .placidus
    ) -> HouseSystem {
        switch system {
        case .placidus:
            return calculatePlacidusHouses(jd: jd, latitude: latitude, longitude: longitude)
        case .equal:
            return calculateEqualHouses(jd: jd, latitude: latitude, longitude: longitude)
        case .wholeSign:
            return calculateWholeSignHouses(jd: jd, latitude: latitude, longitude: longitude)
        case .koch:
            return calculateKochHouses(jd: jd, latitude: latitude, longitude: longitude)
        case .porphyry:
            return calculatePorphyryHouses(jd: jd, latitude: latitude, longitude: longitude)
        default:
            return calculatePlacidusHouses(jd: jd, latitude: latitude, longitude: longitude)
        }
    }
    
    // MARK: - Placidus House System
    
    private func calculatePlacidusHouses(
        jd: Double,
        latitude: Double,
        longitude: Double
    ) -> HouseSystem {
        let T = (jd - 2451545.0) / 36525.0
        
        // Calculate obliquity of the ecliptic
        let epsilon = calculateObliquity(t: T)
        let epsilonRad = degreesToRadians(epsilon)
        let latRad = degreesToRadians(latitude)
        
        // Calculate RAMC (Right Ascension of the Midheaven)
        let lst = calculateLocalSiderealTime(jd: jd, longitude: longitude)
        let ramc = lst * 15.0 // Convert hours to degrees
        
        // Calculate MC (Midheaven - 10th house cusp)
        let mc = calculateMC(ramc: ramc, epsilon: epsilon)
        
        // Calculate Ascendant (1st house cusp)
        let ascendant = calculateAscendant(ramc: ramc, latitude: latitude, epsilon: epsilon)
        
        // Calculate IC (4th house cusp)
        let ic = normalizeAngle(mc + 180)
        
        // Calculate Descendant (7th house cusp)
        let descendant = normalizeAngle(ascendant + 180)
        
        // Calculate intermediate house cusps using Placidus method
        var cusps: [Double] = Array(repeating: 0, count: 12)
        cusps[0] = ascendant   // House 1
        cusps[9] = mc          // House 10
        cusps[3] = ic          // House 4
        cusps[6] = descendant  // House 7
        
        // Calculate semi-arcs for Placidus houses
        let tanLat = tan(latRad)
        let tanEps = tan(epsilonRad)
        
        // Houses 11 and 12 (before MC)
        for i in 1...2 {
            let ratio = Double(i) / 3.0
            let angle = calculatePlacidusCusp(
                ramc: ramc,
                latitude: latitude,
                epsilon: epsilon,
                ratio: ratio,
                isAboveHorizon: true
            )
            cusps[9 + i] = angle
        }
        
        // Houses 2 and 3 (after Ascendant)
        for i in 1...2 {
            let ratio = Double(i) / 3.0
            let angle = calculatePlacidusCusp(
                ramc: ramc,
                latitude: latitude,
                epsilon: epsilon,
                ratio: ratio,
                isAboveHorizon: false
            )
            cusps[i] = angle
        }
        
        // Houses 5 and 6 (after IC)
        for i in 1...2 {
            cusps[3 + i] = normalizeAngle(cusps[9 + i] + 180)
        }
        
        // Houses 8 and 9 (after Descendant)
        for i in 1...2 {
            cusps[6 + i] = normalizeAngle(cusps[i] + 180)
        }
        
        // Create House objects
        var houses: [House] = []
        for i in 0..<12 {
            houses.append(House(number: i + 1, cuspLongitude: cusps[i]))
        }
        
        return HouseSystem(
            houses: houses,
            ascendant: ascendant,
            midheaven: mc,
            descendant: descendant,
            imumCoeli: ic
        )
    }
    
    private func calculatePlacidusCusp(
        ramc: Double,
        latitude: Double,
        epsilon: Double,
        ratio: Double,
        isAboveHorizon: Bool
    ) -> Double {
        let latRad = degreesToRadians(latitude)
        let epsRad = degreesToRadians(epsilon)
        
        let tanLat = tan(latRad)
        let tanEps = tan(epsRad)
        
        // Simplified Placidus calculation
        // Full implementation requires iterative solution
        var angle = ramc + (isAboveHorizon ? ratio * 90 : 90 + ratio * 90)
        
        // Convert RA to ecliptic longitude
        angle = normalizeAngle(angle)
        
        // Apply latitude correction
        let correction = atan2(tanLat * sin(degreesToRadians(angle - ramc)), cos(epsRad))
        angle = normalizeAngle(angle + radiansToDegrees(correction))
        
        return angle
    }
    
    // MARK: - Equal House System
    
    private func calculateEqualHouses(
        jd: Double,
        latitude: Double,
        longitude: Double
    ) -> HouseSystem {
        let T = (jd - 2451545.0) / 36525.0
        let epsilon = calculateObliquity(t: T)
        
        let lst = calculateLocalSiderealTime(jd: jd, longitude: longitude)
        let ramc = lst * 15.0
        
        let ascendant = calculateAscendant(ramc: ramc, latitude: latitude, epsilon: epsilon)
        let mc = calculateMC(ramc: ramc, epsilon: epsilon)
        
        var houses: [House] = []
        for i in 0..<12 {
            let cusp = normalizeAngle(ascendant + Double(i) * 30)
            houses.append(House(number: i + 1, cuspLongitude: cusp))
        }
        
        return HouseSystem(
            houses: houses,
            ascendant: ascendant,
            midheaven: mc,
            descendant: normalizeAngle(ascendant + 180),
            imumCoeli: normalizeAngle(mc + 180)
        )
    }
    
    // MARK: - Whole Sign House System
    
    private func calculateWholeSignHouses(
        jd: Double,
        latitude: Double,
        longitude: Double
    ) -> HouseSystem {
        let T = (jd - 2451545.0) / 36525.0
        let epsilon = calculateObliquity(t: T)
        
        let lst = calculateLocalSiderealTime(jd: jd, longitude: longitude)
        let ramc = lst * 15.0
        
        let ascendant = calculateAscendant(ramc: ramc, latitude: latitude, epsilon: epsilon)
        let mc = calculateMC(ramc: ramc, epsilon: epsilon)
        
        // Find the sign of the ascendant
        let ascendantSign = Int(ascendant / 30)
        
        var houses: [House] = []
        for i in 0..<12 {
            let cusp = Double((ascendantSign + i) % 12) * 30.0
            houses.append(House(number: i + 1, cuspLongitude: cusp))
        }
        
        return HouseSystem(
            houses: houses,
            ascendant: ascendant,
            midheaven: mc,
            descendant: normalizeAngle(ascendant + 180),
            imumCoeli: normalizeAngle(mc + 180)
        )
    }
    
    // MARK: - Koch House System
    
    private func calculateKochHouses(
        jd: Double,
        latitude: Double,
        longitude: Double
    ) -> HouseSystem {
        // Simplified Koch calculation
        // Full implementation requires complex interpolation
        return calculatePlacidusHouses(jd: jd, latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Porphyry House System
    
    private func calculatePorphyryHouses(
        jd: Double,
        latitude: Double,
        longitude: Double
    ) -> HouseSystem {
        let T = (jd - 2451545.0) / 36525.0
        let epsilon = calculateObliquity(t: T)
        
        let lst = calculateLocalSiderealTime(jd: jd, longitude: longitude)
        let ramc = lst * 15.0
        
        let ascendant = calculateAscendant(ramc: ramc, latitude: latitude, epsilon: epsilon)
        let mc = calculateMC(ramc: ramc, epsilon: epsilon)
        let descendant = normalizeAngle(ascendant + 180)
        let ic = normalizeAngle(mc + 180)
        
        // Divide each quadrant into three equal parts
        var houses: [House] = Array(repeating: House(number: 1, cuspLongitude: 0), count: 12)
        
        houses[0] = House(number: 1, cuspLongitude: ascendant)
        houses[9] = House(number: 10, cuspLongitude: mc)
        houses[3] = House(number: 4, cuspLongitude: ic)
        houses[6] = House(number: 7, cuspLongitude: descendant)
        
        // Quadrant 1: Ascendant to MC
        let q1Size = normalizeAngle(mc - ascendant)
        for i in 1...2 {
            houses[i] = House(number: i + 1, cuspLongitude: normalizeAngle(ascendant + q1Size * Double(i) / 3))
        }
        
        // Quadrant 2: MC to Descendant
        let q2Size = normalizeAngle(descendant - mc)
        for i in 1...2 {
            houses[9 + i] = House(number: 10 + i, cuspLongitude: normalizeAngle(mc + q2Size * Double(i) / 3))
        }
        
        // Quadrant 3: Descendant to IC
        let q3Size = normalizeAngle(ic - descendant)
        for i in 1...2 {
            houses[6 + i] = House(number: 7 + i, cuspLongitude: normalizeAngle(descendant + q3Size * Double(i) / 3))
        }
        
        // Quadrant 4: IC to Ascendant
        let q4Size = normalizeAngle(ascendant - ic)
        for i in 1...2 {
            houses[3 + i] = House(number: 4 + i, cuspLongitude: normalizeAngle(ic + q4Size * Double(i) / 3))
        }
        
        return HouseSystem(
            houses: houses,
            ascendant: ascendant,
            midheaven: mc,
            descendant: descendant,
            imumCoeli: ic
        )
    }
    
    // MARK: - Helper Functions
    
    private func calculateLocalSiderealTime(jd: Double, longitude: Double) -> Double {
        // Julian centuries from J2000
        let T = (jd - 2451545.0) / 36525.0
        
        // Greenwich Mean Sidereal Time at 0h UT
        let gmst0 = 6.697374558 + 0.06570982441908 * (jd - 2451545.0) + 1.00273790935 * 0
        
        // Add longitude (east positive)
        var lst = gmst0 + longitude / 15.0
        
        // Normalize to 0-24 hours
        lst = lst.truncatingRemainder(dividingBy: 24)
        if lst < 0 {
            lst += 24
        }
        
        return lst
    }
    
    private func calculateMC(ramc: Double, epsilon: Double) -> Double {
        let ramcRad = degreesToRadians(ramc)
        let epsRad = degreesToRadians(epsilon)
        
        // MC = arctan(tan(RAMC) / cos(epsilon))
        var mc = radiansToDegrees(atan2(tan(ramcRad), cos(epsRad)))
        
        // Ensure MC is in the same quadrant as RAMC
        if cos(ramcRad) < 0 {
            mc = normalizeAngle(mc + 180)
        }
        
        return normalizeAngle(mc)
    }
    
    private func calculateAscendant(ramc: Double, latitude: Double, epsilon: Double) -> Double {
        let ramcRad = degreesToRadians(ramc)
        let latRad = degreesToRadians(latitude)
        let epsRad = degreesToRadians(epsilon)
        
        // Ascendant formula
        let y = -cos(ramcRad)
        let x = sin(epsRad) * tan(latRad) + cos(epsRad) * sin(ramcRad)
        
        var ascendant = radiansToDegrees(atan2(y, x))
        ascendant = normalizeAngle(ascendant)
        
        return ascendant
    }
    
    private func calculateObliquity(t: Double) -> Double {
        // Mean obliquity of the ecliptic (IAU 2006)
        let epsilon0 = 23.0 + 26.0/60.0 + 21.406/3600.0
        
        let T = t
        let deltaEpsilon = -46.836769 * T 
                            - 0.0001831 * T * T 
                            + 0.00200340 * T * T * T 
                            - 0.000000576 * T * T * T * T 
                            - 0.0000000434 * T * T * T * T * T
        
        return epsilon0 + deltaEpsilon / 3600.0
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
