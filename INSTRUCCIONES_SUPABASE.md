# 📋 Instrucciones para Configurar Base de Datos en Supabase

## 🚀 Pasos para Crear las Tablas de Gastos Categorizados

### 1. Acceder a Supabase Dashboard
1. Ve a: https://supabase.com/dashboard
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto: `dbrlbhtgymicwggahake`

### 2. Abrir Editor SQL
1. En el menú lateral, haz clic en **"SQL Editor"**
2. Haz clic en **"New query"**

### 3. Ejecutar el siguiente SQL

Copia y pega todo el siguiente código en el editor SQL y haz clic en **"Run"**:

```sql
-- ========================================
-- CREAR TABLA DE GASTOS CATEGORIZADOS
-- ========================================

-- 1. Crear tabla de gastos
CREATE TABLE IF NOT EXISTS expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    description TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    category TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    receipt_url TEXT,
    is_monthly BOOLEAN DEFAULT FALSE
);

-- 2. Crear tabla de categorías de gastos
CREATE TABLE IF NOT EXISTS expense_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    color TEXT DEFAULT '#6366f1',
    icon TEXT DEFAULT 'receipt',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Insertar categorías predefinidas
INSERT INTO expense_categories (name, description, color, icon) VALUES
('Casa', 'Gastos relacionados con el hogar', '#ef4444', 'home'),
('Luz', 'Pagos de servicios eléctricos', '#f59e0b', 'lightbulb'),
('Agua', 'Pagos de servicios de agua', '#3b82f6', 'water_drop'),
('Teléfono/Internet', 'Comunicaciones y conectividad', '#8b5cf6', 'phone'),
('Materiales de Belleza', 'Productos para tratamientos', '#ec4899', 'spa'),
('Suministros', 'Insumos para el negocio', '#10b981', 'inventory'),
('Marketing', 'Publicidad y promoción', '#f97316', 'campaign'),
('Transporte', 'Movilidad y viajes', '#06b6d4', 'directions_car'),
('Seguros', 'Pólizas y aseguradoras', '#84cc16', 'security'),
('Impuestos', 'Obligaciones fiscales', '#dc2626', 'receipt_long'),
('Mantenimiento', 'Mantenimiento de equipos', '#0891b2', 'build'),
('Otros', 'Gastos no categorizados', '#6b7280', 'more_horiz')
ON CONFLICT (name) DO NOTHING;

-- 4. Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);
CREATE INDEX IF NOT EXISTS idx_expenses_monthly ON expenses(is_monthly) WHERE is_monthly = TRUE;

-- 5. Crear políticas de seguridad (RLS)
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;

-- Políticas para expenses (todos pueden leer, solo autenticados pueden escribir)
CREATE POLICY "Enable read access for all users" ON expenses FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON expenses FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for users" ON expenses FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for users" ON expenses FOR DELETE USING (auth.role() = 'authenticated');

-- Políticas para expense_categories
CREATE POLICY "Enable read access for all users" ON expense_categories FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON expense_categories FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for users" ON expense_categories FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for users" ON expense_categories FOR DELETE USING (auth.role() = 'authenticated');

-- 6. Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Insertar datos de ejemplo (opcional)
INSERT INTO expenses (description, amount, category, date, notes, is_monthly) VALUES
('Renta de local', 15000.00, 'Casa', CURRENT_DATE, 'Renta mensual del consultorio', true),
('Recibo de luz CFE', 2500.00, 'Luz', CURRENT_DATE - INTERVAL '7 days', 'Pago bimestral', false),
('Compra de productos para faciales', 3500.00, 'Materiales de Belleza', CURRENT_DATE - INTERVAL '3 days', 'Hidratantes y limpiadores', false),
('Publicidad en redes sociales', 800.00, 'Marketing', CURRENT_DATE - INTERVAL '1 day', 'Promoción del mes', true)
ON CONFLICT DO NOTHING;
```

### 4. Verificar que las tablas se crearon
1. En el menú lateral, ve a **"Table Editor"**
2. Deberías ver las nuevas tablas:
   - `expenses`
   - `expense_categories`

### 5. Probar la aplicación
1. Ejecuta la aplicación Flutter:
   ```bash
   flutter run -d chrome
   ```

2. Ve a la pestaña **"Admin"** y deberías ver:
   - El nuevo panel de gastos categorizados
   - La opción para agregar gastos
   - El desglose por categorías

## 🎯 ¿Qué incluye el nuevo sistema?

### ✅ **Funcionalidades Implementadas:**
- **12 categorías predefinidas** de gastos
- **Registro de gastos** con descripción, monto, categoría, fecha y notas
- **Gastos mensuales recurrentes** (marcables)
- **Desglose visual** por categorías con colores e iconos
- **Cálculo automático** de totales y ganancias
- **CRUD completo** para gastos
- **Integración total** con Supabase

### 📊 **Categorías Disponibles:**
1. 🏠 Casa
2. 💡 Luz  
3. 💧 Agua
4. 📞 Teléfono/Internet
5. 💅 Materiales de Belleza
6. 📦 Suministros
7. 📢 Marketing
8. 🚗 Transporte
9. 🔒 Seguros
10. 🧾 Impuestos
11. 🔧 Mantenimiento
12. ⚙️ Otros

## 🚨 **Importante:**
- **Ejecuta el SQL completo** en una sola vez
- **Verifica que no haya errores** en la ejecución
- **Las tablas deben aparecer** en el Table Editor
- **La aplicación se conectará automáticamente** una vez creadas las tablas

## 📞 **Si tienes problemas:**
1. Verifica que el SQL se ejecutó sin errores
2. Confirma que las tablas aparecen en Table Editor
3. Reinicia la aplicación Flutter
4. Revisa la consola para mensajes de error

---

**¡Listo! Una vez que ejecutes este SQL, tu aplicación tendrá el sistema completo de gastos categorizados.** 🎉
