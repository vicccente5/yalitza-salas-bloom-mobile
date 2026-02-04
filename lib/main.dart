import 'package:flutter/material.dart';
import 'presentation/app/app_improved.dart';
import 'data/models/data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager().initializeData();
  runApp(const App());
}
