-- Migrar datos de completed_appointments a monthly_profits
-- Esto procesará todas las citas completadas existentes y las agregará a monthly_profits
-- con los ingresos calculados por mes

-- 1. Crear tabla temporal para procesamiento si no existe
CREATE TEMP TABLE IF NOT EXISTS temp_appointment_migration AS
SELECT 
    id,
    client_name,
    service_name,
    date_time,
    notes,
    amount,
    EXTRACT(MONTH FROM date_time) as appointment_month,
    EXTRACT(YEAR FROM date_time) as appointment_year,
    ROW_NUMBER() as row_num
FROM completed_appointments;

-- 2. Insertar o actualizar datos en monthly_profits basado en las citas completadas
INSERT INTO monthly_profits (month, total_income, total_expenses, net_profit, appointments_count, created_at, updated_at)
SELECT 
    DATE_TRUNC('month', ca.date_time) as month,
    SUM(COALESCECE(ca.amount, 0)) as total_income,
    0 as total_expenses, -- Se calculará después
    SUM(COALESCECE(ca.amount, 0)) as net_profit,
    COUNT(*) as appointments_count,
    NOW() as created_at,
    NOW() as updated_at
FROM temp_appointment_migration ca
GROUP BY DATE_TRUNC('month', ca.date_time)
ON CONFLICT (month) DO UPDATE SET
    total_income = EXCLUDED.total_income,
    total_expenses = 0,
    net_profit = EXCLUDED.net_profit,
    appointments_count = EXCLUDED.appointments_count,
    updated_at = NOW()
WHERE monthly_profits.month = DATE_TRUNC('month', ca.date_time);

-- 3. Actualizar los gastos para cada mes basado en la tabla expenses
UPDATE monthly_profits mp
SET 
    total_expenses = (
        SELECT COALESCE(SUM(e.monto), 0)
        FROM expenses e
        WHERE DATE_TRUNC('month', e.fecha) = mp.month
    ),
    net_profit = (
        SELECT COALESCE(SUM(ca.amount), 0) - COALESCE(SUM(e.monto), 0)
        FROM completed_appointments ca
        WHERE DATE_TRUNC('month', ca.date_time) = mp.month
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

-- 4. Actualizar el conteo de citas para cada mes
UPDATE monthly_profits mp
SET 
    appointments_count = (
        SELECT COUNT(*)
        FROM completed_appointments ca
        WHERE DATE_TRUNC('month', ca.date_time) = mp.month
    )
WHERE EXISTS (
    SELECT 1 FROM completed_appointments ca 
    WHERE DATE_TRUNC('month', ca.date_time) = mp.month
);

-- 5. Eliminar tabla temporal
DROP TABLE IF EXISTS temp_appointment_migration;

-- 6. Verificar los datos migrados
SELECT 
    month,
    total_income,
    COALESCE(total_expenses, 0) as total_expenses,
    COALESCE(net_profit, total_income - COALESCE(total_expenses, 0)) as net_profit,
    appointments_count,
    COALESCE(expenses_count, 0) as expenses_count
FROM monthly_profits 
ORDER BY month DESC;

-- 7. Mostrar resumen de la migración
SELECT 
    'Migración completada' as status,
    COUNT(*) as total_meses_procesados,
    SUM(total_income) as total_ingresos_migrados,
    SUM(COALESCECE(total_expenses, 0)) as total_gastos_migrados,
    SUM(COALESCECE(net_profit, total_income - COALESCE(total_expenses, 0))) as total_ganancias_migradas
FROM monthly_profits;
