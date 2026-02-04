# Yalitza Salas - Aplicación Móvil de Gestión de Estética

Aplicación móvil Flutter 100% offline-first para la gestión de clínica de estética, basada en el dashboard web de Yalitza Salas.

## Características Principales

### 📊 Dashboard
- Tarjetas de estadísticas en tiempo real (Total Clientes, Servicios Activos, Citas de Hoy, Completadas Hoy)
- Resumen financiero mensual (Ingresos, Costos, Ganancias)
- Lista de citas programadas para el día actual

### 👥 Gestión de Clientes
- CRUD completo de clientes
- Búsqueda por nombre
- Información detallada (nombre, teléfono, email, fecha de registro)
- Confirmación de eliminación con diálogo

### 📅 Gestión de Citas
- Calendario mensual interactivo
- Creación y edición de citas
- Estados de cita (Programada, Completada, Cancelada)
- Selección de cliente y servicio desde base de datos local

### 💆 Servicios
- Catálogo de servicios con precios y duración
- Categorización de servicios
- CRUD completo de servicios

### 📦 Gestión de Suministros
- Control de inventario
- Alertas de bajo stock
- Costos unitarios y stock mínimo/máximo
- Múltiples unidades de medida

### 💰 Administración
- Resumen financiero detallado
- Historial de citas completadas
- Cálculo automático de ganancias

## Arquitectura Técnica

### Base de Datos Local
- **Drift (SQLite)**: Base de datos relacional local
- **Persistencia permanente**: Los datos se guardan localmente
- **100% Offline**: No requiere conexión a internet

### Estructura del Proyecto
```
lib/
├── data/
│   └── database/
│       ├── app_database.dart      # Configuración principal de Drift
│       └── tables.dart            # Definición de entidades
├── presentation/
│   ├── app/
│   │   └── app.dart               # Navegación principal
│   ├── theme/
│   │   └── app_theme.dart         # Tema y colores
│   ├── bloc/
│   │   └── database/              # Gestión de estado
│   ├── screens/                  # Pantallas principales
│   │   ├── dashboard/
│   │   ├── clients/
│   │   ├── appointments/
│   │   ├── services/
│   │   ├── supplies/
│   │   └── administration/
│   └── widgets/                   # Componentes reutilizables
│       ├── common/
│       ├── dashboard/
│       ├── clients/
│       ├── appointments/
│       ├── services/
│       ├── supplies/
│       └── administration/
└── main.dart
```

### Entidades de Base de Datos

#### Client
- id (PK)
- name (String)
- phone (String?)
- email (String?)
- createdAt (DateTime)

#### Service
- id (PK)
- name (String)
- description (String?)
- price (double)
- duration (int) // minutos
- category (String)
- createdAt (DateTime)

#### Supply
- id (PK)
- name (String)
- unitCost (double)
- unit (String) // kg, ml, unidades, etc.
- currentStock (double)
- minimumStock (double)
- createdAt (DateTime)

#### Appointment
- id (PK)
- clientId (FK)
- serviceId (FK)
- dateTime (DateTime)
- status (String) // scheduled, completed, canceled
- amount (double)
- createdAt (DateTime)
- updatedAt (DateTime)

#### ServiceSupply (Many-to-Many)
- serviceId (FK)
- supplyId (FK)
- quantity (double)

## Instalación y Configuración

### Prerrequisitos
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Pasos de Instalación

1. **Clonar el proyecto**
```bash
git clone <repository-url>
cd yalitza-salas-bloom-mobile
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar código de Drift**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Ejecutar la aplicación**
```bash
flutter run
```

## Tema y Diseño

### Colores
- **Primario**: Morado (#9C27B0)
- **Secundario**: Rosa (#E91E63)
- **Éxito**: Verde (#4CAF50)
- **Error**: Rojo (#F44336)
- **Advertencia**: Naranja (#FF9800)
- **Fondo**: Blanco (#FFFFFF)

### Componentes UI
- Tarjetas con sombras suaves y bordes redondeados
- Navegación inferior con 6 secciones principales
- Diálogos de confirmación para acciones destructivas
- Indicadores visuales de estado (color coding)

## Funcionalidades de Seguridad

### Confirmación de Eliminación
Todas las acciones de eliminación muestran un diálogo de confirmación:
```dart
await ConfirmationDialog.show(
  context: context,
  title: 'Eliminar Elemento',
  content: '¿Estás seguro de eliminar este elemento?',
);
```

### Validación de Datos
- Campos requeridos en formularios
- Validación de formatos (email, números)
- Manejo de errores con feedback visual

## Estado de la Aplicación

### Gestión de Estado
- **BLoC Pattern** para gestión de estado
- **Repository Pattern** para acceso a datos
- **Streams reactivos** con Drift

### Actualización en Tiempo Real
- Los cambios en la base de datos se reflejan inmediatamente
- RefreshIndicator para actualización manual
- Snackbars para feedback de acciones

## Notas Importantes

### Base de Datos Local
- La aplicación funciona completamente offline
- Los datos se persisten en el dispositivo
- No hay conexión a servicios externos (Supabase, etc.)

### Rendimiento
- Lazy loading de datos
- Widgets optimizados para listas largas
- Gestión eficiente de memoria

### Extensibilidad
- Arquitectura modular para fácil mantenimiento
- Componentes reutilizables
- Separación clara de responsabilidades

## Licencia

Proyecto desarrollado para Yalitza Salas - Gestión de Estética.
