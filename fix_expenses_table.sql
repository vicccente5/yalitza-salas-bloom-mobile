-- ========================================
-- CORRECCIÓN COMPLETA DE TABLAS DE GASTOS
-- ========================================

-- Eliminar tablas existentes para recrearlas correctamente
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS expense_categories CASCADE;

-- 1. Crear tabla de gastos con columnas en ambos idiomas
CREATE TABLE expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    -- Columnas en inglés
    description TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    category TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    receipt_url TEXT,
    is_monthly BOOLEAN DEFAULT FALSE,
    -- Columnas en español
    descripcion TEXT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    categoria TEXT NOT NULL,
    fecha TIMESTAMP WITH TIME ZONE NOT NULL,
    notas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Crear tabla de categorías con columnas en ambos idiomas
CREATE TABLE expense_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    -- Columnas en inglés
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    color TEXT DEFAULT '#6366f1',
    icon TEXT DEFAULT 'receipt',
    is_active BOOLEAN DEFAULT TRUE,
    -- Columnas en español
    nombre TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    icono TEXT DEFAULT 'receipt',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Insertar categorías predefinidas
INSERT INTO expense_categories (name, description, color, icon, nombre, descripcion, icono) VALUES
('Casa', 'Gastos relacionados con el hogar', '#ef4444', 'home', 'Casa', 'Gastos relacionados con el hogar', 'home'),
('Luz', 'Pagos de servicios eléctricos', '#f59e0b', 'lightbulb', 'Luz', 'Pagos de servicios eléctricos', 'lightbulb'),
('Agua', 'Pagos de servicios de agua', '#3b82f6', 'water_drop', 'Agua', 'Pagos de servicios de agua', 'water_drop'),
('Teléfono/Internet', 'Comunicaciones y conectividad', '#8b5cf6', 'phone', 'Teléfono/Internet', 'Comunicaciones y conectividad', 'phone'),
('Materiales de Belleza', 'Productos para tratamientos', '#ec4899', 'spa', 'Materiales de Belleza', 'Productos para tratamientos', 'spa'),
('Suministros', 'Insumos para el negocio', '#10b981', 'inventory', 'Suministros', 'Insumos para el negocio', 'inventory'),
('Marketing', 'Publicidad y promoción', '#f97316', 'campaign', 'Marketing', 'Publicidad y promoción', 'campaign'),
('Transporte', 'Movilidad y viajes', '#06b6d4', 'directions_car', 'Transporte', 'Movilidad y viajes', 'directions_car'),
('Seguros', 'Pólizas y aseguradoras', '#84cc16', 'security', 'Seguros', 'Pólizas y aseguradoras', 'security'),
('Impuestos', 'Obligaciones fiscales', '#dc2626', 'receipt_long', 'Impuestos', 'Obligaciones fiscales', 'receipt_long'),
('Mantenimiento', 'Mantenimiento de equipos', '#0891b2', 'build', 'Mantenimiento', 'Mantenimiento de equipos', 'build'),
('Otros', 'Gastos no categorizados', '#6b7280', 'more_horiz', 'Otros', 'Gastos no categorizados', 'more_horiz');

-- 4. Crear índices
CREATE INDEX idx_expenses_date ON expenses(date DESC);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_categoria ON expenses(categoria);
CREATE INDEX idx_expenses_monthly ON expenses(is_monthly) WHERE is_monthly = TRUE;

-- 5. Crear políticas de seguridad (RLS)
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;

-- Políticas para expenses
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

-- 7. Insertar datos de ejemplo
INSERT INTO expenses (description, amount, category, date, notes, is_monthly, descripcion, monto, categoria, fecha, notas) VALUES
('Renta de local', 15000.00, 'Casa', CURRENT_DATE, 'Renta mensual del consultorio', true, 'Renta de local', 15000.00, 'Casa', CURRENT_DATE, 'Renta mensual del consultorio'),
('Recibo de luz CFE', 2500.00, 'Luz', CURRENT_DATE - INTERVAL '7 days', 'Pago bimestral', false, 'Recibo de luz CFE', 2500.00, 'Luz', CURRENT_DATE - INTERVAL '7 days', 'Pago bimestral'),
('Compra de productos para faciales', 3500.00, 'Materiales de Belleza', CURRENT_DATE - INTERVAL '3 days', 'Hidratantes y limpiadores', false, 'Compra de productos para faciales', 3500.00, 'Materiales de Belleza', CURRENT_DATE - INTERVAL '3 days', 'Hidratantes y limpiadores'),
('Publicidad en redes sociales', 800.00, 'Marketing', CURRENT_DATE - INTERVAL '1 day', 'Promoción del mes', true, 'Publicidad en redes sociales', 800.00, 'Marketing', CURRENT_DATE - INTERVAL '1 day', 'Promoción del mes');

-- 8. Verificación
SELECT 'expenses table created successfully' as status;
SELECT 'expense_categories table created successfully' as status;
SELECT COUNT(*) as categories_count FROM expense_categories;
SELECT COUNT(*) as expenses_count FROM expenses;
