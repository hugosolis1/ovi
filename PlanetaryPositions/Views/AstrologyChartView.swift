import SwiftUI

struct AstrologyChartView: View {
    let chartData: ChartData?
    @State private var showHouses = true
    @State private var showAspects = true
    @State private var selectedPlanet: PlanetPosition?
    @State private var zoomScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                if let chart = chartData {
                    // Controls
                    HStack {
                        Toggle("Casas", isOn: $showHouses)
                            .toggleStyle(.button)
                        
                        Toggle("Aspectos", isOn: $showAspects)
                            .toggleStyle(.button)
                        
                        Spacer()
                        
                        Button(action: { zoomScale = 1.0 }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Chart wheel
                    GeometryReader { geometry in
                        let size = min(geometry.size.width, geometry.size.height) * zoomScale
                        
                        ZStack {
                            // Background
                            Circle()
                                .fill(Color(.systemBackground))
                                .shadow(radius: 10)
                            
                            // Zodiac wheel
                            ChartWheelView(
                                chartData: chart,
                                showHouses: showHouses,
                                showAspects: showAspects,
                                selectedPlanet: $selectedPlanet,
                                size: size
                            )
                        }
                        .frame(width: size, height: size)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                zoomScale = min(max(value, 0.5), 2.0)
                            }
                    )
                    
                    // Selected planet info
                    if let planet = selectedPlanet {
                        PlanetDetailView(position: planet, houseSystem: chart.houseSystem)
                            .transition(.move(edge: .bottom))
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "circle.dashed")
                            .font(.system(size: 60))
                            .foregroundColor(.purple.opacity(0.5))
                        
                        Text("No hay carta astral")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Ve a Configuración y calcula una carta")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Carta Astral")
        }
    }
}

struct ChartWheelView: View {
    let chartData: ChartData
    let showHouses: Bool
    let showAspects: Bool
    @Binding var selectedPlanet: PlanetPosition?
    let size: CGFloat
    
    private let zodiacRingWidth: CGFloat = 40
    private let houseRingWidth: CGFloat = 30
    private let planetRadius: CGFloat = 25
    
    var body: some View {
        ZStack {
            // Outer zodiac ring
            ZodiacRingView(size: size)
            
            // House cusps
            if showHouses, let houses = chartData.houseSystem {
                HouseRingView(houses: houses, size: size - zodiacRingWidth * 2)
            }
            
            // Aspect lines
            if showAspects {
                AspectLinesView(chartData: chartData, size: size - zodiacRingWidth * 2 - houseRingWidth * 2)
            }
            
            // Planet positions
            PlanetRingView(
                chartData: chartData,
                selectedPlanet: $selectedPlanet,
                size: size - zodiacRingWidth * 2 - houseRingWidth * 2
            )
            
            // Center info
            CenterInfoView(chartData: chartData)
        }
    }
}

struct ZodiacRingView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color.purple.opacity(0.3), lineWidth: 2)
            
            // Zodiac signs
            ForEach(ZodiacSign.allCases) { sign in
                ZodiacSignView(sign: sign, size: size)
            }
            
            // Degree markers
            ForEach(0..<360) { degree in
                if degree % 5 == 0 {
                    DegreeMarker(degree: degree, size: size)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct ZodiacSignView: View {
    let sign: ZodiacSign
    let size: CGFloat
    
    private var angle: Double {
        sign.startLongitude + 15 // Center of the sign
    }
    
    var body: some View {
        let radius = size / 2 - 25
        let x = radius * cos(degreesToRadians(angle - 90))
        let y = radius * sin(degreesToRadians(angle - 90))
        
        ZStack {
            // Sign background
            Circle()
                .fill(sign.color.opacity(0.2))
                .frame(width: 32, height: 32)
            
            // Sign symbol
            Text(sign.symbol)
                .font(.system(size: 18))
                .foregroundColor(sign.color)
        }
        .position(x: size / 2 + x, y: size / 2 + y)
    }
}

struct DegreeMarker: View {
    let degree: Int
    let size: CGFloat
    
    var body: some View {
        let radius = size / 2 - 5
        let x1 = (radius - (degree % 10 == 0 ? 8 : 4)) * cos(degreesToRadians(Double(degree) - 90))
        let y1 = (radius - (degree % 10 == 0 ? 8 : 4)) * sin(degreesToRadians(Double(degree) - 90))
        let x2 = radius * cos(degreesToRadians(Double(degree) - 90))
        let y2 = radius * sin(degreesToRadians(Double(degree) - 90))
        
        Path { path in
            path.move(to: CGPoint(x: size / 2 + x1, y: size / 2 + y1))
            path.addLine(to: CGPoint(x: size / 2 + x2, y: size / 2 + y2))
        }
        .stroke(degree % 30 == 0 ? Color.purple : Color.gray.opacity(0.5), lineWidth: degree % 30 == 0 ? 2 : 1)
    }
}

struct HouseRingView: View {
    let houses: HouseSystem
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // House cusp lines
            ForEach(houses.houses) { house in
                HouseCuspLine(house: house, size: size)
            }
            
            // House numbers
            ForEach(houses.houses) { house in
                HouseNumberView(house: house, size: size)
            }
        }
        .frame(width: size, height: size)
    }
}

struct HouseCuspLine: View {
    let house: House
    let size: CGFloat
    
