import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Verificando conexión HTTP a Supabase...');
  
  try {
    // URL de prueba para verificar conexión
    final url = Uri.parse('https://dbrlbhtgymicwggahake.supabase.co/rest/v1/');
    
    final request = await HttpClient().getUrl(url);
    request.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE');
    request.headers.set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE');
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Conexión a Supabase REST API exitosa');
      print('📊 Status Code: ${response.statusCode}');
      
      // Intentar listar tablas
      final tablesUrl = Uri.parse('https://dbrlbhtgymicwggahake.supabase.co/rest/v1/expenses?select=count&limit=1');
      final tablesRequest = await HttpClient().getUrl(tablesUrl);
      tablesRequest.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE');
      
      final tablesResponse = await tablesRequest.close();
      
      if (tablesResponse.statusCode == 200) {
        final responseData = await tablesResponse.transform(utf8.decoder).join();
        print('✅ Tabla "expenses" accesible');
        print('📋 Respuesta: $responseData');
      } else {
        print('⚠️  Error accediendo a tabla expenses: ${tablesResponse.statusCode}');
      }
      
    } else {
      print('❌ Error de conexión: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Error crítico: $e');
  }
}
