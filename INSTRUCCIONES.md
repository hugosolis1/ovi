# 🪐 Instrucciones - AstrologyApp

## 📱 Características de la App

Esta aplicación iOS calcula posiciones planetarias exactas y muestra cartas astrales usando efemérides astronómicas reales.

### ✨ Funcionalidades

1. **📅 Selección de Fecha y Hora**
   - Selector de fecha completo
   - Selector de hora y minutos
   - Botón "Usar hora actual"

2. **🌍 Zona Horaria (UTC)**
   - Rueda de selección de offset UTC (de -12 a +14)
   - Botón rápido para Greenwich UTC+0
   - Presets para ciudades principales

3. **📍 Coordenadas**
   - Sliders para latitud (-90° a +90°)
   - Sliders para longitud (-180° a +180°)
   - Greenwich, Londres por defecto: 51.4769°N, 0.0005°W
   - Presets para: Nueva York, Madrid, Ciudad de México

4. **☀️/🌍 Modos de Cálculo**
   - **Geocéntrico**: Posiciones desde la Tierra
   - **Heliocéntrico**: Posiciones desde el Sol

5. **🌟 Posiciones Planetarias**
   - Sol, Luna, Mercurio, Venus, Marte, Júpiter, Saturno, Urano, Neptuno, Plutón
   - Nodos Lunares (Norte y Sur)
   - Longitud exacta en grados 0-360°
   - Signo zodiacal
   - Velocidad y dirección (retrógrado/directo)
   - Distancia en UA

6. **🎯 Carta Astral Visual**
   - Rueda zodiacal interactiva
   - 12 casas astrológicas (sistema Placidus)
   - Aspectos planetarios visuales
   - Zoom con gestos
   - Información detallada al tocar planetas

7. **⚡ Aspectos Planetarios**
   - Conjunciones (0°)
   - Sextiles (60°)
   - Cuadraturas (90°)
   - Trígonos (120°)
   - Oposiciones (180°)
   - Aspectos menores opcionales

## 🔬 Precisión Astronómica

| Cuerpo | Algoritmo | Precisión |
|--------|-----------|-----------|
| Sol | VSOP87 simplificada | ~1 arcsec |
| Luna | ELP2000-82 extendida | ~2 arcsec |
| Planetas | VSOP87 | ~5 arcsec |
| Nodos | Fórmula del nodo medio | ~1 arcmin |

## 🚀 Pasos para Compilar

### 1. Subir a GitHub

```bash
# En tu computadora local
git init
git add .
git commit -m "Initial commit - AstrologyApp"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
git push -u origin main
```

### 2. Configurar CodeMagic

1. Ve a [codemagic.io](https://codemagic.io)
2. Inicia sesión con tu cuenta de GitHub
3. Haz clic en "Add Application"
4. Selecciona tu repositorio `AstrologyApp`
5. CodeMagic detectará automáticamente el archivo `codemagic.yaml`
6. Configura el workflow:
   - **Workflow name**: `ios-build`
   - **Instance type**: `mac_mini_m1`
   - **Xcode version**: `15.2`

### 3. Ejecutar Build

1. En CodeMagic, selecciona el workflow `ios-build`
2. Haz clic en "Start new build"
3. Espera a que termine (aproximadamente 5-10 minutos)
4. Descarga el archivo `.ipa` generado

### 4. Instalar en iOS 15.8.2

#### Opción A: AltStore (Recomendado)
1. Instala AltStore en tu computadora y iPhone
2. Conecta tu iPhone por USB
3. En AltStore, selecciona "My Apps"
4. Toca "+" y selecciona el archivo `.ipa`
5. Ingresa tu Apple ID cuando se solicite

#### Opción B: Sideloadly
1. Descarga Sideloadly desde [iosgods.com](https://iosgods.com)
2. Conecta tu iPhone por USB
3. Arrastra el `.ipa` a Sideloadly
4. Ingresa tu Apple ID
5. Haz clic en "Start"

#### Opción C: TrollStore (si tienes iOS 15.0-15.8.2 compatible)
1. Instala TrollStore
2. Comparte el `.ipa` a TrollStore
3. La app se instalará permanentemente

## 📁 Estructura del Proyecto

```
AstrologyApp/
├── codemagic.yaml              # Configuración de CodeMagic
├── exportOptions.plist         # Opciones de exportación
├── README.md                   # Documentación
├── INSTRUCCIONES.md           # Este archivo
└── PlanetaryPositions.xcodeproj/  # Proyecto Xcode
└── PlanetaryPositions/
    ├── PlanetaryPositionsApp.swift
    ├── Info.plist
    ├── Assets.xcassets/
    ├── Preview Content/
    ├── Views/
    │   ├── ContentView.swift
    │   ├── PlanetPositionsView.swift
    │   ├── AstrologyChartView.swift
    │   └── AspectsView.swift
    ├── Models/
    │   ├── Planet.swift
    │   ├── ZodiacSign.swift
    │   ├── House.swift
    │   ├── Aspect.swift
    │   └── ChartData.swift
    └── Engine/
        ├── SwissEphemerisEngine.swift
        ├── VSOP87Calculator.swift
        ├── ELP2000Calculator.swift
        └── HouseCalculator.swift
```

## 🛠️ Compilar Localmente (Opcional)

Si tienes Mac con Xcode:

```bash
# Abrir proyecto
open PlanetaryPositions.xcodeproj

# O compilar por línea de comandos
xcodebuild -project PlanetaryPositions.xcodeproj \
  -scheme PlanetaryPositions \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  clean build
```

## 📝 Notas Importantes

1. **iOS 15.8.2**: La app está configurada con `IPHONEOS_DEPLOYMENT_TARGET = 15.8`
2. **Sin firma**: El `.ipa` generado es **unsigned**, necesitarás herramientas como AltStore para instalarlo
3. **Efemérides**: Los cálculos usan VSOP87 y ELP2000, son precisos para fechas entre 1900-2100
4. **No requiere internet**: Todos los cálculos son locales

## 🐛 Solución de Problemas

### Error "Unable to install"
- Asegúrate de que tu Apple ID no tenga 2FA (o usa app-specific password)
- Revisa que el dispositivo esté conectado por USB
- Intenta reiniciar AltStore/Sideloadly

### Error en CodeMagic
- Verifica que el archivo `codemagic.yaml` esté en la raíz del repositorio
- Asegúrate de que el proyecto Xcode se abre correctamente en Xcode local

### Cálculos incorrectos
- Verifica que la zona horaria (UTC) sea correcta
- Para máxima precisión, usa coordenadas exactas del lugar de nacimiento

## 📧 Soporte

Si encuentras problemas:
1. Revisa que todos los archivos estén en el repositorio
2. Verifica la versión de Xcode en CodeMagic (15.2 recomendado)
3. Consulta los logs de compilación en CodeMagic

---

**Versión**: 1.0  
**Fecha**: 2025  
**Compatible con**: iOS 15.8.2+
