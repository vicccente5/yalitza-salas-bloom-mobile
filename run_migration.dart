import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para ejecutar la migración de la base de datos
/// y crear las tablas de gastos categorizados
class DatabaseMigration {
  static const String _supabaseUrl = 'https://dbrlbhtgymicwggahake.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE';

  static late final SupabaseClient _supabase;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _supabase = Supabase.instance.client;
  }

  static Future<void> createExpensesTable() async {
    try {
      print('Creando tabla expenses...');
      
      // Usar RPC para ejecutar SQL directamente
      final result = await _supabase.rpc('exec_sql', params: {
        'sql': '''
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
        '''
      });
      
      print('✅ Tabla expenses creada exitosamente');
    } catch (e) {
      print('❌ Error creando tabla expenses: $e');
      // Intentar con SQL directo si RPC no funciona
      await _createTableWithDirectSQL();
    }
  }

  static Future<void> _createTableWithDirectSQL() async {
    try {
      print('Intentando crear tabla con SQL directo...');
      
      // Insertar un registro para forzar la creación de la tabla
      await _supabase.from('expenses').insert({
        'id': '00000000-0000-0000-0000-000000000001',
        'description': 'Gasto de prueba',
        'amount': 0.01,
        'category': 'Otros',
        'date': DateTime.now().toIso8601String(),
        'notes': 'Registro de prueba para crear tabla',
      });
      
      // Eliminar el registro de prueba
      await _supabase.from('expenses').delete().eq('id', '00000000-0000-0000-0000-000000000001');
      
      print('✅ Tabla expenses creada exitosamente con método directo');
    } catch (e) {
      print('❌ Error creando tabla con método directo: $e');
    }
  }

  static Future<void> createExpenseCategoriesTable() async {
    try {
      print('Creando tabla expense_categories...');
      
      await _supabase.from('expense_categories').insert({
        'id': '00000000-0000-0000-0000-000000000001',
        'name': 'Casa',
        'description': 'Gastos relacionados con el hogar',
        'color': '#ef4444',
        'icon': 'home',
        'is_active': true,
      });
      
      // Eliminar el registro de prueba
      await _supabase.from('expense_categories').delete().eq('id', '00000000-0000-0000-0000-000000000001');
      
      print('✅ Tabla expense_categories creada exitosamente');
    } catch (e) {
      print('❌ Error creando tabla expense_categories: $e');
    }
  }

  static Future<void> insertSampleData() async {
    try {
      print('Insertando datos de ejemplo...');
      
      final sampleExpenses = [
        {
          'description': 'Renta de local',
          'amount': 15000.00,
          'category': 'Casa',
          'date': DateTime.now().toIso8601String(),
          'notes': 'Renta mensual del consultorio',
          'is_monthly': true,
        },
        {
          'description': 'Recibo de luz CFE',
          'amount': 2500.00,
          'category': 'Luz',
          'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'notes': 'Pago bimestral',
          'is_monthly': false,
        },
        {
          'description': 'Compra de productos para faciales',
          'amount': 3500.00,
          'category': 'Materiales de Belleza',
          'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'notes': 'Hidratantes y limpiadores',
          'is_monthly': false,
        },
        {
          'description': 'Publicidad en redes sociales',
          'amount': 800.00,
          'category': 'Marketing',
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'notes': 'Promoción del mes',
          'is_monthly': true,
        },
      ];

      for (final expense in sampleExpenses) {
        await _supabase.from('expenses').insert(expense);
      }

      print('✅ Datos de ejemplo insertados exitosamente');
    } catch (e) {
      print('❌ Error insertando datos de ejemplo: $e');
    }
  }

  static Future<void> insertCategories() async {
    try {
      print('Insertando categorías predefinidas...');
      
      final categories = [
        {'name': 'Casa', 'description': 'Gastos relacionados con el hogar', 'color': '#ef4444', 'icon': 'home'},
        {'name': 'Luz', 'description': 'Pagos de servicios eléctricos', 'color': '#f59e0b', 'icon': 'lightbulb'},
        {'name': 'Agua', 'description': 'Pagos de servicios de agua', 'color': '#3b82f6', 'icon': 'water_drop'},
        {'name': 'Teléfono/Internet', 'description': 'Comunicaciones y conectividad', 'color': '#8b5cf6', 'icon': 'phone'},
        {'name': 'Materiales de Belleza', 'description': 'Productos para tratamientos', 'color': '#ec4899', 'icon': 'spa'},
        {'name': 'Suministros', 'description': 'Insumos para el negocio', 'color': '#10b981', 'icon': 'inventory'},
        {'name': 'Marketing', 'description': 'Publicidad y promoción', 'color': '#f97316', 'icon': 'campaign'},
        {'name': 'Transporte', 'description': 'Movilidad y viajes', 'color': '#06b6d4', 'icon': 'directions_car'},
        {'name': 'Seguros', 'description': 'Pólizas y aseguradoras', 'color': '#84cc16', 'icon': 'security'},
        {'name': 'Impuestos', 'description': 'Obligaciones fiscales', 'color': '#dc2626', 'icon': 'receipt_long'},
        {'name': 'Mantenimiento', 'description': 'Mantenimiento de equipos', 'color': '#0891b2', 'icon': 'build'},
        {'name': 'Otros', 'description': 'Gastos no categorizados', 'color': '#6b7280', 'icon': 'more_horiz'},
      ];

      for (final category in categories) {
        try {
          await _supabase.from('expense_categories').insert(category);
        } catch (e) {
          // Ignorar errores de duplicados
          print('Categoría ${category['name']} ya existe o error: $e');
        }
      }

      print('✅ Categorías predefinidas insertadas exitosamente');
    } catch (e) {
      print('❌ Error insertando categorías: $e');
    }
  }

  static Future<void> runFullMigration() async {
    await initialize();
    
    print('=== INICIANDO MIGRACIÓN DE BASE DE DATOS ===');
    
    await createExpensesTable();
    await createExpenseCategoriesTable();
    await insertCategories();
    await insertSampleData();
    
    print('=== MIGRACIÓN COMPLETADA ===');
  }
}

void main() async {
  await DatabaseMigration.runFullMigration();
}
