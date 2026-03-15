-- =====================================================================
-- CORRECCIÓN COMPLETA PARA VISTAS FINANCIERAS - VERSIÓN CORREGIDA
-- Problema: monthly_profits_with_expenses muestra 0.00 en total_expenses
-- Solución: Usar solo campos correctos (monto, fecha) de la tabla expenses
-- =====================================================================

-- 1. PRIMERO: Verificar datos actuales para diagnóstico
SELECT 
    'EXPENSES_DATA' as table_name,
    COUNT(*) as total_records,
    SUM(COALESCE(monto, 0)) as total_amount,
    MIN(fecha) as earliest_date,
    MAX(fecha) as latest_date
FROM expenses
UNION ALL
SELECT 
    'MONTHLY_PROFITS' as table_name,
    COUNT(*) as total_records,
    SUM(COALESCE(total_expenses, 0)) as total_amount,
    MIN(month) as earliest_date,
    MAX(month) as latest_date
FROM monthly_profits
UNION ALL
SELECT 
    'COMPLETED_APPOINTMENTS' as table_name,
    COUNT(*) as total_records,
    SUM(COALESCE(amount, 0)) as total_amount,
    MIN(date_time) as earliest_date,
    MAX(date_time) as latest_date
FROM completed_appointments;

-- 2. CORRECCIÓN: Actualizar todos los registros existentes en monthly_profits
-- con los gastos reales calculados desde la tabla expenses (SOLO CAMPOS CORRECTOS)
UPDATE monthly_profits mp 
SET 
    total_expenses = (
        SELECT COALESCE(SUM(monto), 0)
        FROM expenses e
        WHERE DATE_TRUNC('month', e.fecha) = mp.month
    ),
    expenses_count = (
        SELECT COUNT(*)
        FROM expenses e
        WHERE DATE_TRUNC('month', e.fecha) = mp.month
    ),
    -- Recalcular net_profit correctamente
    net_profit = total_income - (
        SELECT COALESCE(SUM(monto), 0)
        FROM expenses e
        WHERE DATE_TRUNC('month', e.fecha) = mp.month
    );

-- 3. VISTA CORREGIDA: monthly_profits_with_expenses
-- Esta vista ahora calcula correctamente los gastos y ganancias
CREATE OR REPLACE VIEW monthly_profits_with_expenses AS
SELECT 
    mp.id,
    mp.month,
    COALESCE(mp.total_income, 0) as total_income,
    -- Calcular gastos en tiempo real desde la tabla expenses (SOLO CAMPO monto)
    COALESCE(
        (
            SELECT SUM(monto)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = mp.month
        ), 0
    ) as total_expenses,
    -- Contar gastos reales
    COALESCE(
        (
            SELECT COUNT(*)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = mp.month
        ), 0
    ) as expenses_count,
    -- Calcular ganancia neta correctamente
    (COALESCE(mp.total_income, 0) - COALESCE(
        (
            SELECT SUM(monto)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = mp.month
        ), 0
    )) as net_profit,
    COALESCE(mp.appointments_count, 0) as appointments_count,
    mp.created_at,
    mp.updated_at
FROM monthly_profits mp
ORDER BY mp.month DESC;

-- 4. VISTA ADICIONAL: monthly_financial_summary
-- Vista completa que combina ingresos, gastos y citas
CREATE OR REPLACE VIEW monthly_financial_summary AS
SELECT 
    -- Información del mes
    DATE_TRUNC('month', month_date.month) as month,
    TO_CHAR(month_date.month, 'YYYY-MM') as month_key,
    TO_CHAR(month_date.month, 'Month YYYY') as month_name,
    
    -- Ingresos desde completed_appointments
    COALESCE(
        (
            SELECT SUM(COALESCE(ca.amount, 0))
            FROM completed_appointments ca
            WHERE DATE_TRUNC('month', ca.date_time) = month_date.month
        ), 0
    ) as total_income,
    
    -- Conteo de citas completadas
    COALESCE(
        (
            SELECT COUNT(*)
            FROM completed_appointments ca
            WHERE DATE_TRUNC('month', ca.date_time) = month_date.month
        ), 0
    ) as appointments_count,
    
    -- Gastos desde expenses (SOLO CAMPOS CORRECTOS: monto, fecha)
    COALESCE(
        (
            SELECT SUM(monto)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = month_date.month
        ), 0
    ) as total_expenses,
    
    -- Conteo de gastos
    COALESCE(
        (
            SELECT COUNT(*)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = month_date.month
        ), 0
    ) as expenses_count,
    
    -- Ganancia neta calculada
    (
        COALESCE(
            (
                SELECT SUM(COALESCE(ca.amount, 0))
                FROM completed_appointments ca
                WHERE DATE_TRUNC('month', ca.date_time) = month_date.month
            ), 0
        ) - 
        COALESCE(
            (
                SELECT SUM(monto)
                FROM expenses e
                WHERE DATE_TRUNC('month', e.fecha) = month_date.month
            ), 0
        )
    ) as net_profit
