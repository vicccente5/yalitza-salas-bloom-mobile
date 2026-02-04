import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/database/database_manager_bloc.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/dashboard_screen_final.dart';
import '../screens/clients/clients_screen_final.dart';
import '../screens/appointments/appointments_screen_final.dart';
import '../screens/services/services_screen_final.dart';
import '../screens/supplies/supplies_screen_final.dart';
import '../screens/administration/administration_screen_final.dart';

class App extends StatelessWidget {
  const App({super.key});

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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClientsScreen(),
    const AppointmentsScreen(),
    const ServicesScreen(),
    const SuppliesScreen(),
    const AdministrationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DatabaseBloc, DatabaseState>(
        listener: (context, state) {
          if (state is DatabaseStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () {
                    // Reload current screen data
                    switch (_currentIndex) {
                      case 0:
                        context.read<DatabaseBloc>().add(LoadDashboardData());
                        break;
                      case 1:
                        context.read<DatabaseBloc>().add(LoadClients());
                        break;
                      case 2:
                        context.read<DatabaseBloc>().add(LoadAppointments());
                        break;
                      case 3:
                        context.read<DatabaseBloc>().add(LoadServices());
                        break;
                      case 4:
                        context.read<DatabaseBloc>().add(LoadSupplies());
                        break;
                      case 5:
                        context.read<DatabaseBloc>().add(LoadDashboardData());
                        break;
                    }
                  },
                ),
              ),
            );
          }
          if (state is DatabaseStateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Load data for the selected screen
          switch (index) {
            case 0:
              context.read<DatabaseBloc>().add(LoadDashboardData());
              break;
            case 1:
              context.read<DatabaseBloc>().add(LoadClients());
              break;
            case 2:
              context.read<DatabaseBloc>().add(LoadAppointments());
              break;
            case 3:
              context.read<DatabaseBloc>().add(LoadServices());
              break;
            case 4:
              context.read<DatabaseBloc>().add(LoadSupplies());
              break;
            case 5:
              context.read<DatabaseBloc>().add(LoadDashboardData());
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
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
    );
  }
}
