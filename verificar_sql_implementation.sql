-- =====================================================================
-- VERIFICACIÓN POST-IMPLEMENTACIÓN SQL
-- =====================================================================

-- 1. Verificar que las vistas se crearon correctamente
SELECT 
    viewname,
    viewowner,
    definition
FROM pg_views 
WHERE viewname IN ('monthly_profits_with_expenses', 'monthly_financial_summary')
ORDER BY viewname;

-- 2. Verificar datos en la vista corregida
SELECT 
    month,
    total_income,
    total_expenses,
    net_profit,
    appointments_count,
    expenses_count,
    CASE 
        WHEN total_expenses > 0 THEN '✅ CORRECTO'
        ELSE '❌ REQUIERE ATENCION'
    END as expenses_status
FROM monthly_profits_with_expenses 
ORDER BY month DESC 
LIMIT 6;

-- 3. Comparar con datos brutos de expenses
SELECT 
    DATE_TRUNC('month', fecha) as month,
    COUNT(*) as expense_count,
    SUM(monto) as raw_expenses
FROM expenses 
WHERE fecha IS NOT NULL
GROUP BY DATE_TRUNC('month', fecha)
ORDER BY month DESC 
LIMIT 6;

-- 4. Verificar triggers creados
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_condition,
    action_statement
FROM information_schema.triggers 
WHERE trigger_table = 'expenses'
ORDER BY trigger_name;

-- 5. Verificar estado actual de monthly_profits
SELECT 
    month,
    total_income,
    total_expenses,
    net_profit,
    appointments_count,
    expenses_count,
    updated_at
FROM monthly_profits 
ORDER BY month DESC 
LIMIT 6;

-- 6. Prueba rápida: ¿Cuántos gastos hay en el mes actual?
SELECT 
    COUNT(*) as current_month_expenses,
    SUM(monto) as current_month_total
FROM expenses 
WHERE DATE_TRUNC('month', fecha) = DATE_TRUNC('month', NOW());
