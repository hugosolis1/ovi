import SwiftUI

struct ContentView: View {
    @StateObject private var engine = SwissEphemerisEngine.shared
    @State private var selectedDate = Date()
    @State private var utcOffset = 0
    @State private var latitude = 51.4769
    @State private var longitude = -0.0005
    @State private var calculationMode: CalculationMode = .geocentric
    @State private var chartData: ChartData?
    @State private var selectedTab = 0
    @State private var showDatePicker = false
    
    private let utcOffsets = Array(-12...14)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Date & Settings
            settingsView
                .tabItem {
                    Label("Configuración", systemImage: "gear")
                }
                .tag(0)
            
            // Tab 2: Planet Positions
            PlanetPositionsView(chartData: chartData)
                .tabItem {
                    Label("Planetas", systemImage: "sparkles")
                }
                .tag(1)
            
            // Tab 3: Astrology Chart
            AstrologyChartView(chartData: chartData)
                .tabItem {
                    Label("Carta Astral", systemImage: "circle.dashed")
                }
                .tag(2)
            
            // Tab 4: Aspects
            AspectsView(chartData: chartData)
                .tabItem {
                    Label("Aspectos", systemImage: "line.3.crossed.swirl.circle")
                }
                .tag(3)
        }
        .accentColor(.purple)
        .onAppear {
            calculateChart()
        }
    }
    
    private var settingsView: some View {
        NavigationView {
            Form {
                Section(header: Text("Fecha y Hora")) {
                    DatePicker(
                        "Fecha y Hora",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphite)
                    .environment(\.locale, Locale(identifier: "es_ES"))
                    
                    Button(action: {
                        selectedDate = Date()
                        calculateChart()
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Usar hora actual")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Zona Horaria (UTC)")) {
                    Picker("Offset UTC", selection: $utcOffset) {
                        ForEach(utcOffsets, id: \.self) { offset in
                            Text(formatUTCOffset(offset)).tag(offset)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    
                    Button("Greenwich (UTC+0)") {
                        utcOffset = 0
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("Coordenadas")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Latitud:")
                                .frame(width: 70, alignment: .leading)
                            Slider(value: $latitude, in: -90...90, step: 0.0001)
                            Text(String(format: "%.4f°", latitude))
                                .monospacedDigit()
                                .frame(width: 80)
                        }
                        
                        HStack {
                            Text("Longitud:")
                                .frame(width: 70, alignment: .leading)
                            Slider(value: $longitude, in: -180...180, step: 0.0001)
                            Text(String(format: "%.4f°", longitude))
                                .monospacedDigit()
                                .frame(width: 80)
                        }
                    }
                    
                    Button("Greenwich, Londres") {
                        latitude = 51.4769
                        longitude = -0.0005
                    }
                    .foregroundColor(.blue)
                    
                    Button("Nueva York") {
                        latitude = 40.7128
                        longitude = -74.0060
                        utcOffset = -5
                    }
                    .foregroundColor(.blue)
                    
                    Button("Madrid") {
                        latitude = 40.4168
                        longitude = -3.7038
                        utcOffset = 1
                    }
                    .foregroundColor(.blue)
                    
                    Button("Ciudad de México") {
                        latitude = 19.4326
                        longitude = -99.1332
                        utcOffset = -6
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("Modo de Cálculo")) {
                    Picker("Modo", selection: $calculationMode) {
                        ForEach(CalculationMode.allCases) { mode in
                            HStack {
                                Image(systemName: mode.icon)
                                Text(mode.rawValue)
                            }
                            .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button(action: calculateChart) {
                        HStack {
                            Spacer()
                            if engine.isCalculating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Calcular Carta")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                    }
                    .disabled(engine.isCalculating)
                }
                
                if let chart = chartData {
                    Section(header: Text("Información de la Carta")) {
                        HStack {
                            Text("Fecha:")
                            Spacer()
                            Text(chart.formattedDate)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("UTC:")
                            Spacer()
                            Text(chart.formattedUTC)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Ubicación:")
                            Spacer()
                            Text(chart.formattedCoordinates)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Modo:")
                            Spacer()
                            Text(chart.calculationMode.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        if let houses = chart.houseSystem {
                            HStack {
                                Text("Ascendente:")
                                Spacer()
                                Text(houses.ascendantSign.symbol)
                                    .foregroundColor(.purple)
                                + Text(" ")
                                + Text(String(format: "%.2f°", houses.ascendant))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("MC:")
                                Spacer()
                                Text(houses.midheavenSign.symbol)
                                    .foregroundColor(.purple)
                                + Text(" ")
                                + Text(String(format: "%.2f°", houses.midheaven))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("JD:")
                            Spacer()
                            Text(String(format: "%.6f", chart.julianDay))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Tiempo de cálculo:")
                            Spacer()
                            Text(String(format: "%.3f ms", engine.lastCalculationTime * 1000))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Configuración")
        }
    }
    
    private func calculateChart() {
        chartData = engine.calculateChart(
            date: selectedDate,
            utcOffset: utcOffset,
            latitude: latitude,
            longitude: longitude,
            mode: calculationMode
        )
    }
    
    private func formatUTCOffset(_ offset: Int) -> String {
        if offset >= 0 {
            return "UTC+\(offset)"
        } else {
            return "UTC\(offset)"
        }
    }
}

// MARK: - Date Picker Style Extension

extension View {
    func datePickerStyle(_ style: some DatePickerStyle) -> some View {
        self.datePickerStyle(style)
    }
}

struct GraphiteDatePickerStyle: DatePickerStyle {
    func makeBody(configuration: Configuration) -> some View {
        DatePicker(configuration)
            .labelsHidden()
    }
}

extension DatePickerStyle where Self == GraphiteDatePickerStyle {
    static var graphite: GraphiteDatePickerStyle {
        GraphiteDatePickerStyle()
    }
}
