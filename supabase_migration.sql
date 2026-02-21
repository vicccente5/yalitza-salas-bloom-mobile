-- MIGRACIÓN PARA SISTEMA DE GASTOS CATEGORIZADOS
-- Yalitza Salas Bloom Mobile

-- 1. Crear tabla de gastos categorizados
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

-- 2. Crear tabla de categorías de gastos (opcional, para más flexibilidad)
CREATE TABLE IF NOT EXISTS expense_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    color TEXT DEFAULT '#6366f1', -- Color para UI
    icon TEXT DEFAULT 'receipt', -- Icono para UI
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Insertar categorías predefinidas
INSERT INTO expense_categories (name, description, color, icon) VALUES
('Casa', 'Gastos relacionados con el hogar', '#ef4444', 'home'),
('Luz', 'Pagos de servicios eléctricos', '#f59e0b', 'lightbulb'),
('Agua', 'Pagos de servicios de agua', '#3b82f6', 'water_drop'),
('Teléfono/Internet', 'Comunicaciones y conectividad', '#8b5cf6', 'phone'),
('Materiales de belleza', 'Productos para tratamientos', '#ec4899', 'spa'),
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

-- 5. Crear vista para resumen financiero actualizado
CREATE OR REPLACE VIEW financial_summary AS
SELECT 
    -- Datos financieros existentes
    f.monthly_income,
    f.monthly_costs,
    f.monthly_profit,
    
    -- Cálculo de gastos por categoría (mes actual)
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Casa'), 0
    ) as casa_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Luz'), 0
    ) as luz_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Agua'), 0
    ) as agua_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Teléfono/Internet'), 0
    ) as telefono_internet_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Materiales de belleza'), 0
    ) as materiales_belleza_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Suministros'), 0
    ) as suministros_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Marketing'), 0
    ) as marketing_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Transporte'), 0
    ) as transporte_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Seguros'), 0
    ) as seguros_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Impuestos'), 0
    ) as impuestos_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Mantenimiento'), 0
    ) as mantenimiento_expenses,
    
    COALESCE(
        (SELECT COALESCE(SUM(e.amount), 0) 
         FROM expenses e 
         WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)
         AND e.category = 'Otros'), 0
    ) as otros_expenses,
    
    -- Total de gastos del mes (nuevo cálculo)
    COALESCE((SELECT COALESCE(SUM(e.amount), 0) 
              FROM expenses e 
              WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)), 0) as total_monthly_expenses,
    
    -- Ganancia recalculada
    (f.monthly_income - COALESCE((SELECT COALESCE(SUM(e.amount), 0) 
                                  FROM expenses e 
                                  WHERE DATE_TRUNC('month', e.date) = DATE_TRUNC('month', CURRENT_DATE)), 0)) as calculated_profit,
    
    f.updated_at
    
FROM financial_data f
WHERE f.id = 1;

-- 6. Políticas de seguridad (RLS - Row Level Security)
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;

-- Políticas para expenses (todos pueden leer, solo autenticados pueden escribir)
CREATE POLICY "Enable read access for all users" ON expenses FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON expenses FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for users" ON expenses FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for users" ON expenses FOR DELETE USING (auth.role() = 'authenticated');

-- Políticas para expense_categories (todos pueden leer, solo autenticados pueden escribir)
CREATE POLICY "Enable read access for all users" ON expense_categories FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON expense_categories FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for users" ON expense_categories FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for users" ON expense_categories FOR DELETE USING (auth.role() = 'authenticated');

-- 7. Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. Datos de ejemplo (opcional)
INSERT INTO expenses (description, amount, category, date, notes) VALUES
('Renta de local', 15000.00, 'Casa', CURRENT_DATE, 'Renta mensual del consultorio'),
('Recibo de luz CFE', 2500.00, 'Luz', CURRENT_DATE - INTERVAL '7 days', 'Pago bimestral'),
('Compra de productos para faciales', 3500.00, 'Materiales de belleza', CURRENT_DATE - INTERVAL '3 days', 'Hidratantes y limpiadores'),
('Publicidad en redes sociales', 800.00, 'Marketing', CURRENT_DATE - INTERVAL '1 day', 'Promoción del mes')
ON CONFLICT DO NOTHING;
