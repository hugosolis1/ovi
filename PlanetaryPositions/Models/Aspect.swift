import Foundation

enum AspectType: String, CaseIterable, Identifiable {
    case conjunction = "Conjunción"
    case sextile = "Sextil"
    case square = "Cuadratura"
    case trine = "Trígono"
    case opposition = "Oposición"
    case quincunx = "Quincuncio"
    case semisextile = "Semisextil"
    case semisquare = "Semicuadratura"
    case sesquiquadrate = "Sesquicuadratura"
    
    var id: String { rawValue }
    
    var angle: Double {
        switch self {
        case .conjunction: return 0
        case .semisextile: return 30
        case .sextile: return 60
        case .semisquare: return 45
        case .square: return 90
        case .trine: return 120
        case .sesquiquadrate: return 135
        case .quincunx: return 150
        case .opposition: return 180
        }
    }
    
    var orb: Double {
        switch self {
        case .conjunction: return 8
        case .opposition: return 8
        case .trine: return 6
        case .square: return 6
        case .sextile: return 4
        case .quincunx: return 2
        case .semisextile: return 1
        case .semisquare: return 1
        case .sesquiquadrate: return 1
        }
    }
    
    var symbol: String {
        switch self {
        case .conjunction: return "☌"
        case .sextile: return "⚹"
        case .square: return "□"
        case .trine: return "△"
        case .opposition: return "☍"
        case .quincunx: return "⚻"
        case .semisextile: return "⚺"
        case .semisquare: return "∠"
        case .sesquiquadrate: return "⚼"
        }
    }
    
    var nature: AspectNature {
        switch self {
        case .conjunction, .trine, .sextile:
            return .harmonious
        case .square, .opposition, .semisquare, .sesquiquadrate:
            return .challenging
        case .quincunx, .semisextile:
            return .neutral
        }
    }
}

enum AspectNature: String {
    case harmonious = "Armónico"
    case challenging = "Tensivo"
    case neutral = "Neutral"
    
    var color: String {
        switch self {
        case .harmonious: return "green"
        case .challenging: return "red"
        case .neutral: return "gray"
        }
    }
}

struct Aspect: Identifiable {
    let id = UUID()
    let planet1: PlanetType
    let planet2: PlanetType
    let type: AspectType
    let orb: Double
    let exactAngle: Double
    let applying: Bool
    
    var isMajor: Bool {
        type == .conjunction || type == .opposition || 
        type == .trine || type == .square || type == .sextile
    }
    
    var formattedOrb: String {
        let degrees = Int(orb)
        let minutes = Int((orb - Double(degrees)) * 60)
        return "\(degrees)°\(minutes)'"
    }
    
    var description: String {
        "\(planet1.symbol) \(type.symbol) \(planet2.symbol) (orb: \(formattedOrb))"
    }
}

struct AspectConfiguration {
    static func findAspects(between positions: [PlanetPosition], 
                           includeMinor: Bool = false) -> [Aspect] {
        var aspects: [Aspect] = []
        let majorAspects: [AspectType] = [.conjunction, .sextile, .square, .trine, .opposition]
        let minorAspects: [AspectType] = [.semisextile, .semisquare, .sesquiquadrate, .quincunx]
        
        let aspectsToCheck = includeMinor ? majorAspects + minorAspects : majorAspects
        
        for i in 0..<positions.count {
            for j in (i+1)..<positions.count {
                let pos1 = positions[i]
                let pos2 = positions[j]
                
                let angle = abs(pos1.longitude - pos2.longitude)
                let shortestAngle = min(angle, 360 - angle)
                
                for aspectType in aspectsToCheck {
                    let diff = abs(shortestAngle - aspectType.angle)
                    if diff <= aspectType.orb {
                        let applying = pos1.speed > pos2.speed
                        aspects.append(Aspect(
                            planet1: pos1.type,
                            planet2: pos2.type,
                            type: aspectType,
                            orb: diff,
                            exactAngle: shortestAngle,
                            applying: applying
                        ))
                    }
                }
            }
        }
        
        return aspects.sorted { $0.orb < $1.orb }
    }
}
