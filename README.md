# 🌱 EcoRuta: Reciclaje Colaborativo

> Aplicación móvil que conecta vecinos con recicladores locales mediante geolocalización en tiempo real, optimizando la recolección de materiales reciclables y reduciendo la acumulación de residuos en los hogares.

---

## 📋 Descripción

**EcoRuta** es una app móvil multiplataforma (Android e iOS) que permite a los **vecinos** publicar la ubicación y fotografía de sus materiales reciclables, y a los **recicladores informales** visualizarlos en un mapa interactivo para optimizar sus rutas de recolección.

El sistema incluye un módulo de gamificación (puntos e insignias) para motivar la participación continua de los vecinos y genera datos de impacto ambiental para municipalidades y ONGs.

Este repositorio corresponde al **MVP v1.0** desarrollado como proyecto final del curso **Seminario de Proyecto II (ISW-411)** — UAPA 2026.

---

## ⚙️ Stack Tecnológico

| Componente             | Tecnología                                          |
|------------------------|-----------------------------------------------------|
| Framework móvil        | **Flutter 3.x** (Dart) — Android 8.0+ / iOS 13+    |
| Autenticación          | **Firebase Auth**                                   |
| Base de datos          | **Firebase Firestore** (NoSQL en tiempo real)       |
| Almacenamiento         | **Firebase Storage** (imágenes de residuos)         |
| Notificaciones push    | **Firebase Cloud Messaging (FCM)**                  |
| Mapas                  | **Google Maps SDK** (flutter: google_maps_flutter)  |
| Gestión de estado      | **flutter_bloc 8.x** (patrón BLoC)                  |
| Diseño UI              | **Figma** + Material Design 3                       |
| Control de versiones   | **GitHub** (branches por funcionalidad)             |
| Gestión de tareas      | **Trello** (backlog y sprints)                      |

---

## 👥 Integrantes del Equipo — SAAB Software Devs

| Nombre           | Rol                                          | Capa principal       |
|------------------|----------------------------------------------|----------------------|
| Abrahan Corona   | Líder del Proyecto / Desarrollador UI        | Presentation (BLoC + Pages) |
| Samuel Vargas    | Analista Funcional / Desarrollador Backend   | Data + Domain (Firebase + Casos de uso) |

**Facilitador:** Joan Gregorio Pérez 
**Curso:** Seminario de Proyecto II — ISW-411 — UAPA 2026

---

## 🏗️ Arquitectura — Clean Architecture + BLoC

El proyecto implementa **Clean Architecture** con cuatro capas bien definidas:

```
REGLA DE DEPENDENCIA: Las capas internas NO conocen las capas externas.
```

```
┌─────────────────────────────────────────────────────┐
│           PRESENTATION LAYER                        │
│   Flutter UI  ·  BLoC  ·  Pages  ·  Widgets        │
└──────────────────────┬──────────────────────────────┘
                       │ eventos / estados
┌──────────────────────▼──────────────────────────────┐
│              DOMAIN LAYER                           │
│   Entities  ·  Use Cases  ·  Repository Interfaces  │
│   (Dart puro — sin dependencias externas)           │
└──────────────────────┬──────────────────────────────┘
                       │ contratos (interfaces)
┌──────────────────────▼──────────────────────────────┐
│               DATA LAYER                            │
│   DataSources  ·  Models (DTO)  ·  Repositories    │
│   Firebase Firestore  ·  Auth  ·  Storage  ·  FCM  │
└──────────────────────┬──────────────────────────────┘
                       │ SDK / HTTPS / WebSocket
┌──────────────────────▼──────────────────────────────┐
│            FIREBASE SERVICES + Google Maps          │
└─────────────────────────────────────────────────────┘
         ↕ (transversal a todas las capas)
┌─────────────────────────────────────────────────────┐
│                   CORE                              │
│          Constants  ·  Errors  ·  Utils             │
└─────────────────────────────────────────────────────┘
```

### Estructura de carpetas

```
ecoruta/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   └── utils/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── presentation/
│       ├── bloc/
│       ├── pages/
│       └── widgets/
├── assets/
│   ├── images/
│   └── icons/
├── test/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Funcionalidades del MVP v1.0

- **F-01** — Gestión de Perfiles y Autenticación (registro, login, recuperación de contraseña)
- **F-02** — Módulo de Reporte de Residuos (formulario + foto + GPS)
- **F-03** — Geolocalización y Mapa de Reportes Activos (solo recicladores validados)
- **F-04** — Gestión del Estado de Recolección (Pendiente → Recogido)
- **F-05** — Módulo de Gamificación y Perfil de Impacto (puntos, insignias)

> **Fuera del MVP v1.0:** Cálculo de CO₂ equivalente (RF-15), pagos monetarios, chat, dashboard web administrativo.

---

## ▶️ Cómo ejecutar el proyecto

```bash
# 1. Clonar el repositorio
git clone https://github.com/samuelvargas013/ecoruta1.git
cd ecoruta

# 2. Instalar dependencias
flutter pub get

# 3. Configurar Firebase
#    - Crear proyecto en Firebase Console
#    - Activar: Auth, Firestore, Storage, FCM
#    - Descargar google-services.json (Android) y GoogleService-Info.plist (iOS)
#    - Colocarlos en android/app/ e ios/Runner/ respectivamente

# 4. Ejecutar
flutter run
```

**Requisitos:** Flutter 3.19+, Dart 3.x, Android SDK 21+ / Xcode 14+

---

## 📌 Commit inicial

```
git commit -m "Configura estructura del proyecto posterior a clinica tecnica Semana 4"
```

---

## 📄 Documentos del proyecto

| Documento                            | Descripción                                  |
|--------------------------------------|----------------------------------------------|
| `SRS_EcoRuta_v1_1.docx`             | Documento de Requerimientos de Software      |
| `Ficha_Clinica_Tecnica_Semana3.docx`| Ficha de la Clínica Técnica — Semana 3       |
| `Arquitectura_EcoRuta_Semana3.docx` | Documento de Arquitectura (patrón + capas)   |

---

*SAAB Software Devs — 2026 — ISW-411 UAPA*