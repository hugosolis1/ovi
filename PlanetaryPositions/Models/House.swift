import Foundation

struct House: Identifiable, Equatable {
    let id = UUID()
    let number: Int
    let cuspLongitude: Double
    
    var zodiacSign: ZodiacSign {
        ZodiacSign.from(longitude: cuspLongitude)
    }
    
    var degreeInSign: Double {
        let signIndex = Int(cuspLongitude / 30)
        return cuspLongitude - Double(signIndex * 30)
    }
    
    var formattedCusp: String {
        let degrees = Int(degreeInSign)
        let minutes = Int((degreeInSign - Double(degrees)) * 60)
        return "\(degrees)°\(minutes)' \(zodiacSign.symbol)"
    }
    
    var name: String {
        switch number {
        case 1: return "Casa I (Ascendente)"
        case 2: return "Casa II"
        case 3: return "Casa III"
        case 4: return "Casa IV (IC)"
        case 5: return "Casa V"
        case 6: return "Casa VI"
        case 7: return "Casa VII (Descendente)"
        case 8: return "Casa VIII"
        case 9: return "Casa IX"
        case 10: return "Casa X (MC)"
        case 11: return "Casa XI"
        case 12: return "Casa XII"
        default: return "Casa \(number)"
        }
    }
    
    static func == (lhs: House, rhs: House) -> Bool {
        lhs.number == rhs.number && abs(lhs.cuspLongitude - rhs.cuspLongitude) < 0.0001
    }
}

struct HouseSystem {
    let houses: [House]
    let ascendant: Double
    let midheaven: Double
    let descendant: Double
    let imumCoeli: Double
    
    var ascendantSign: ZodiacSign {
        ZodiacSign.from(longitude: ascendant)
    }
    
    var midheavenSign: ZodiacSign {
        ZodiacSign.from(longitude: midheaven)
    }
    
    func houseContaining(longitude: Double) -> House? {
        for i in 0..<houses.count {
            let current = houses[i]
            let next = houses[(i + 1) % houses.count]
            
            if current.cuspLongitude <= next.cuspLongitude {
                if longitude >= current.cuspLongitude && longitude < next.cuspLongitude {
                    return current
                }
            } else {
                // House crosses 0°
                if longitude >= current.cuspLongitude || longitude < next.cuspLongitude {
                    return current
                }
            }
        }
        return houses.first
    }
}
