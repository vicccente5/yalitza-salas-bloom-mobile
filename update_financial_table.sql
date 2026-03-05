-- Modificar tabla financial_data para manejar ingresos por fecha
-- 1. Agregar columna para fecha específica del ingreso
ALTER TABLE financial_data 
ADD COLUMN IF NOT EXISTS income_date DATE;

-- 2. Crear tabla para ingresos mensuales detallados
CREATE TABLE IF NOT EXISTS monthly_income (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  income_date DATE NOT NULL, -- Fecha específica del ingreso
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  source VARCHAR(50) DEFAULT 'appointment', -- 'appointment', 'manual', 'adjustment'
  appointment_id TEXT, -- Cambiado a TEXT para compatibilidad con UUID y INTEGER
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crear índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_monthly_income_date ON monthly_income(income_date);
CREATE INDEX IF NOT EXISTS idx_monthly_income_source ON monthly_income(source);

-- 4. Políticas RLS para monthly_income
ALTER TABLE monthly_income ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON monthly_income
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON monthly_income
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON monthly_income
  FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON monthly_income
  FOR DELETE USING (true);

-- 5. Trigger para actualizar updated_at en monthly_income
CREATE TRIGGER update_monthly_income_updated_at 
  BEFORE UPDATE ON monthly_income 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- 6. Migrar datos existentes (si los hay)
INSERT INTO monthly_income (income_date, amount, description, source, created_at)
SELECT 
  NOW() as income_date,
  monthly_income as amount,
  'Migrated from financial_data' as description,
  'migration' as source,
  NOW() as created_at
FROM financial_data 
WHERE monthly_income > 0;

-- 7. Actualizar financial_data para que sea un resumen mensual
UPDATE financial_data 
SET monthly_income = (
  SELECT COALESCE(SUM(amount), 0) 
  FROM monthly_income 
  WHERE DATE_TRUNC('month', income_date) = DATE_TRUNC('month', NOW())
);

-- 8. Crear vista para obtener ingresos mensuales
CREATE OR REPLACE VIEW monthly_income_summary AS
SELECT 
  DATE_TRUNC('month', income_date) as month,
  SUM(amount) as total_income,
  COUNT(*) as income_count,
  MIN(income_date) as first_income_date,
  MAX(income_date) as last_income_date
FROM monthly_income 
GROUP BY DATE_TRUNC('month', income_date)
ORDER BY month DESC;
