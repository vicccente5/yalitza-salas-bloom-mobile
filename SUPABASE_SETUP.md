# 🚀 Configuración de Supabase para Yalitza Salas Bloom

## 📋 Requisitos Previos

1. **Cuenta de Supabase** - Regístrate en [supabase.com](https://supabase.com)
2. **Proyecto Flutter** - Ya configurado

## 🔧 Paso 1: Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Haz clic en **"Start your project"**
3. Inicia sesión con GitHub o Google
4. Crea un nuevo proyecto:
   - **Nombre**: `yalitza-salas-bloom`
   - **Contraseña de base de datos**: Genera una segura
   - **Región**: Elige la más cercana a tus usuarios
5. Espera a que se cree el proyecto (2-3 minutos)

## 🗄️ Paso 2: Crear Tablas en la Base de Datos

Ve a **SQL Editor** en tu proyecto Supabase y ejecuta las siguientes consultas:

### Tabla de Clientes
```sql
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_clients_name ON clients(name);
CREATE INDEX idx_clients_created_at ON clients(created_at);
```

### Tabla de Servicios
```sql
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration INTEGER NOT NULL, -- en minutos
    category VARCHAR(100) NOT NULL,
    supplies JSONB, -- array de suministros
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_services_name ON services(name);
CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_created_at ON services(created_at);
```

### Tabla de Suministros
```sql
CREATE TABLE supplies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    unit_cost DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50) NOT NULL, -- kg, ml, unidades, etc.
    current_stock DECIMAL(10,2) NOT NULL DEFAULT 0,
    minimum_stock DECIMAL(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_supplies_name ON supplies(name);
CREATE INDEX idx_supplies_created_at ON supplies(created_at);
```

### Tabla de Citas
```sql
CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    client_name VARCHAR(255) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'scheduled', -- scheduled, completed, canceled
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_appointments_date_time ON appointments(date_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_client_name ON appointments(client_name);
```

### Tabla de Citas Completadas
```sql
CREATE TABLE completed_appointments (
    id SERIAL PRIMARY KEY,
    client_name VARCHAR(255) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_completed_appointments_date_time ON completed_appointments(date_time);
CREATE INDEX idx_completed_appointments_client_name ON completed_appointments(client_name);
```

### Tabla de Datos Financieros
```sql
CREATE TABLE financial_data (
    id SERIAL PRIMARY KEY,
    monthly_income DECIMAL(12,2) NOT NULL DEFAULT 0,
    monthly_costs DECIMAL(12,2) NOT NULL DEFAULT 0,
    monthly_profit DECIMAL(12,2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar registro inicial
INSERT INTO financial_data (id, monthly_income, monthly_costs, monthly_profit, updated_at)
VALUES (1, 0, 0, 0, NOW());
```

## 🔑 Paso 3: Configurar API Keys

1. Ve a **Settings** > **API** en tu proyecto Supabase
2. Copia los siguientes valores:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **anon public key**: La clave pública anónima

## ⚙️ Paso 4: Actualizar Código Flutter

Reemplaza en `lib/data/models/supabase_manager.dart`:

```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co', // Reemplaza con tu URL
  anonKey: 'your-anon-key-here', // Reemplaza con tu clave
);
```

## 🔒 Paso 5: Configurar Políticas de Seguridad (RLS)

Ejecuta estas políticas en el SQL Editor:

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplies ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE completed_appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_data ENABLE ROW LEVEL SECURITY;

-- Políticas para clientes
CREATE POLICY "Allow all operations on clients" ON clients
    FOR ALL USING (true) WITH CHECK (true);

-- Políticas para servicios
CREATE POLICY "Allow all operations on services" ON services
    FOR ALL USING (true) WITH CHECK (true);

-- Políticas para suministros
CREATE POLICY "Allow all operations on supplies" ON supplies
    FOR ALL USING (true) WITH CHECK (true);

-- Políticas para citas
CREATE POLICY "Allow all operations on appointments" ON appointments
    FOR ALL USING (true) WITH CHECK (true);

-- Políticas para citas completadas
CREATE POLICY "Allow all operations on completed_appointments" ON completed_appointments
    FOR ALL USING (true) WITH CHECK (true);

-- Políticas para datos financieros
CREATE POLICY "Allow all operations on financial_data" ON financial_data
    FOR ALL USING (true) WITH CHECK (true);
```

## 🚀 Paso 6: Probar la Conexión

1. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

2. Deberías ver la pantalla de "Conectando con la Nube"
3. Si todo está correcto, la app cargará y mostrará "Cloud" en la barra superior

## 📱 Paso 7: Actualizar main.dart

Reemplaza el contenido de `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'presentation/app/app_supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
```

## 🔧 Paso 8: Construir APK

```bash
flutter pub get
flutter build apk --release
```

## ✅ Beneficios de Usar Supabase

### 🌐 **Ventajas sobre SharedPreferences**
- ✅ **Persistencia real en la nube**
- ✅ **Multi-dispositivo sincronizado**
- ✅ **Backup automático**
- ✅ **Escalabilidad infinita**
- ✅ **Acceso web a los datos**
- ✅ **API REST incluida**
- ✅ **Tiempo real (realtime)**
- ✅ **Seguridad enterprise**

### 🔄 **Sincronización Automática**
- **Cada 30 segundos**: sincronización automática
- **Al cambiar pestaña**: sincronización inmediata
- **Al reabrir app**: carga desde la nube
- **Botón de sync**: sincronización manual

### 💾 **Características Cloud**
- **Dashboard web**: Ver datos en supabase.com
- **Exportación**: Exportar datos fácilmente
- **Backup**: Versionado automático
- **Colaboración**: Múltiples usuarios
- **Analytics**: Estadísticas de uso

## 🎯 **Resultado Final**

La aplicación ahora:
1. **Guarda todo en la nube** (Supabase)
2. **Sincroniza automáticamente**
3. **Funciona offline** con cache local
4. **Persiste datos** sin importar qué pase
5. **Acceso web** a todos los datos
6. **Multi-dispositivo** sincronizado

**¡Es una solución enterprise-level para persistencia de datos!** 🚀
