-- Agregar columna de gastos a la tabla monthly_profits
-- Esto permitirá que los gastos se vean reflejados correctamente en "Ver Ganancias por Mes"

-- 1. Agregar columna de gastos si no existe
ALTER TABLE monthly_profits 
ADD COLUMN IF NOT EXISTS total_expenses DECIMAL(10,2) DEFAULT 0.0;

-- 2. Agregar columna de número de gastos si no existe
ALTER TABLE monthly_profits 
ADD COLUMN IF NOT EXISTS expenses_count INTEGER DEFAULT 0;

-- 3. Actualizar registros existentes con gastos reales
UPDATE monthly_profits mp 
SET 
    total_expenses = (
        SELECT COALESCE(SUM(e.monto), 0)
        FROM expenses e
        WHERE DATE_TRUNC('month', e.fecha) = mp.month
    ),
    expenses_count = (
        SELECT COUNT(*)
        FROM expenses e
        WHERE DATE_TRUNC('month', e.fecha) = mp.month
    )
WHERE EXISTS (
    SELECT 1 FROM expenses e 
    WHERE DATE_TRUNC('month', e.fecha) = mp.month
);

-- 4. Crear índice para búsquedas más rápidas por gastos
CREATE INDEX IF NOT EXISTS idx_monthly_profits_expenses ON monthly_profits(total_expenses);

-- 5. Crear vista actualizada para mostrar ganancias con gastos
CREATE OR REPLACE VIEW monthly_profits_with_expenses AS
SELECT 
    mp.id,
    mp.month,
    mp.total_income,
    COALESCE(mp.total_expenses, 0) as total_expenses,
    COALESCE(mp.expenses_count, 0) as expenses_count,
    mp.net_profit,
    mp.appointments_count,
    mp.created_at,
    mp.updated_at,
    -- Calcular ganancia neta si no existe
    CASE 
        WHEN mp.net_profit IS NULL THEN mp.total_income - COALESCE(mp.total_expenses, 0)
        ELSE mp.net_profit
    END as calculated_net_profit
FROM monthly_profits mp
ORDER BY mp.month DESC;

-- 6. Actualizar el método calculateAndSaveMonthlyProfit para incluir gastos
-- (Esto se debe hacer en el código de la aplicación)

-- 7. Verificar que los datos se vean correctamente
SELECT 
    month,
    total_income,
    COALESCE(total_expenses, 0) as expenses,
    COALESCE(net_profit, total_income - COALESCE(total_expenses, 0)) as profit,
    appointments_count,
    COALESCE(expenses_count, 0) as expense_count
FROM monthly_profits 
ORDER BY month DESC;
