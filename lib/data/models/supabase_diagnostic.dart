import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDiagnostic {
  static final SupabaseDiagnostic _instance = SupabaseDiagnostic._internal();
  factory SupabaseDiagnostic() => _instance;
  SupabaseDiagnostic._internal();

  late final SupabaseClient _supabase;

  Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'https://vdwbzlgrpblqepuhgwbd.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkd2J6bGdycGJscWVwdWhnd2JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwMjcwNjksImV4cCI6MjA4MDYwMzA2OX0.0wRwPmV2JfgtIPjdu4TVTWGTOnbjSmyOx13l8N-ghKs',
    );
    _supabase = Supabase.instance.client;
  }

  Future<void> runDiagnostic() async {
    print('\n🔍 === SUPABASE DIAGNOSTIC ===\n');
    
    await testConnection();
    await testKnownTables();
    
    print('\n🏁 === DIAGNOSTIC COMPLETED ===\n');
  }

  Future<void> testConnection() async {
    try {
      print('📡 Testing connection...');
      final response = await _supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public')
          .limit(5);
      print('✅ Connection OK! Found ${response.length} tables');
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  }

  Future<void> testKnownTables() async {
    List<String> tables = ['clients', 'clientes', 'services', 'servicios', 'supplies', 'suministros', 'appointments', 'citas'];
    
    for (String table in tables) {
      try {
        final response = await _supabase.from(table).select('*').limit(1);
        print('✅ Table "$table": ${response.length} records');
        
        if (response.isNotEmpty) {
          print('   Fields: ${response.first.keys.join(', ')}');
        }
      } catch (e) {
        print('❌ Table "$table" not found');
      }
    }
  }
}
