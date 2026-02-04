import 'package:flutter/material.dart';
import 'presentation/app/app_persistent.dart';
import 'data/models/data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize data manager and load saved data
  final dataManager = DataManager();
  await dataManager.initializeData();
  
  runApp(const App());
}
