import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/clients/clients_screen_improved.dart';
import '../screens/appointments/appointments_screen_enhanced.dart';
import '../screens/services/services_screen_improved.dart';
import '../screens/supplies/supplies_screen_improved.dart';
import '../screens/administration/administration_screen_improved.dart';
import '../../data/models/supabase_manager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final SupabaseManager _supabaseManager = SupabaseManager();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('DEBUG: Initializing Supabase App...');
      await _supabaseManager.initializeSupabase();
      
      if (mounted) {
        setState(() {
          _isInitialized = _supabaseManager.isInitialized;
        });
      }
      
      print('DEBUG: Supabase App initialized: $_isInitialized');
    } catch (e) {
      print('ERROR initializing Supabase App: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    print('DEBUG: Supabase App disposing');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('DEBUG: Supabase App lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('DEBUG: Supabase App resumed - syncing...');
        _supabaseManager.forceSync();
        break;
      case AppLifecycleState.paused:
        print('DEBUG: Supabase App paused');
        break;
      case AppLifecycleState.detached:
        print('DEBUG: Supabase App detached');
        break;
      case AppLifecycleState.inactive:
        print('DEBUG: Supabase App inactive');
        break;
      case AppLifecycleState.hidden:
        print('DEBUG: Supabase App hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'Yalitza Salas',
        theme: AppTheme.lightTheme,
        home: const InitializationScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Yalitza Salas',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_sync,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Conectando con la Nube',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yalitza Salas Bloom',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Inicializando base de datos en la nube...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  final SupabaseManager _supabaseManager = SupabaseManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('DEBUG: Supabase MainScreen initialized');
    
    // Sincronizar cada 30 segundos
    _startPeriodicSync();
  }

  @override
  void dispose() {
    print('DEBUG: Supabase MainScreen disposing');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startPeriodicSync() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        print('DEBUG: Periodic sync triggered');
        _supabaseManager.forceSync();
        _startPeriodicSync(); // Repetir
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('DEBUG: Supabase MainScreen lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('DEBUG: Supabase MainScreen resumed - syncing...');
        _supabaseManager.forceSync();
        break;
      case AppLifecycleState.paused:
        print('DEBUG: Supabase MainScreen paused');
        break;
      case AppLifecycleState.detached:
        print('DEBUG: Supabase MainScreen detached');
        break;
      case AppLifecycleState.inactive:
        print('DEBUG: Supabase MainScreen inactive');
        break;
      case AppLifecycleState.hidden:
        print('DEBUG: Supabase MainScreen hidden');
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
    print('DEBUG: Supabase Tab changed from $_currentIndex to $index - syncing...');
    setState(() {
      _currentIndex = index;
    });
    // Sincronizar con Supabase al cambiar pestaña
    await _supabaseManager.forceSync();
    print('DEBUG: Supabase Data synced after tab change');
  }

  Future<bool> _onWillPop() async {
    print('DEBUG: Supabase Back button pressed - syncing...');
    await _supabaseManager.forceSync();
    print('DEBUG: Supabase Data synced before exit');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text('Yalitza Salas'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Cloud', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(strokeWidth: 2),
                        SizedBox(width: 16),
                        Text('Sincronizando con la nube...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                await _supabaseManager.forceSync();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos sincronizados exitosamente'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              icon: const Icon(Icons.sync),
              tooltip: 'Sincronizar con la nube',
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _onTabChanged(index);
          },
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
