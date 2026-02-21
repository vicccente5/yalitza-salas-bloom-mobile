-- ========================================
-- RECONSTRUCCIÓN COMPLETA DE TABLA EXPENSES
-- ========================================

-- 1. Eliminar tabla completamente
DROP TABLE IF EXISTS expenses CASCADE;

-- 2. Recrear tabla con estructura limpia y correcta
CREATE TABLE expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    -- Columnas principales (obligatorias)
    descripcion TEXT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    categoria TEXT NOT NULL,
    fecha TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Columnas adicionales
    notas TEXT DEFAULT '',
    receipt_url TEXT DEFAULT '',
    is_monthly BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crear índices
CREATE INDEX idx_expenses_fecha ON expenses(fecha DESC);
CREATE INDEX idx_expenses_categoria ON expenses(categoria);
CREATE INDEX idx_expenses_mensual ON expenses(is_monthly) WHERE is_monthly = TRUE;

-- 4. Crear trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. Configurar RLS (más permisivo)
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir todo en expenses" ON expenses
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- 6. Insertar datos de prueba
INSERT INTO expenses (descripcion, monto, categoria, fecha, notas) VALUES
('Gasto de prueba', 100.00, 'Otros', CURRENT_TIMESTAMP, 'Registro de prueba para verificar estructura');

-- 7. Verificar estructura
SELECT 'Tabla expenses reconstruida exitosamente' as status;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'expenses' 
ORDER BY ordinal_position;
