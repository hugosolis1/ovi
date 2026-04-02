import Foundation
import SwiftUI

enum PlanetType: String, CaseIterable, Identifiable {
    case sun = "Sol"
    case moon = "Luna"
    case mercury = "Mercurio"
    case venus = "Venus"
    case mars = "Marte"
    case jupiter = "Júpiter"
    case saturn = "Saturno"
    case uranus = "Urano"
    case neptune = "Neptuno"
    case pluto = "Plutón"
    case northNode = "Nodo Norte"
    case southNode = "Nodo Sur"
    case chiron = "Quirón"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        case .chiron: return "⚷"
        }
    }
    
    var color: Color {
        switch self {
        case .sun: return .yellow
        case .moon: return .gray
        case .mercury: return .orange
        case .venus: return .green
        case .mars: return .red
        case .jupiter: return .purple
        case .saturn: return .blue
        case .uranus: return .cyan
        case .neptune: return .indigo
        case .pluto: return .brown
        case .northNode, .southNode: return .pink
        case .chiron: return .mint
        }
    }
    
    var isLuminarie: Bool {
        self == .sun || self == .moon
    }
    
    var isSocialPlanet: Bool {
        self == .mercury || self == .venus || self == .mars
    }
    
    var isTranspersonal: Bool {
        self == .jupiter || self == .saturn || self == .uranus || 
        self == .neptune || self == .pluto
    }
}

struct PlanetPosition: Identifiable, Equatable {
    let id = UUID()
    let type: PlanetType
    let longitude: Double  // 0-360 degrees
    let latitude: Double   // degrees
    let distance: Double   // AU
    let speed: Double      // degrees/day
    let isRetrograde: Bool
    
    var longitudeDegrees: Double {
        longitude.truncatingRemainder(dividingBy: 360)
    }
    
    var zodiacSign: ZodiacSign {
        ZodiacSign.from(longitude: longitude)
    }
    
    var degreeInSign: Double {
        let signIndex = Int(longitude / 30)
        return longitude - Double(signIndex * 30)
    }
    
    var formattedPosition: String {
        let degrees = Int(degreeInSign)
        let minutes = Int((degreeInSign - Double(degrees)) * 60)
        return "\(degrees)°\(minutes)' \(zodiacSign.symbol)"
    }
    
    var formattedLongitude: String {
        let deg = Int(longitudeDegrees)
        let min = Int((longitudeDegrees - Double(deg)) * 60)
        let sec = Int(((longitudeDegrees - Double(deg)) * 60 - Double(min)) * 60)
        return String(format: "%d°%d'%d\"", deg, min, sec)
    }
    
    static func == (lhs: PlanetPosition, rhs: PlanetPosition) -> Bool {
        lhs.type == rhs.type && abs(lhs.longitude - rhs.longitude) < 0.0001
    }
}

enum CalculationMode: String, CaseIterable, Identifiable {
    case geocentric = "Geocéntrico"
    case heliocentric = "Heliocéntrico"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .geocentric: return "globe"
        case .heliocentric: return "sun.max"
        }
    }
}
