-- ========================================
-- CORRECCIÓN DE POLÍTICAS RLS PARA GASTOS
-- ========================================

-- Eliminar políticas existentes que causan problemas
DROP POLICY IF EXISTS "Enable read access for all users" ON expenses;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON expenses;
DROP POLICY IF EXISTS "Enable update for users" ON expenses;
DROP POLICY IF EXISTS "Enable delete for users" ON expenses;

DROP POLICY IF EXISTS "Enable read access for all users" ON expense_categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON expense_categories;
DROP POLICY IF EXISTS "Enable update for users" ON expense_categories;
DROP POLICY IF EXISTS "Enable delete for users" ON expense_categories;

-- Crear nuevas políticas más permisivas para expenses
CREATE POLICY "Allow all operations on expenses" ON expenses
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Crear nuevas políticas más permisivas para expense_categories
CREATE POLICY "Allow all operations on expense_categories" ON expense_categories
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Verificar que las políticas se aplicaron correctamente
SELECT 'RLS policies updated successfully' as status;

-- Opcional: Deshabilitar RLS temporalmente para pruebas
-- ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE expense_categories DISABLE ROW LEVEL SECURITY;

-- Si prefieres deshabilitar RLS completamente, descomenta las líneas anteriores
-- y comenta las políticas CREATE POLICY de arriba
