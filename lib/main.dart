import 'package:flutter/material.dart';
import 'presentation/app/app_improved.dart';
import 'data/models/data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar locale de forma segura para evitar errores
  try {
    // Forzar inicialización del sistema de localización
    final locale = const Locale('es', 'ES');
    // Esto ayuda a inicializar el sistema interno de fechas
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    print('Error inicializando locale: $e');
  }
  
  await DataManager().initializeData();
  runApp(const App());
}