FROM (
    -- Generar todos los meses desde hace 2 años hasta 1 año futuro
    SELECT generate_series(
        DATE_TRUNC('month', NOW() - INTERVAL '2 years'),
        DATE_TRUNC('month', NOW() + INTERVAL '1 year'),
        INTERVAL '1 month'
    )::date as month
) month_date
ORDER BY month_date.month DESC;

-- 5. VERIFICACIÓN: Mostrar datos corregidos
SELECT 
    'VERIFICACION_FINAL' as status,
    month,
    total_income,
    total_expenses,
    net_profit,
    appointments_count,
    expenses_count,
    CASE 
        WHEN total_expenses > 0 THEN 'CORRECTO'
        ELSE 'REQUIERE_ATENCION'
    END as expenses_status
FROM monthly_profits_with_expenses 
ORDER BY month DESC 
LIMIT 12;

-- 6. VERIFICACIÓN ADICIONAL: Comparación con datos brutos
SELECT 
    'COMPARACION_DATOS_BRUTOS' as status,
    DATE_TRUNC('month', fecha) as month,
    COUNT(*) as expense_count,
    SUM(monto) as raw_expenses
FROM expenses 
WHERE fecha IS NOT NULL
GROUP BY DATE_TRUNC('month', fecha)
ORDER BY month DESC
LIMIT 12;

-- 7. TRIGGER AUTOMÁTICO: Actualizar monthly_profits cuando se agrega un gasto
CREATE OR REPLACE FUNCTION update_monthly_profits_on_expense()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar o insertar registro en monthly_profits para el mes del gasto
    INSERT INTO monthly_profits (month, total_expenses, expenses_count)
    VALUES (
        DATE_TRUNC('month', NEW.fecha),
        NEW.monto,
        1
    )
    ON CONFLICT (month) 
    DO UPDATE SET
        total_expenses = monthly_profits.total_expenses + NEW.monto,
        expenses_count = monthly_profits.expenses_count + 1,
        net_profit = monthly_profits.total_income - (monthly_profits.total_expenses + NEW.monto);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para gastos
DROP TRIGGER IF EXISTS trigger_update_monthly_profits_on_expense ON expenses;
CREATE TRIGGER trigger_update_monthly_profits_on_expense
    AFTER INSERT ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_monthly_profits_on_expense();

-- 8. TRIGGER PARA ACTUALIZACIÓN DE GASTOS
CREATE OR REPLACE FUNCTION update_monthly_profits_on_expense_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Recalcular total de gastos para el mes
    UPDATE monthly_profits 
    SET 
        total_expenses = (
            SELECT SUM(monto)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = DATE_TRUNC('month', NEW.fecha)
        ),
        expenses_count = (
            SELECT COUNT(*)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = DATE_TRUNC('month', NEW.fecha)
        ),
        net_profit = total_income - (
            SELECT SUM(monto)
            FROM expenses e
            WHERE DATE_TRUNC('month', e.fecha) = DATE_TRUNC('month', NEW.fecha)
        )
    WHERE month = DATE_TRUNC('month', NEW.fecha);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para actualización de gastos
DROP TRIGGER IF EXISTS trigger_update_monthly_profits_on_expense_update ON expenses;
CREATE TRIGGER trigger_update_monthly_profits_on_expense_update
    AFTER UPDATE ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_monthly_profits_on_expense_update();

-- 9. TRIGGER PARA ELIMINACIÓN DE GASTOS
CREATE OR REPLACE FUNCTION update_monthly_profits_on_expense_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar total de gastos para el mes
    UPDATE monthly_profits 
    SET 
        total_expenses = total_expenses - OLD.monto,
        expenses_count = expenses_count - 1,
        net_profit = total_income - (total_expenses - OLD.monto)
    WHERE month = DATE_TRUNC('month', OLD.fecha);
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para eliminación de gastos
DROP TRIGGER IF EXISTS trigger_update_monthly_profits_on_expense_delete ON expenses;
CREATE TRIGGER trigger_update_monthly_profits_on_expense_delete
    AFTER DELETE ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_monthly_profits_on_expense_delete();

-- =====================================================================
-- FIN DE LAS CORRECCIONES - VERSIÓN CORREGIDA
-- =====================================================================
