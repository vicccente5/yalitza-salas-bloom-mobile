import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/clients/clients_screen_improved.dart';
import '../screens/appointments/appointments_screen_enhanced.dart';
import '../screens/services/services_screen_improved.dart';
import '../screens/supplies/supplies_screen_improved.dart';
import '../screens/administration/administration_screen_improved.dart';
import '../../data/models/data_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final DataManager _dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('DEBUG: App initialized, lifecycle observer added');
  }

  @override
  void dispose() {
    print('DEBUG: App disposing, forcing final save...');
    WidgetsBinding.instance.removeObserver(this);
    _dataManager.forceSaveData();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('DEBUG: App lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
        print('DEBUG: App paused - saving data...');
        _dataManager.forceSaveData();
        break;
      case AppLifecycleState.detached:
        print('DEBUG: App detached - final save...');
        _dataManager.forceSaveData();
        break;
      case AppLifecycleState.resumed:
        print('DEBUG: App resumed');
        break;
      case AppLifecycleState.inactive:
        print('DEBUG: App inactive - saving data...');
        _dataManager.forceSaveData();
        break;
      case AppLifecycleState.hidden:
        print('DEBUG: App hidden - saving data...');
        _dataManager.forceSaveData();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yalitza Salas',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final DataManager _dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('DEBUG: MainScreen initialized, lifecycle observer added');
  }

  @override
  void dispose() {
    print('DEBUG: MainScreen disposing, forcing final save...');
    WidgetsBinding.instance.removeObserver(this);
    _dataManager.forceSaveData();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('DEBUG: MainScreen lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
        print('DEBUG: MainScreen paused - saving data...');
        _dataManager.forceSaveData();
        break;
      case AppLifecycleState.detached:
        print('DEBUG: MainScreen detached - final save...');
        _dataManager.forceSaveData();
        break;
      case AppLifecycleState.resumed:
        print('DEBUG: MainScreen resumed');
        break;
      case AppLifecycleState.inactive:
        print('DEBUG: MainScreen inactive - saving data...');
        _dataManager.forceSaveData();
        break;
      case AppLifecycleState.hidden:
        print('DEBUG: MainScreen hidden - saving data...');
        _dataManager.forceSaveData();
        break;
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ClientsScreen(),
    const AppointmentsScreen(),
    const ServicesScreen(),
    const SuppliesScreen(),
    const AdministrationScreen(),
  ];

  Future<void> _onTabChanged(int index) async {
    print('DEBUG: Tab changed from $_currentIndex to $index - saving data...');
    setState(() {
      _currentIndex = index;
    });
    // Guardar datos al cambiar de pestaña
    await _dataManager.forceSaveData();
    print('DEBUG: Data saved after tab change');
  }

  Future<bool> _onWillPop() async {
    print('DEBUG: Back button pressed - saving data...');
    await _dataManager.forceSaveData();
    print('DEBUG: Data saved before exit');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Citas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_outlined),
              activeIcon: Icon(Icons.spa),
              label: 'Servicios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_outlined),
              activeIcon: Icon(Icons.inventory),
              label: 'Suministros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          ],
        ),
      ),
    );
  }
}
