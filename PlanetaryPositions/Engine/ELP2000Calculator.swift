import Foundation

class ELP2000Calculator {
    
    // MARK: - ELP2000-82 Lunar Theory
    
    // Simplified implementation of ELP2000-82 theory
    // Full implementation includes thousands of terms
    
    struct ELP2000Term {
        let amplitude: Double
        let phase: Double
        let frequency: Double
        let D: Int  // Mean elongation of Moon
        let M: Int  // Mean anomaly of Sun
        let Mp: Int // Mean anomaly of Moon
        let F: Int  // Argument of latitude
        let omega: Int // Longitude of ascending node
    }
    
    // Main periodic terms for lunar longitude (simplified)
    private let longitudeTerms: [ELP2000Term] = [
        // Main inequality
        ELP2000Term(amplitude: 6.289, phase: 5.168, frequency: 8399.685, D: 0, M: 0, Mp: 1, F: 0, omega: 0),
        // Evection
        ELP2000Term(amplitude: 1.274, phase: 0.0, frequency: 7771.377, D: 2, M: -1, Mp: 0, F: 0, omega: 0),
        // Variation
        ELP2000Term(amplitude: 0.658, phase: 0.214, frequency: 15542.754, D: 2, M: 0, Mp: 0, F: 0, omega: 0),
        // Yearly equation
        ELP2000Term(amplitude: 0.214, phase: 2.453, frequency: 628.302, D: 0, M: 1, Mp: 0, F: 0, omega: 0),
        // Parallactic inequality
        ELP2000Term(amplitude: 0.186, phase: 3.814, frequency: 9664.040, D: 0, M: 0, Mp: 0, F: 2, omega: 0),
        // Reduction to ecliptic
        ELP2000Term(amplitude: 0.114, phase: 3.142, frequency: 0.0, D: 0, M: 0, Mp: 0, F: 0, omega: 1),
        // Additional terms
        ELP2000Term(amplitude: 0.059, phase: 0.83, frequency: 11790.629, D: 4, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.057, phase: 3.14, frequency: 0.0, D: 0, M: 0, Mp: 0, F: 0, omega: 2),
        ELP2000Term(amplitude: 0.053, phase: 0.40, frequency: 6133.512, D: 2, M: -2, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.046, phase: 0.50, frequency: 529.691, D: 0, M: 0, Mp: 2, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.042, phase: 2.16, frequency: 10977.079, D: 4, M: -1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.034, phase: 2.56, frequency: 5486.778, D: 1, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.032, phase: 4.56, frequency: 6069.776, D: 2, M: 1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.030, phase: 1.19, frequency: -796.298, D: 0, M: 2, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.027, phase: 4.27, frequency: 5856.478, D: 6, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.025, phase: 5.06, frequency: 5959.095, D: 2, M: 0, Mp: -1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.023, phase: 1.66, frequency: 5855.909, D: 4, M: -2, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.021, phase: 0.48, frequency: 5893.423, D: 2, M: 0, Mp: 1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.020, phase: 3.00, frequency: 5746.271, D: 6, M: -1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.019, phase: 2.00, frequency: 5756.566, D: 0, M: 1, Mp: -1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.018, phase: 4.00, frequency: 5750.671, D: 2, M: 1, Mp: -1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.017, phase: 1.00, frequency: 6131.493, D: 2, M: -1, Mp: 1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.016, phase: 5.00, frequency: 6072.958, D: 2, M: 0, Mp: -2, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.015, phase: 2.50, frequency: 11712.955, D: 6, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.014, phase: 3.50, frequency: 6132.028, D: 2, M: 0, Mp: 2, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.013, phase: 0.50, frequency: 5966.731, D: 4, M: 0, Mp: -1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.012, phase: 4.50, frequency: 6283.076, D: 0, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.011, phase: 1.50, frequency: 11718.744, D: 8, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.010, phase: 5.50, frequency: 5754.069, D: 4, M: 1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.009, phase: 2.50, frequency: 5884.927, D: 4, M: 0, Mp: 1, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.009, phase: 0.00, frequency: 5852.958, D: 2, M: -1, Mp: -1, F: 0, omega: 0)
    ]
    
