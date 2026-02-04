import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/app/app_simple.dart';
import 'presentation/bloc/database/database_bloc.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = AppDatabase();
  
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: db),
      ],
      child: BlocProvider(
        create: (context) => DatabaseBloc(db),
        child: const App(),
      ),
    ),
  );
}
