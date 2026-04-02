# 🪐 AstrologyApp - Posiciones Planetarias y Carta Astral

Aplicación iOS nativa construida con SwiftUI para calcular y visualizar posiciones planetarias reales y cartas astrales con alta precisión astronómica.

## ✨ Características

- **📅 Selección de Fecha y Hora**: Elige cualquier fecha, hora y minuto
- **🌍 UTC Ajustable**: Modifica el offset UTC para cualquier zona horaria
- **📍 Coordenadas de Greenwich**: Usa Greenwich, Londres por defecto (51.4769°N, 0.0005°W)
- **🌟 Posiciones Planetarias Exactas**: Cálculos usando efemérides VSOP87 y ELP2000
- **☀️/🌍 Heliocéntrico/Geocéntrico**: Cambia entre vista desde el Sol o desde la Tierra
- **🎯 Carta Astral Visual**: Rueda zodiacal interactiva con posiciones planetarias
- **🏠 Casas Astrológicas**: Cálculo de las 12 casas
- **⚡ Aspectos Planetarios**: Conjunciones, oposiciones, trinos, cuadraturas, sextiles

## 🔬 Precisión Astronómica

| Cuerpo | Algoritmo | Precisión |
|--------|-----------|-----------|
| Sol | VSOP87 simplificada | ~1 arcsec |
| Luna | ELP2000-82 extendida | ~2 arcsec |
| Planetas | VSOP87 con elementos keplerianos | ~5 arcsec |
| Nodos | Fórmula del nodo medio | ~1 arcmin |

## 🚀 Compilación con CodeMagic

1. Sube este repositorio a GitHub
2. Conecta el repositorio en [CodeMagic](https://codemagic.io)
3. Ejecuta el workflow `ios-build`
4. Descarga el `.ipa` unsigned generado

## 📋 Requisitos

- iOS 15.8.2 o superior
- Xcode 15.0 o superior
- Swift 5.9 o superior

## 🛠️ Estructura del Proyecto

```
PlanetaryPositions/
├── Engine/
│   ├── SwissEphemerisEngine.swift    # Motor de cálculo astronómico
│   ├── VSOP87Calculator.swift        # Algoritmos VSOP87
│   ├── ELP2000Calculator.swift       # Algoritmos ELP2000 para la Luna
│   └── HouseCalculator.swift         # Cálculo de casas astrológicas
├── Models/
│   ├── Planet.swift                  # Modelo de planetas
│   ├── ZodiacSign.swift              # Signos zodiacales
│   ├── House.swift                   # Modelo de casas
│   ├── Aspect.swift                  # Aspectos planetarios
│   └── ChartData.swift               # Datos de la carta astral
├── Views/
│   ├── ContentView.swift             # Vista principal
│   ├── DateTimeSelectorView.swift    # Selector de fecha/hora
│   ├── PlanetPositionsView.swift     # Lista de posiciones
│   ├── AstrologyChartView.swift      # Carta astral visual
│   └── ChartWheelView.swift          # Rueda zodiacal
└── PlanetaryPositionsApp.swift       # Punto de entrada
```

## 📄 Licencia

MIT License - Libre para uso personal y comercial.
