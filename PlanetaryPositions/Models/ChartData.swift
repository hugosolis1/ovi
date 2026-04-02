import Foundation
import CoreLocation

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let utcOffset: Int
    let latitude: Double
    let longitude: Double
    let locationName: String
    let calculationMode: CalculationMode
    let planetPositions: [PlanetPosition]
    let houseSystem: HouseSystem?
    let aspects: [Aspect]
    
    var julianDay: Double {
        calculateJulianDay(date: date, utcOffset: utcOffset)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedCoordinates: String {
        let latDir = latitude >= 0 ? "N" : "S"
        let lonDir = longitude >= 0 ? "E" : "W"
        return String(format: "%.4f°%@, %.4f°%@", 
                     abs(latitude), latDir, abs(longitude), lonDir)
    }
    
    var formattedUTC: String {
        if utcOffset >= 0 {
            return "UTC+\(utcOffset)"
        } else {
            return "UTC\(utcOffset)"
        }
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
            return 0
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
        
        let jd = floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524.5 + dayFraction
        
        return jd
    }
}

struct LocationData {
    static let greenwich = (
        name: "Greenwich, Londres",
        latitude: 51.4769,
        longitude: -0.0005
    )
    
    static let defaultLocations: [(name: String, latitude: Double, longitude: Double)] = [
        greenwich,
        ("Nueva York", 40.7128, -74.0060),
        ("Los Ángeles", 34.0522, -118.2437),
        ("Madrid", 40.4168, -3.7038),
        ("Buenos Aires", -34.6037, -58.3816),
        ("Ciudad de México", 19.4326, -99.1332),
        ("Tokio", 35.6762, 139.6503),
        ("Sídney", -33.8688, 151.2093)
    ]
}
