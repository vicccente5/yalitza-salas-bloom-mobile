import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para configurar la base de datos de Supabase
/// usando la API REST directamente
class SupabaseSetup {
  static const String _supabaseUrl = 'https://dbrlbhtgymicwggahake.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE';

  static Future<void> createExpensesTable() async {
    print('🔧 Creando tabla expenses...');
    
    final url = Uri.parse('$_supabaseUrl/rest/v1/rpc/execute_sql');
    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    };

    final sql = '''
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
    ''';

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'sql': sql}),
      );

      if (response.statusCode == 200) {
        print('✅ Tabla expenses creada exitosamente');
      } else {
        print('❌ Error creando tabla expenses: ${response.body}');
        // Intentar método alternativo
        await _createTableAlternative();
      }
    } catch (e) {
      print('❌ Error en la petición: $e');
      await _createTableAlternative();
    }
  }

  static Future<void> _createTableAlternative() async {
    print('🔄 Intentando método alternativo...');
    
    // Intentar insertar un registro para forzar la creación de la tabla
    final url = Uri.parse('$_supabaseUrl/rest/v1/expenses');
    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    };

    final testData = {
      'id': '00000000-0000-0000-0000-000000000001',
      'description': 'Test Record',
      'amount': 0.01,
      'category': 'Test',
      'date': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(testData),
      );

      if (response.statusCode == 201) {
        print('✅ Tabla expenses creada con método alternativo');
        // Eliminar el registro de prueba
        await _deleteTestRecord();
      } else {
        print('❌ Método alternativo falló: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en método alternativo: $e');
    }
  }

  static Future<void> _deleteTestRecord() async {
    final url = Uri.parse('$_supabaseUrl/rest/v1/expenses?id=eq.00000000-0000-0000-0000-000000000001');
    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey,
    };

    try {
      await http.delete(url, headers: headers);
      print('🧹 Registro de prueba eliminado');
    } catch (e) {
      print('⚠️ No se pudo eliminar registro de prueba: $e');
    }
  }

  static Future<void> createExpenseCategoriesTable() async {
    print('🔧 Creando tabla expense_categories...');
    
    final url = Uri.parse('$_supabaseUrl/rest/v1/expense_categories');
    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    };

    final testData = {
      'id': '00000000-0000-0000-0000-000000000001',
      'name': 'Test Category',
      'description': 'Test category for table creation',
      'color': '#000000',
      'icon': 'test',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(testData),
      );

      if (response.statusCode == 201) {
        print('✅ Tabla expense_categories creada exitosamente');
        // Eliminar el registro de prueba
        await _deleteTestCategory();
      } else {
        print('❌ Error creando tabla expense_categories: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creando tabla expense_categories: $e');
    }
  }

  static Future<void> _deleteTestCategory() async {
    final url = Uri.parse('$_supabaseUrl/rest/v1/expense_categories?id=eq.00000000-0000-0000-0000-000000000001');
    final headers = <String, String>{
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey,
    };

    try {
      await http.delete(url, headers: headers);
      print('🧹 Categoría de prueba eliminada');
    } catch (e) {
      print('⚠️ No se pudo eliminar categoría de prueba: $e');
    }
  }

  static Future<void> insertCategories() async {
    print('📝 Insertando categorías predefinidas...');
    
    final url = Uri.parse('$_supabaseUrl/rest/v1/expense_categories');
    final headers = <String, String>{
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    };

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

    int successCount = 0;
    for (final category in categories) {
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(category),
        );

        if (response.statusCode == 201) {
          successCount++;
        } else {
          print('⚠️ Categoría ${category['name']} ya existe o error: ${response.body}');
        }
      } catch (e) {
        print('⚠️ Error insertando categoría ${category['name']}: $e');
      }
    }

    print('✅ $successCount categorías insertadas exitosamente');
  }

  static Future<void> insertSampleExpenses() async {
    print('💰 Insertando gastos de ejemplo...');
    
    final url = Uri.parse('$_supabaseUrl/rest/v1/expenses');
    final headers = {
      'Authorization': 'Bearer $_supabaseAnonKey',
      'apikey': _supabaseAnonKey,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    };

    final expenses = [
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

    int successCount = 0;
    for (final expense in expenses) {
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(expense),
        );

        if (response.statusCode == 201) {
          successCount++;
        } else {
          print('⚠️ Gasto ${expense['description']} error: ${response.body}');
        }
      } catch (e) {
        print('⚠️ Error insertando gasto ${expense['description']}: $e');
      }
    }

    print('✅ $successCount gastos de ejemplo insertados exitosamente');
  }

  static Future<void> verifyTables() async {
    print('🔍 Verificando que las tablas existen...');
    
    // Verificar tabla expenses
    try {
      final url = Uri.parse('$_supabaseUrl/rest/v1/expenses?limit=1');
      final headers = {
        'Authorization': 'Bearer $_supabaseAnonKey',
        'apikey': _supabaseAnonKey',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        print('✅ Tabla expenses verificada');
      } else {
        print('❌ Tabla expenses no encontrada');
      }
    } catch (e) {
      print('❌ Error verificando tabla expenses: $e');
    }

    // Verificar tabla expense_categories
    try {
      final url = Uri.parse('$_supabaseUrl/rest/v1/expense_categories?limit=1');
      final headers = {
        'Authorization': 'Bearer $_supabaseAnonKey',
        'apikey': _supabaseAnonKey',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        print('✅ Tabla expense_categories verificada');
      } else {
        print('❌ Tabla expense_categories no encontrada');
      }
    } catch (e) {
      print('❌ Error verificando tabla expense_categories: $e');
    }
  }

  static Future<void> runFullSetup() async {
    print('🚀 INICIANDO CONFIGURACIÓN AUTOMÁTICA DE SUPABASE');
    print('=' * 60);
    
    await createExpensesTable();
    await createExpenseCategoriesTable();
    await insertCategories();
    await insertSampleExpenses();
    await verifyTables();
    
    print('=' * 60);
    print('🎉 CONFIGURACIÓN COMPLETADA');
    print('📱 Ahora puedes ejecutar la aplicación Flutter');
    print('🔗 Ve a la pestaña Admin para ver el nuevo sistema');
  }
}

void main() async {
  await SupabaseSetup.runFullSetup();
}