    // Terms for lunar latitude (simplified)
    private let latitudeTerms: [ELP2000Term] = [
        ELP2000Term(amplitude: 5.128, phase: 3.81, frequency: 8399.685, D: 0, M: 0, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.281, phase: 0.0, frequency: 0.0, D: 0, M: 0, Mp: 0, F: 0, omega: 1),
        ELP2000Term(amplitude: 0.278, phase: 3.0, frequency: 7771.377, D: 2, M: -1, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.173, phase: 5.0, frequency: 15542.754, D: 2, M: 0, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.055, phase: 3.0, frequency: 9664.040, D: 0, M: 0, Mp: 0, F: 3, omega: 0),
        ELP2000Term(amplitude: 0.046, phase: 4.0, frequency: 11790.629, D: 4, M: 0, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.033, phase: 2.0, frequency: 6133.512, D: 2, M: -2, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.025, phase: 1.0, frequency: 10977.079, D: 4, M: -1, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.021, phase: 5.0, frequency: 5486.778, D: 1, M: 0, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.019, phase: 3.0, frequency: 6069.776, D: 2, M: 1, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.017, phase: 1.0, frequency: 5856.478, D: 6, M: 0, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.016, phase: 4.0, frequency: 5959.095, D: 2, M: 0, Mp: -1, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.015, phase: 2.0, frequency: 5855.909, D: 4, M: -2, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.014, phase: 0.0, frequency: 5893.423, D: 2, M: 0, Mp: 1, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.013, phase: 3.0, frequency: 5746.271, D: 6, M: -1, Mp: 0, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.012, phase: 1.0, frequency: 5756.566, D: 0, M: 1, Mp: -1, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.011, phase: 5.0, frequency: 5750.671, D: 2, M: 1, Mp: -1, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.010, phase: 2.0, frequency: 6131.493, D: 2, M: -1, Mp: 1, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.009, phase: 0.0, frequency: 6072.958, D: 2, M: 0, Mp: -2, F: 1, omega: 0),
        ELP2000Term(amplitude: 0.008, phase: 4.0, frequency: 11712.955, D: 6, M: 0, Mp: 0, F: 1, omega: 0)
    ]
    
    // Terms for lunar distance (simplified)
    private let distanceTerms: [ELP2000Term] = [
        ELP2000Term(amplitude: -0.58, phase: 0.0, frequency: 8399.685, D: 0, M: 0, Mp: 1, F: 0, omega: 0),
        ELP2000Term(amplitude: -0.46, phase: 0.0, frequency: 7771.377, D: 2, M: -1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: -0.09, phase: 0.0, frequency: 15542.754, D: 2, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.08, phase: 0.0, frequency: 9664.040, D: 0, M: 0, Mp: 0, F: 2, omega: 0),
        ELP2000Term(amplitude: 0.05, phase: 0.0, frequency: 11790.629, D: 4, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.04, phase: 0.0, frequency: 6133.512, D: 2, M: -2, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.03, phase: 0.0, frequency: 10977.079, D: 4, M: -1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.02, phase: 0.0, frequency: 5486.778, D: 1, M: 0, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.02, phase: 0.0, frequency: 6069.776, D: 2, M: 1, Mp: 0, F: 0, omega: 0),
        ELP2000Term(amplitude: 0.01, phase: 0.0, frequency: 5856.478, D: 6, M: 0, Mp: 0, F: 0, omega: 0)
    ]
    
    // MARK: - Calculation
    
    func calculatePosition(jd: Double) -> (longitude: Double, latitude: Double, distance: Double) {
        // Julian centuries from J2000
        let T = (jd - 2451545.0) / 36525.0
        
        // Mean elements (in degrees)
        let Lp = 218.3164477 + 481267.88123421 * T - 0.0015786 * T * T + T * T * T / 538841.0 - T * T * T * T / 65194000.0
        let D = 297.8501921 + 445267.1114034 * T - 0.0018819 * T * T + T * T * T / 545868.0 - T * T * T * T / 113065000.0
        let M = 357.5291092 + 35999.0502909 * T - 0.0001536 * T * T + T * T * T / 24490000.0
        let Mp = 134.9633964 + 477198.8675055 * T + 0.0087414 * T * T + T * T * T / 69699.0 - T * T * T * T / 14712000.0
        let F = 93.2720950 + 483202.0175233 * T - 0.0036539 * T * T - T * T * T / 3526000.0 + T * T * T * T / 863310000.0
        let omega = 125.0445479 - 1934.1362891 * T + 0.0020754 * T * T + T * T * T / 467441.0 - T * T * T * T / 60616000.0
        
        // Mean longitude
        var longitude = Lp
        
        // Add periodic terms for longitude
        for term in longitudeTerms {
            let argument = term.D * D + term.M * M + term.Mp * Mp + term.F * F + term.omega * omega
            longitude += term.amplitude * sin(degreesToRadians(argument))
        }
        
        // Calculate latitude
        var latitude = 0.0
        for term in latitudeTerms {
            let argument = term.D * D + term.M * M + term.Mp * Mp + term.F * F + term.omega * omega
            latitude += term.amplitude * sin(degreesToRadians(argument))
        }
        
        // Calculate distance (Earth radii)
        var distance = 60.2666 // Mean distance
        for term in distanceTerms {
            let argument = term.D * D + term.M * M + term.Mp * Mp + term.F * F + term.omega * omega
            distance += term.amplitude * cos(degreesToRadians(argument))
        }
        
        // Convert distance to AU
        let distanceAU = distance * 6378.14 / 149597870.7
        
        return (normalizeAngle(longitude), latitude, distanceAU)
    }
    
    func calculateDetailedPosition(jd: Double) -> (
        longitude: Double,
        latitude: Double,
        distance: Double,
        longitudeSpeed: Double,
        latitudeSpeed: Double
    ) {
        let (lon, lat, dist) = calculatePosition(jd: jd)
        
        // Calculate speed using numerical differentiation
        let dt = 0.001 // days
        let (lon2, lat2, _) = calculatePosition(jd: jd + dt)
        
        let lonSpeed = (lon2 - lon) / dt
        let latSpeed = (lat2 - lat) / dt
        
        return (lon, lat, dist, lonSpeed, latSpeed)
    }
    
    // MARK: - Helper Functions
    
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
