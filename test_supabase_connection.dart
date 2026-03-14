import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 Iniciando prueba de conexión a Supabase...');
  
  try {
    // Inicializar Supabase
    await Supabase.initialize(
      url: 'https://dbrlbhtgymicwggahake.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE',
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Conexión a Supabase establecida correctamente');
    
    // Lista de tablas a verificar
    final tables = [
      'clients',
      'clientes', 
      'services',
      'servicios',
      'appointments',
      'citas',
      'completed_appointments',
      'citas_completadas',
      'expenses',
      'gastos',
      'monthly_income',
      'monthly_profits',
      'ganancias_mensuales',
      'financial_data',
      'expense_categories',
      'categorias_gastos'
    ];
    
    print('\n📋 Verificando estructura de tablas...');
    
    for (final table in tables) {
      try {
        final result = await supabase.from(table).select('*').limit(1);
        print('✅ Tabla "$table" - ACCESIBLE (${result.length} registros)');
      } catch (e) {
        if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
          print('❌ Tabla "$table" - NO EXISTE');
        } else {
          print('⚠️  Tabla "$table" - ERROR: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}...');
        }
      }
    }
    
    // Probar inserción básica
    print('\n🧪 Probando inserción de datos...');
    try {
      final testData = {
        'test_field': 'Test Data ${DateTime.now()}',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Intentar insertar en expenses
      try {
        await supabase.from('expenses').insert({
          'description': 'Test Expense',
          'amount': 100.0,
          'category': 'Test',
          'fecha': DateTime.now().toIso8601String(),
        });
        print('✅ Inserción en expenses exitosa');
      } catch (e) {
        print('❌ Error insertando en expenses: $e');
      }
      
    } catch (e) {
      print('❌ Error general en prueba de inserción: $e');
    }
    
    print('\n🎯 Prueba de conexión completada');
    
  } catch (e) {
    print('❌ Error crítico de conexión: $e');
    exit(1);
  }
}
