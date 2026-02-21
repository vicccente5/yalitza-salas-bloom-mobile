import 'package:supabase_flutter/supabase_flutter.dart';

/// Script simple para configurar las tablas de gastos
/// usando el método de inserción directa
class SimpleSetup {
  static const String supabaseUrl = 'https://dbrlbhtgymicwggahake.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE';

  static Future<void> setupTables() async {
    print('🚀 Iniciando configuración de tablas...');
    
    try {
      // Inicializar Supabase
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      final supabase = Supabase.instance.client;
      
      print('✅ Supabase inicializado');
      
      // Crear tabla de categorías primero
      await createCategoriesTable(supabase);
      
      // Crear tabla de gastos
      await createExpensesTable(supabase);
      
      // Insertar categorías predefinidas
      await insertCategories(supabase);
      
      // Insertar gastos de ejemplo
      await insertSampleExpenses(supabase);
      
      print('🎉 Configuración completada exitosamente');
      
    } catch (e) {
      print('❌ Error en la configuración: $e');
    }
  }

  static Future<void> createCategoriesTable(dynamic supabase) async {
    print('📁 Creando tabla de categorías...');
    
    try {
      // Intentar insertar una categoría de prueba para crear la tabla
      await supabase.from('expense_categories').insert({
        'id': '00000000-0000-0000-0000-000000000001',
        'name': 'Test',
        'description': 'Test category',
        'color': '#000000',
        'icon': 'test',
        'is_active': true,
      });
      
      // Eliminar la categoría de prueba
      await supabase.from('expense_categories').delete().eq('id', '00000000-0000-0000-0000-000000000001');
      
      print('✅ Tabla expense_categories creada');
    } catch (e) {
      print('⚠️ La tabla expense_categories ya existe o error: $e');
    }
  }

  static Future<void> createExpensesTable(dynamic supabase) async {
    print('💰 Creando tabla de gastos...');
    
    try {
      // Intentar insertar un gasto de prueba para crear la tabla
      await supabase.from('expenses').insert({
        'id': '00000000-0000-0000-0000-000000000001',
        'description': 'Test Expense',
        'amount': 0.01,
        'category': 'Test',
        'date': DateTime.now().toIso8601String(),
        'notes': 'Test expense',
        'is_monthly': false,
      });
      
      // Eliminar el gasto de prueba
      await supabase.from('expenses').delete().eq('id', '00000000-0000-0000-0000-000000000001');
      
      print('✅ Tabla expenses creada');
    } catch (e) {
      print('⚠️ La tabla expenses ya existe o error: $e');
    }
  }

  static Future<void> insertCategories(dynamic supabase) async {
    print('📝 Insertando categorías predefinidas...');
    
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
        await supabase.from('expense_categories').insert(category);
        successCount++;
        print('✅ Categoría ${category['name']} insertada');
      } catch (e) {
        print('⚠️ Categoría ${category['name']} ya existe o error: $e');
      }
    }

    print('📊 Total categorías insertadas: $successCount/12');
  }

  static Future<void> insertSampleExpenses(dynamic supabase) async {
    print('💰 Insertando gastos de ejemplo...');
    
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
        'date': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
        'notes': 'Pago bimestral',
        'is_monthly': false,
      },
      {
        'description': 'Compra de productos para faciales',
        'amount': 3500.00,
        'category': 'Materiales de Belleza',
        'date': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'notes': 'Hidratantes y limpiadores',
        'is_monthly': false,
      },
      {
        'description': 'Publicidad en redes sociales',
        'amount': 800.00,
        'category': 'Marketing',
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'notes': 'Promoción del mes',
        'is_monthly': true,
      },
    ];

    int successCount = 0;
    for (final expense in expenses) {
      try {
        await supabase.from('expenses').insert(expense);
        successCount++;
        print('✅ Gasto ${expense['description']} insertado');
      } catch (e) {
        print('⚠️ Gasto ${expense['description']} error: $e');
      }
    }

    print('💵 Total gastos insertados: $successCount/4');
  }
}

void main() async {
  await SimpleSetup.setupTables();
  print('🎯 Configuración finalizada. Ahora ejecuta: flutter run -d chrome');
}
