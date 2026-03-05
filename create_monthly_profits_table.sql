-- Crear tabla para guardar ganancias mensuales
CREATE TABLE IF NOT EXISTS monthly_profits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  month DATE NOT NULL, -- Primer día del mes (YYYY-MM-01)
  total_income DECIMAL(10,2) DEFAULT 0,
  total_expenses DECIMAL(10,2) DEFAULT 0,
  net_profit DECIMAL(10,2) DEFAULT 0,
  appointments_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(month)
);

-- Crear índice para búsquedas rápidas por mes
CREATE INDEX IF NOT EXISTS idx_monthly_profits_month ON monthly_profits(month);

-- Políticas RLS (Row Level Security)
-- 1. Habilitar RLS en la tabla
ALTER TABLE monthly_profits ENABLE ROW LEVEL SECURITY;

-- 2. Política para permitir leer todos los datos
CREATE POLICY "Enable read access for all users" ON monthly_profits
  FOR SELECT USING (true);

-- 3. Política para permitir insertar datos
CREATE POLICY "Enable insert for all users" ON monthly_profits
  FOR INSERT WITH CHECK (true);

-- 4. Política para permitir actualizar datos
CREATE POLICY "Enable update for all users" ON monthly_profits
  FOR UPDATE USING (true);

-- 5. Política para permitir eliminar datos
CREATE POLICY "Enable delete for all users" ON monthly_profits
  FOR DELETE USING (true);

-- Crear trigger para actualizar automáticamente el campo updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_monthly_profits_updated_at 
  BEFORE UPDATE ON monthly_profits 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
