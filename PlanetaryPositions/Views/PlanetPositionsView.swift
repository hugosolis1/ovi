import SwiftUI

struct PlanetPositionsView: View {
    let chartData: ChartData?
    @State private var showRetrogradeOnly = false
    @State private var sortBy: SortOption = .longitude
    
    enum SortOption: String, CaseIterable, Identifiable {
        case longitude = "Longitud"
        case name = "Nombre"
        case speed = "Velocidad"
        case distance = "Distancia"
        
        var id: String { rawValue }
    }
    
    var filteredAndSortedPositions: [PlanetPosition] {
        guard let chart = chartData else { return [] }
        
        var positions = chart.planetPositions
        
        if showRetrogradeOnly {
            positions = positions.filter { $0.isRetrograde }
        }
        
        switch sortBy {
        case .longitude:
            positions.sort { $0.longitude < $1.longitude }
        case .name:
            positions.sort { $0.type.rawValue < $1.type.rawValue }
        case .speed:
            positions.sort { abs($0.speed) > abs($1.speed) }
        case .distance:
            positions.sort { $0.distance < $1.distance }
        }
        
        return positions
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let chart = chartData {
                    // Filter and sort controls
                    HStack {
                        Picker("Ordenar por", selection: $sortBy) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 150)
                        
                        Spacer()
                        
                        Toggle("Solo retrógrados", isOn: $showRetrogradeOnly)
                            .toggleStyle(.switch)
                            .frame(maxWidth: 180)
                    }
                    .padding(.horizontal)
                    
                    // Summary
                    HStack(spacing: 20) {
                        StatView(title: "Planetas", value: "\(chart.planetPositions.count)")
                        StatView(title: "Retrógrados", value: "\(chart.planetPositions.filter { $0.isRetrograde }.count)")
                        StatView(title: "Aspectos", value: "\(chart.aspects.count)")
                    }
                    .padding()
                    
                    // Planet list
                    List {
                        ForEach(filteredAndSortedPositions) { position in
                            PlanetRowView(position: position, houseSystem: chart.houseSystem)
                        }
                    }
                    .listStyle(.plain)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.purple.opacity(0.5))
                        
                        Text("No hay datos")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Ve a Configuración y calcula una carta astral")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Posiciones Planetarias")
        }
    }
}

struct PlanetRowView: View {
    let position: PlanetPosition
    let houseSystem: HouseSystem?
    
    var body: some View {
        HStack(spacing: 12) {
            // Planet symbol
            ZStack {
                Circle()
                    .fill(position.type.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text(position.type.symbol)
                    .font(.system(size: 24))
                    .foregroundColor(position.type.color)
            }
            
            // Planet info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(position.type.rawValue)
                        .font(.headline)
                    
                    if position.isRetrograde {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    // House number
                    if let house = houseSystem?.houseContaining(longitude: position.longitude) {
                        Text("Casa \(house.number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 16) {
                    // Position
                    HStack(spacing: 4) {
                        Text(position.zodiacSign.symbol)
                            .foregroundColor(position.zodiacSign.color)
                        Text(String(format: "%.2f°", position.degreeInSign))
                            .monospacedDigit()
                    }
                    
                    // Longitude
                    Label {
                        Text(position.formattedLongitude)
                            .font(.caption)
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: "arrow.right.circle")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Speed
                    Label {
                        Text(String(format: "%.3f°/d", position.speed))
                            .font(.caption)
                            .monospacedDigit()
                    } icon: {
                        Image(systemName: position.speed >= 0 ? "arrow.forward" : "arrow.backward")
                            .font(.caption2)
                    }
                    .foregroundColor(position.speed >= 0 ? .green : .red)
                }
                
                // Distance
                HStack {
                    Text(String(format: "Distancia: %.4f AU", position.distance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    // Element
                    Text(position.zodiacSign.element.rawValue)
                        .font(.caption)
                        .foregroundColor(position.zodiacSign.element.color)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }
}
