import Foundation
import SwiftUI

enum ZodiacSign: String, CaseIterable, Identifiable {
    case aries = "Aries"
    case taurus = "Tauro"
    case gemini = "Géminis"
    case cancer = "Cáncer"
    case leo = "Leo"
    case virgo = "Virgo"
    case libra = "Libra"
    case scorpio = "Escorpio"
    case sagittarius = "Sagitario"
    case capricorn = "Capricornio"
    case aquarius = "Acuario"
    case pisces = "Piscis"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }
    
    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }
    
    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }
    
    var ruler: PlanetType {
        switch self {
        case .aries: return .mars
        case .taurus: return .venus
        case .gemini: return .mercury
        case .cancer: return .moon
        case .leo: return .sun
        case .virgo: return .mercury
        case .libra: return .venus
        case .scorpio: return .pluto
        case .sagittarius: return .jupiter
        case .capricorn: return .saturn
        case .aquarius: return .uranus
        case .pisces: return .neptune
        }
    }
    
    var startLongitude: Double {
        Double(allCases.firstIndex(of: self)!) * 30.0
    }
    
    var endLongitude: Double {
        startLongitude + 30.0
    }
    
    var color: Color {
        element.color
    }
    
    static func from(longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360)
        let index = Int(normalized / 30) % 12
        return allCases[index]
    }
    
    static func from(degrees: Double) -> ZodiacSign {
        from(longitude: degrees)
    }
}

enum Element: String, CaseIterable {
    case fire = "Fuego"
    case earth = "Tierra"
    case air = "Aire"
    case water = "Agua"
    
    var color: Color {
        switch self {
        case .fire: return .red
        case .earth: return .green
        case .air: return .yellow
        case .water: return .blue
        }
    }
}

enum Modality: String, CaseIterable {
    case cardinal = "Cardinal"
    case fixed = "Fijo"
    case mutable = "Mutable"
}