    var body: some View {
        let radius = size / 2
        let angle = house.cuspLongitude - 90
        let x = radius * cos(degreesToRadians(angle))
        let y = radius * sin(degreesToRadians(angle))
        
        Path { path in
            path.move(to: CGPoint(x: size / 2, y: size / 2))
            path.addLine(to: CGPoint(x: size / 2 + x, y: size / 2 + y))
        }
        .stroke(house.number == 1 || house.number == 10 ? Color.purple : Color.gray.opacity(0.3),
                lineWidth: house.number == 1 || house.number == 10 ? 2 : 1)
    }
}

struct HouseNumberView: View {
    let house: House
    let size: CGFloat
    
    var body: some View {
        let angle = house.cuspLongitude + 15 // Middle of the house
        let radius = size / 2 - 20
        let x = radius * cos(degreesToRadians(angle - 90))
        let y = radius * sin(degreesToRadians(angle - 90))
        
        Text("\(house.number)")
            .font(.caption)
            .foregroundColor(.secondary)
            .position(x: size / 2 + x, y: size / 2 + y)
    }
}

struct AspectLinesView: View {
    let chartData: ChartData
    let size: CGFloat
    
    var body: some View {
        let majorAspects = chartData.aspects.filter { $0.isMajor }
        
        ZStack {
            ForEach(majorAspects.prefix(20)) { aspect in
                if let pos1 = chartData.planetPositions.first(where: { $0.type == aspect.planet1 }),
                   let pos2 = chartData.planetPositions.first(where: { $0.type == aspect.planet2 }) {
                    AspectLine(
                        from: pos1.longitude,
                        to: pos2.longitude,
                        aspectType: aspect.type,
                        size: size
                    )
                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct AspectLine: View {
    let from: Double
    let to: Double
    let aspectType: AspectType
    let size: CGFloat
    
    var body: some View {
        let radius = size / 2 - 30
        let x1 = radius * cos(degreesToRadians(from - 90))
        let y1 = radius * sin(degreesToRadians(from - 90))
        let x2 = radius * cos(degreesToRadians(to - 90))
        let y2 = radius * sin(degreesToRadians(to - 90))
        
        Path { path in
            path.move(to: CGPoint(x: size / 2 + x1, y: size / 2 + y1))
            path.addLine(to: CGPoint(x: size / 2 + x2, y: size / 2 + y2))
        }
        .stroke(aspectColor, style: StrokeStyle(lineWidth: 1, dash: aspectType == .opposition ? [5, 3] : []))
        .opacity(0.6)
    }
    
    private var aspectColor: Color {
        switch aspectType.nature {
        case .harmonious:
            return .green
        case .challenging:
            return .red
        case .neutral:
            return .gray
        }
    }
}

struct PlanetRingView: View {
    let chartData: ChartData
    @Binding var selectedPlanet: PlanetPosition?
    let size: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(chartData.planetPositions) { position in
                PlanetOnChart(
                    position: position,
                    isSelected: selectedPlanet?.id == position.id,
                    size: size
                )
                .onTapGesture {
                    withAnimation {
                        selectedPlanet = position
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct PlanetOnChart: View {
    let position: PlanetPosition
    let isSelected: Bool
    let size: CGFloat
    
    private var radius: CGFloat {
        size / 2 - 50
    }
    
    private var x: CGFloat {
        radius * CGFloat(cos(degreesToRadians(position.longitude - 90)))
    }
    
    private var y: CGFloat {
        radius * CGFloat(sin(degreesToRadians(position.longitude - 90)))
    }
    
    var body: some View {
        ZStack {
            // Selection ring
            if isSelected {
                Circle()
                    .stroke(position.type.color, lineWidth: 3)
                    .frame(width: 36, height: 36)
            }
            
            // Planet circle
            Circle()
                .fill(position.type.color.opacity(0.3))
                .frame(width: 30, height: 30)
            
            // Planet symbol
            Text(position.type.symbol)
                .font(.system(size: 16))
                .foregroundColor(position.type.color)
            
            // Retrograde indicator
            if position.isRetrograde {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 8))
                    .foregroundColor(.red)
                    .offset(x: 10, y: -10)
            }
        }
        .position(x: size / 2 + x, y: size / 2 + y)
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct CenterInfoView: View {
    let chartData: ChartData
    
    var body: some View {
        VStack(spacing: 4) {
            if let houses = chartData.houseSystem {
                Text(houses.ascendantSign.symbol)
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                
                Text("Asc")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(chartData.calculationMode == .geocentric ? "🌍" : "☀️")
                .font(.title2)
        }
        .padding()
        .background(
            Circle()
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
}

struct PlanetDetailView: View {
    let position: PlanetPosition
    let houseSystem: HouseSystem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(position.type.symbol)
                    .font(.title)
                    .foregroundColor(position.type.color)
                
                Text(position.type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                if position.isRetrograde {
                    Label("Retrógrado", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Posición:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(position.zodiacSign.symbol) \(String(format: "%.2f°", position.degreeInSign))")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Longitud:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(position.formattedLongitude)
                        .font(.subheadline)
                        .monospacedDigit()
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Velocidad:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.4f°/día", position.speed))
                        .font(.subheadline)
                        .monospacedDigit()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Distancia:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.4f AU", position.distance))
                        .font(.subheadline)
                        .monospacedDigit()
                }
            }
            
            if let house = houseSystem?.houseContaining(longitude: position.longitude) {
                HStack {
                    Text("Casa:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(house.number) (\(house.zodiacSign.symbol))")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Helper Functions

private func degreesToRadians(_ degrees: Double) -> Double {
    degrees * .pi / 180
}
