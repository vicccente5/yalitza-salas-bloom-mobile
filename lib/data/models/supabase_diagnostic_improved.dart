import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDiagnosticImproved {
  static final SupabaseDiagnosticImproved _instance = SupabaseDiagnosticImproved._internal();
  factory SupabaseDiagnosticImproved() => _instance;
  SupabaseDiagnosticImproved._internal();

  late final SupabaseClient _supabase;

  Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://vdwbzlgrpblqepuhgwbd.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkd2J6bGdycGJscWVwdWhnd2JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwMjcwNjksImV4cCI6MjA4MDYwMzA2OX0.0wRwPmV2JfgtIPjdu4TVTWGTOnbjSmyOx13l8N-ghKs',
    );
    _supabase = Supabase.instance.client;
  }

  Future<List<String>> runDiagnostic() async {
    List<String> logs = [];
    logs.add('🔍 === SUPABASE DIAGNOSTIC ===');
    
    try {
      // 1. Probar conexión
      logs.add('📡 Testing connection...');
      await _supabase.from('information_schema.tables').select('table_name').limit(1);
      logs.add('✅ Connection successful!');
      
      // 2. Listar todas las tablas posibles
      logs.add('\n📋 Testing all possible table names...');
      
      List<String> possibleTables = [
        'clients', 'clientes', 'customers', 'customer',
        'services', 'servicios', 'treatments', 'treatment',
        'supplies', 'suministros', 'products', 'inventory', 'inventario',
        'appointments', 'citas', 'bookings', 'reservations',
        'users', 'usuarios', 'financial_data', 'datos_financieros', 'config'
      ];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase.from(tableName).select('*').limit(1);
          logs.add('✅ Table "$tableName": ${response.length} records');
          
          if (response.isNotEmpty) {
            String fields = response.first.keys.join(', ');
            logs.add('   Fields: $fields');
            
            // Mostrar un registro de ejemplo
            String example = response.first.toString();
            if (example.length > 100) {
              example = example.substring(0, 100) + '...';
            }
            logs.add('   Example: $example');
          }
        } catch (e) {
          logs.add('❌ Table "$tableName" not found');
        }
      }
      
      // 3. Intentar listar tablas del sistema
      logs.add('\n🔍 Trying to list system tables...');
      try {
        final systemTables = await _supabase
            .from('information_schema.tables')
            .select('table_name')
            .eq('table_schema', 'public');
        
        logs.add('📊 Found ${systemTables.length} system tables:');
        for (var table in systemTables) {
          logs.add('   • ${table['table_name']}');
        }
      } catch (e) {
        logs.add('❌ Could not list system tables: $e');
      }
      
    } catch (e) {
      logs.add('❌ Major error: $e');
    }
    
    logs.add('\n🏁 === DIAGNOSTIC COMPLETED ===');
    return logs;
  }
}
