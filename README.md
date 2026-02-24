# SiembraIA 🌱

**App móvil de monitoreo agrícola inteligente** — Flutter + Firebase + OpenWeather + IA basada en reglas.

---

## Tabla de contenidos

1. [Descripción](#descripción)
2. [Stack tecnológico](#stack-tecnológico)
3. [Arquitectura](#arquitectura)
4. [Funcionalidades](#funcionalidades)
5. [Configuración del proyecto](#configuración-del-proyecto)
6. [Variables de entorno](#variables-de-entorno)
7. [Firebase Setup](#firebase-setup)
8. [Estructura de carpetas](#estructura-de-carpetas)
9. [Modelo de datos Firestore](#modelo-de-datos-firestore)
10. [Motor de IA (Rule-based MVP)](#motor-de-ia-rule-based-mvp)
11. [Ejecutar el proyecto](#ejecutar-el-proyecto)
12. [Tests](#tests)
13. [Datos de ejemplo (seed)](#datos-de-ejemplo-seed)

---

## Descripción

SiembraIA ayuda a agricultores e ingenieros agrónomos a:

- Registrar y monitorear **parcelas** con cultivos, variedades y ubicación.
- Registrar **visitas de campo** (altura de planta, humedad de suelo, plagas, etapa fenológica).
- Subir **fotos** desde cámara o galería a Firebase Storage.
- Recibir **alertas inteligentes** basadas en condiciones del campo y pronóstico climático.
- Consultar el **clima actual y pronóstico 48 h** via OpenWeather API.
- Ver **gráficas** de evolución de altura y humedad por parcela.

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter 3 / Dart 3 |
| Autenticación | Firebase Auth (Email/Password) |
| Base de datos | Cloud Firestore |
| Almacenamiento | Firebase Storage |
| Estado | Riverpod 2 |
| Navegación | go_router 14 |
| Clima | OpenWeather API v2.5 |
| Gráficas | fl_chart |
| Imágenes | image_picker + cached_network_image |

---

## Arquitectura

```
lib/
├── main.dart                   # Entry point, Firebase init, ProviderScope
├── models/                     # Modelos de datos (UserModel, FarmModel, PlotModel, VisitModel, PhotoModel, WeatherModel, AlertModel)
├── services/                   # Lógica de negocio (AuthService, WeatherService, StorageService, IAEngine)
├── repositories/               # Acceso a Firestore (FarmRepository, PlotRepository, VisitRepository, PhotoRepository)
├── state/                      # Riverpod providers (providers.dart, auth_state.dart, farm_state.dart)
├── ui/
│   ├── screens/                # Pantallas de la app
│   └── widgets/                # Widgets reutilizables
└── utils/                      # Constantes, tema, router, helpers
```

### Patrón limpio

```
UI (screens) → State (Riverpod providers) → Repository → Firestore/Storage
                      ↓
                  Services (Auth, Weather, IA)
```

---

## Funcionalidades

### Autenticación
- ✅ Registro con email/contraseña
- ✅ Inicio de sesión
- ✅ Cierre de sesión
- ✅ Perfil: nombre, rol (Agricultor / Ingeniero Agrónomo), región

### Parcelas
- ✅ Lista con búsqueda
- ✅ Crear / editar parcela (nombre, cultivo, variedad, superficie, coordenadas GPS)
- ✅ Detalle de parcela con historial de visitas
- ✅ Gráfica de altura de planta vs tiempo
- ✅ Gráfica de humedad del suelo vs tiempo

### Visitas de campo
- ✅ Formulario rápido con sliders (altura planta, humedad suelo)
- ✅ Toggle de plaga + slider de severidad (0–5)
- ✅ Etapa fenológica (germinación → cosecha)
- ✅ Observaciones y notas libres

### Fotos
- ✅ Cámara o galería
- ✅ Subida a Firebase Storage con URL persistente
- ✅ Grid de fotos en detalle de visita

### Alertas IA
- ✅ Motor de reglas en Dart (sin modelo ML)
- ✅ 4 reglas implementadas (hídrica, hongos, plaga, calor)
- ✅ Severidad: Baja / Media / Alta
- ✅ Interfaz abstracta `IAEngine` lista para sustituir por LLM

### Clima
- ✅ Clima actual (temperatura, humedad, viento)
- ✅ Pronóstico 48 h (probabilidad de lluvia, temperatura máxima)
- ✅ Cache de 30 minutos via SharedPreferences

---

## Configuración del proyecto

### Requisitos previos

- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Cuenta Firebase (gratuita)
- API Key de OpenWeather (gratuita en [openweathermap.org](https://openweathermap.org/api))

### Instalación

```bash
git clone https://github.com/morenoj529/SiembraIA.git
cd SiembraIA
flutter pub get
```

---

## Variables de entorno

La API Key de OpenWeather se pasa via `--dart-define` para no comprometer el secreto en el código fuente:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=tu_clave_aqui
```

Para **build release**:

```bash
flutter build apk --dart-define=OPENWEATHER_API_KEY=tu_clave_aqui
```

---

## Firebase Setup

### 1. Crear proyecto Firebase

1. Ve a [console.firebase.google.com](https://console.firebase.google.com)
2. Crea un nuevo proyecto llamado `SiembraIA`
3. Habilita **Authentication → Email/Password**
4. Crea la base de datos **Firestore** (modo producción)
5. Habilita **Firebase Storage**

### 2. Agregar app Android

1. En Firebase Console → `Agregar app → Android`
2. Nombre del paquete: `com.siembra_ia.app` (o el que uses)
3. Descarga `google-services.json`
4. Colócalo en `android/app/google-services.json`

### 3. Agregar app iOS

1. En Firebase Console → `Agregar app → iOS`
2. Bundle ID: `com.siembra-ia.app`
3. Descarga `GoogleService-Info.plist`
4. Colócalo en `ios/Runner/GoogleService-Info.plist`

### 4. Desplegar reglas de seguridad

```bash
# Instala Firebase CLI si no la tienes
npm install -g firebase-tools
firebase login
firebase use --add  # selecciona tu proyecto

# Despliega reglas de Firestore
firebase deploy --only firestore:rules

# Despliega índices de Firestore
firebase deploy --only firestore:indexes

# Despliega reglas de Storage
firebase deploy --only storage
```

### 5. Archivos de configuración Firebase

> ⚠️ **Estos archivos NO se incluyen en el repositorio por seguridad.**

| Archivo | Destino |
|---|---|
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

---

## Estructura de carpetas

```
SiembraIA/
├── android/
│   └── app/
│       ├── src/main/AndroidManifest.xml
│       └── src/main/res/xml/file_paths.xml
├── ios/
│   └── Runner/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── farm_model.dart
│   │   ├── plot_model.dart
│   │   ├── visit_model.dart
│   │   ├── photo_model.dart
│   │   ├── weather_model.dart
│   │   └── alert_model.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── weather_service.dart
│   │   ├── storage_service.dart
│   │   └── ia_engine.dart          ← Motor IA (rule-based MVP + interfaz abstracta)
│   ├── repositories/
│   │   ├── farm_repository.dart
│   │   ├── plot_repository.dart
│   │   ├── visit_repository.dart
│   │   └── photo_repository.dart
│   ├── state/
│   │   ├── providers.dart          ← Providers de servicios y repos
│   │   ├── auth_state.dart         ← Estado de autenticación
│   │   └── farm_state.dart         ← Farms, plots, alerts
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── plots_screen.dart
│   │   │   ├── plot_detail_screen.dart
│   │   │   ├── edit_plot_screen.dart
│   │   │   ├── new_visit_screen.dart
│   │   │   ├── visit_detail_screen.dart
│   │   │   ├── alerts_screen.dart
│   │   │   └── profile_screen.dart
│   │   └── widgets/
│   │       ├── common_widgets.dart
│   │       └── alert_card.dart
│   └── utils/
│       ├── app_theme.dart
│       ├── constants.dart
│       ├── helpers.dart
│       └── router.dart
├── test/
│   └── ia_engine_test.dart         ← Tests del motor de IA
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
└── pubspec.yaml
```

---

## Modelo de datos Firestore

### `users/{uid}`
```json
{
  "email": "string",
  "nombre": "string",
  "rol": "agricultor | ingeniero",
  "region": "string",
  "createdAt": "timestamp"
}
```

### `farms/{farmId}`
```json
{
  "nombre": "string",
  "ownerId": "uid",
  "ubicacionGeneral": "string",
  "colaboradores": ["uid"],
  "createdAt": "timestamp"
}
```

### `plots/{plotId}`
```json
{
  "farmId": "string",
  "nombre": "string",
  "cultivo": "string",
  "variedad": "string",
  "superficieHa": 5.0,
  "geoPoint": { "lat": 25.7964, "lon": -109.0214 },
  "ownerId": "uid",
  "createdAt": "timestamp"
}
```

### `visits/{visitId}`
```json
{
  "plotId": "string",
  "fechaHora": "timestamp",
  "observaciones": "string",
  "etapaFenologica": "vegetativo | floracion | ...",
  "alturaPlantaCm": 80.0,
  "humedadSueloPct": 45.0,
  "plagaPresente": false,
  "severidadPlaga": 0,
  "notas": "string",
  "createdBy": "uid",
  "createdAt": "timestamp"
}
```

### `photos/{photoId}`
```json
{
  "visitId": "string",
  "urlStorage": "https://...",
  "labels": ["string"],
  "createdAt": "timestamp"
}
```

---

## Motor de IA (Rule-based MVP)

Implementado en `lib/services/ia_engine.dart`.

| # | Condición | Alerta | Severidad |
|---|---|---|---|
| 1 | `humedadSuelo < 25%` AND sin lluvia 48h | Riesgo hídrico | Alta |
| 2 | `humedadAire > 70%` AND `temp 20–30°C` AND lluvia próxima | Riesgo de hongos | Media |
| 3 | `plagaPresente` AND `severidad >= 3` | Revisar control de plaga | Media/Alta |
| 4 | `tempMax > 36°C` | Golpe de calor | Alta |

### Extensión futura

La interfaz abstracta `IAEngine` permite sustituir `RuleBasedEngine` por un LLM o modelo ML sin cambiar el resto de la app:

```dart
// Para sustituir por LLM, crea una nueva implementación:
class LLMEngine implements IAEngine {
  @override
  Future<List<AlertModel>> generateAlerts({...}) async {
    // Llamada a API de LLM / modelo
  }
}

// Y cambia el provider:
final iaEngineProvider = Provider<IAEngine>((_) => LLMEngine());
```

---

## Ejecutar el proyecto

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Asegúrate de tener google-services.json en android/app/
# 3. Ejecutar en modo debug con la API key de OpenWeather
flutter run --dart-define=OPENWEATHER_API_KEY=tu_clave

# 4. Build release Android
flutter build apk --dart-define=OPENWEATHER_API_KEY=tu_clave

# 5. Build release iOS
flutter build ipa --dart-define=OPENWEATHER_API_KEY=tu_clave
```

---

## Tests

```bash
flutter test
```

Los tests unitarios cubren el motor de IA (`test/ia_engine_test.dart`):

- ✅ Regla hídrica (humedad baja sin lluvia)
- ✅ Regla hongos (humedad alta + temperatura + lluvia)
- ✅ Regla plaga (con distintos niveles de severidad)
- ✅ Regla calor (temperatura máxima)
- ✅ Sin visita → sin alertas
- ✅ Helpers `WeatherForecast.hasRainIn` y `maxTempIn`

---

## Datos de ejemplo (seed)

Para poblar Firestore con datos de prueba, puedes ejecutar en la consola de Firebase o via script:

```js
// Ejemplo de plot en Los Mochis
db.collection('plots').add({
  farmId: '',
  nombre: 'Parcela Norte',
  cultivo: 'Maíz',
  variedad: 'Híbrido DK-357',
  superficieHa: 5.5,
  geoPoint: new GeoPoint(25.7964, -109.0214),
  ownerId: '<tu-uid>',
  createdAt: new Date()
});

// Visita con condiciones de alerta
db.collection('visits').add({
  plotId: '<plotId>',
  fechaHora: new Date(),
  observaciones: 'Suelo seco, pocas lluvias este mes',
  etapaFenologica: 'vegetativo',
  alturaPlantaCm: 65,
  humedadSueloPct: 18,   // < 25 → alerta hídrica
  plagaPresente: true,
  severidadPlaga: 4,     // >= 3 → alerta plaga
  notas: 'Se observan insectos en hojas',
  createdBy: '<tu-uid>',
  createdAt: new Date()
});
```

---

## Licencia

MIT © 2024 SiembraIA Team
