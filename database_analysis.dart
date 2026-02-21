import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para analizar la estructura actual de la base de datos de Supabase
/// y preparar la implementación del sistema de gastos categorizados
class DatabaseAnalyzer {
  static const String _supabaseUrl = 'https://dbrlbhtgymicwggahake.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE';

  static late final SupabaseClient _supabase;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _supabase = Supabase.instance.client;
  }

  /// Analizar la estructura actual de la tabla financiera
  static Future<void> analyzeFinancialTable() async {
    try {
      print('=== ANÁLISIS DE TABLA FINANCIERA ===');
      
      // Intentar diferentes nombres de tabla
      final possibleTables = ['financial_data', 'finanzas', 'financial', 'datos_financieros'];
      
      for (final tableName in possibleTables) {
        try {
          final data = await _supabase.from(tableName).select('*').limit(1);
          print('✅ Tabla encontrada: $tableName');
          print('Datos: $data');
          
          if (data.isNotEmpty) {
            final columns = (data.first as Map<String, dynamic>).keys.toList();
            print('Columnas: $columns');
          }
          break;
        } catch (e) {
          print('❌ Tabla $tableName no encontrada: $e');
        }
      }
    } catch (e) {
      print('Error analizando tabla financiera: $e');
    }
  }

  /// Verificar si existe tabla de gastos categorizados
  static Future<void> checkExpensesTable() async {
    try {
      print('\n=== VERIFICANDO TABLA DE GASTOS ===');
      
      final possibleTables = ['expenses', 'gastos', 'expenses_categories', 'gastos_categorizados'];
      
      for (final tableName in possibleTables) {
        try {
          final data = await _supabase.from(tableName).select('*').limit(1);
          print('✅ Tabla de gastos encontrada: $tableName');
          print('Datos: $data');
          
          if (data.isNotEmpty) {
            final columns = (data.first as Map<String, dynamic>).keys.toList();
            print('Columnas: $columns');
          }
          break;
        } catch (e) {
          print('❌ Tabla $tableName no encontrada: $e');
        }
      }
    } catch (e) {
      print('Error verificando tabla de gastos: $e');
    }
  }

  /// Proponer estructura para nueva tabla de gastos categorizados
  static Future<void> proposeExpensesStructure() async {
    print('\n=== PROPUESTA DE ESTRUCTURA PARA GASTOS CATEGORIZADOS ===');
    
    final proposedStructure = {
      'table_name': 'expenses',
      'columns': {
        'id': 'UUID (PRIMARY KEY)',
        'description': 'TEXT (descripción del gasto)',
        'amount': 'DECIMAL (monto del gasto)',
        'category': 'TEXT (categoría: casa, luz, materiales, etc.)',
        'date': 'TIMESTAMP (fecha del gasto)',
        'created_at': 'TIMESTAMP (fecha de creación)',
        'updated_at': 'TIMESTAMP (fecha de actualización)',
        'notes': 'TEXT (notas adicionales, opcional)',
        'receipt_url': 'TEXT (URL de recibo, opcional)',
        'is_monthly': 'BOOLEAN (¿es gasto mensual recurrente?)',
      }
    };
    
    print('Estructura propuesta:');
    final columns = proposedStructure['columns'] as Map<String, dynamic>;
    columns.forEach((key, value) {
      print('  $key: $value');
    });
    
    final proposedCategories = [
      'Casa',
      'Luz',
      'Agua',
      'Teléfono/Internet',
      'Materiales de belleza',
      'Suministros',
      'Marketing',
      'Transporte',
      'Seguros',
      'Impuestos',
      'Mantenimiento',
      'Otros'
    ];
    
    print('\nCategorías propuestas:');
    for (int i = 0; i < proposedCategories.length; i++) {
      print('  ${i + 1}. ${proposedCategories[i]}');
    }
  }

  /// Ejecutar análisis completo
  static Future<void> runFullAnalysis() async {
    await initialize();
    await analyzeFinancialTable();
    await checkExpensesTable();
    await proposeExpensesStructure();
  }
}

void main() async {
  await DatabaseAnalyzer.runFullAnalysis();
}
