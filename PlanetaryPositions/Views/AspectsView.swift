import SwiftUI

struct AspectsView: View {
    let chartData: ChartData?
    @State private var showMinorAspects = false
    @State private var selectedAspect: Aspect?
    
    var filteredAspects: [Aspect] {
        guard let chart = chartData else { return [] }
        
        if showMinorAspects {
            return chart.aspects
        } else {
            return chart.aspects.filter { $0.isMajor }
        }
    }
    
    var aspectsByType: [AspectType: [Aspect]] {
        Dictionary(grouping: filteredAspects) { $0.type }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let chart = chartData {
                    // Controls
                    HStack {
                        Toggle("Aspectos menores", isOn: $showMinorAspects)
                            .toggleStyle(.switch)
                        
                        Spacer()
                        
                        Text("\(filteredAspects.count) aspectos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Aspect summary
                    AspectSummaryView(aspects: filteredAspects)
                        .padding(.horizontal)
                    
                    // Aspect list
                    List {
                        ForEach(AspectType.allCases) { type in
                            if let aspects = aspectsByType[type], !aspects.isEmpty {
                                Section(header: AspectSectionHeader(type: type, count: aspects.count)) {
                                    ForEach(aspects) { aspect in
                                        AspectRow(aspect: aspect)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                selectedAspect = aspect
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "line.3.crossed.swirl.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.purple.opacity(0.5))
                        
                        Text("No hay aspectos")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Ve a Configuración y calcula una carta astral")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Aspectos Planetarios")
            .sheet(item: $selectedAspect) { aspect in
                AspectDetailView(aspect: aspect)
            }
        }
    }
}

struct AspectSummaryView: View {
    let aspects: [Aspect]
    
    var harmoniousCount: Int {
        aspects.filter { $0.type.nature == .harmonious }.count
    }
    
    var challengingCount: Int {
        aspects.filter { $0.type.nature == .challenging }.count
    }
    
    var neutralCount: Int {
        aspects.filter { $0.type.nature == .neutral }.count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AspectStatView(
                title: "Armónicos",
                count: harmoniousCount,
                color: .green,
                icon: "hand.thumbsup.fill"
            )
            
            AspectStatView(
                title: "Tensivos",
                count: challengingCount,
                color: .red,
                icon: "hand.thumbsdown.fill"
            )
            
            AspectStatView(
                title: "Neutros",
                count: neutralCount,
                color: .gray,
                icon: "minus.circle.fill"
            )
        }
    }
}

struct AspectStatView: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AspectSectionHeader: View {
    let type: AspectType
    let count: Int
    
    var body: some View {
        HStack {
            Text(type.symbol)
                .font(.title3)
                .foregroundColor(aspectColor)
            
            Text(type.rawValue)
                .font(.headline)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4)
        }
        .foregroundColor(aspectColor)
    }
    
    private var aspectColor: Color {
        switch type.nature {
        case .harmonious:
            return .green
        case .challenging:
            return .red
        case .neutral:
            return .gray
        }
    }
}

struct AspectRow: View {
    let aspect: Aspect
    
    var body: some View {
        HStack(spacing: 12) {
            // Planet 1
            VStack {
                Text(aspect.planet1.symbol)
                    .font(.title2)
                    .foregroundColor(planetColor(aspect.planet1))
                Text(aspect.planet1.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // Aspect symbol
            ZStack {
                Circle()
                    .fill(aspectColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(aspect.type.symbol)
                    .font(.title3)
                    .foregroundColor(aspectColor)
            }
            
            // Planet 2
            VStack {
                Text(aspect.planet2.symbol)
                    .font(.title2)
                    .foregroundColor(planetColor(aspect.planet2))
                Text(aspect.planet2.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            Spacer()
            
            // Orb
            VStack(alignment: .trailing, spacing: 2) {
                Text("Órbita")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(aspect.formattedOrb)
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundColor(orbColor)
                
                Text(aspect.applying ? "Aplicando" : "Separando")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var aspectColor: Color {
        switch aspect.type.nature {
        case .harmonious:
            return .green
        case .challenging:
            return .red
        case .neutral:
            return .gray
        }
    }
    
    private var orbColor: Color {
        if aspect.orb < 1 {
            return .green
        } else if aspect.orb < 3 {
            return .orange
        } else {
            return .secondary
        }
    }
    
    private func planetColor(_ planet: PlanetType) -> Color {
        switch planet {
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
}

struct AspectDetailView: View {
    let aspect: Aspect
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        HStack(spacing: 30) {
                            PlanetDetailCircle(planet: aspect.planet1)
                            
                            VStack {
                                Text(aspect.type.symbol)
                                    .font(.system(size: 50))
                                    .foregroundColor(aspectColor)
                                
                                Text(aspect.type.rawValue)
                                    .font(.headline)
                                    .foregroundColor(aspectColor)
                            }
                            
                            PlanetDetailCircle(planet: aspect.planet2)
                        }
                    }
                    .padding()
                    
                    // Aspect info
                    VStack(alignment: .leading, spacing: 16) {
                        InfoRow(title: "Ángulo exacto", value: String(format: "%.2f°", aspect.exactAngle))
                        InfoRow(title: "Órbita", value: aspect.formattedOrb)
                        InfoRow(title: "Naturaleza", value: aspect.type.nature.rawValue)
                        InfoRow(title: "Dirección", value: aspect.applying ? "Aplicando" : "Separando")
                        
                        Divider()
                        
                        Text("Descripción")
                            .font(.headline)
                        
                        Text(aspectDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Detalle del Aspecto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var aspectColor: Color {
        switch aspect.type.nature {
        case .harmonious:
            return .green
        case .challenging:
            return .red
        case .neutral:
            return .gray
        }
    }
    
    private var aspectDescription: String {
        switch aspect.type {
        case .conjunction:
            return "La conjunción representa una unión o fusión de energías. Los dos planetas actúan juntos, potenciando o modificando sus efectos mutuos."
        case .sextile:
            return "El sextil es un aspecto armonioso de 60° que indica oportunidades, facilidad de comunicación y cooperación entre los planetas."
        case .square:
            return "La cuadratura es un aspecto desafiante de 90° que crea tensión, conflicto interno y la necesidad de acción y cambio."
        case .trine:
            return "El trígono es el aspecto más armonioso de 120°, indicando flujo natural de energía, talentos innatos y buena fortuna."
        case .opposition:
            return "La oposición de 180° representa polaridad, confrontación y la necesidad de encontrar equilibrio entre energías opuestas."
        case .quincunx:
            return "El quincuncio de 150° indica ajustes necesarios, incomodidad y la necesidad de adaptación entre energías incompatibles."
        case .semisextile:
            return "El semisextil de 30° es un aspecto menor que indica oportunidades sutiles y conexiones leves."
        case .semisquare:
            return "La semicuadratura de 45° es un aspecto menor de fricción que crea irritación menor y la necesidad de ajustes."
        case .sesquiquadrate:
            return "La sesquicuadratura de 135° es un aspecto menor de tensión que indica obstáculos menores y la necesidad de perseverancia."
        }
    }
}

struct PlanetDetailCircle: View {
    let planet: PlanetType
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(planetColor.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Text(planet.symbol)
                    .font(.system(size: 36))
                    .foregroundColor(planetColor)
            }
            
            Text(planet.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var planetColor: Color {
        switch planet {
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
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

extension Aspect: Identifiable {
    // Already has id from UUID
}
