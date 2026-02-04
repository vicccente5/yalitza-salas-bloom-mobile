import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class SupabaseManagerAdaptive {
  static final SupabaseManagerAdaptive _instance = SupabaseManagerAdaptive._internal();
  factory SupabaseManagerAdaptive() => _instance;
  SupabaseManagerAdaptive._internal();

  late final SupabaseClient _supabase;
  final List<VoidCallback> _listeners = [];

  // Variables locales para cache
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _supplies = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _completedAppointments = [];

  double _monthlyIncome = 0.0;
  double _monthlyCosts = 0.0;
  double _monthlyProfit = 0.0;

  bool _isInitialized = false;

  Future<void> initializeSupabase() async {
    try {
      print('DEBUG: Initializing Supabase with adaptive schema...');
      
      await Supabase.initialize(
        url: 'https://vdwbzlgrpblqepuhgwbd.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkd2J6bGdycGJscWVwdWhnd2JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwMjcwNjksImV4cCI6MjA4MDYwMzA2OX0.0wRwPmV2JfgtIPjdu4TVTWGTOnbjSmyOx13l8N-ghKs',
      );

      _supabase = Supabase.instance.client;
      _isInitialized = true;
      
      print('DEBUG: Supabase initialized successfully');
      await loadAllData();
    } catch (e) {
      print('ERROR initializing Supabase: $e');
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Getters
  List<Map<String, dynamic>> get clients => List.from(_clients);
  List<Map<String, dynamic>> get services => List.from(_services);
  List<Map<String, dynamic>> get supplies => List.from(_supplies);
  List<Map<String, dynamic>> get appointments => List.from(_appointments);
  List<Map<String, dynamic>> get completedAppointments => List.from(_completedAppointments);
  double get monthlyIncome => _monthlyIncome;
  double get monthlyCosts => _monthlyCosts;
  double get monthlyProfit => _monthlyProfit;

  // Métodos de carga desde Supabase (adaptativo)
  Future<void> loadAllData() async {
    if (!_isInitialized) return;

    try {
      print('DEBUG: Loading all data from Supabase with adaptive schema...');
      
      await Future.wait([
        loadClientsAdaptive(),
        loadServicesAdaptive(),
        loadSuppliesAdaptive(),
        loadAppointmentsAdaptive(),
        loadCompletedAppointmentsAdaptive(),
        loadFinancialDataAdaptive(),
      ]);

      _notifyListeners();
      print('DEBUG: All data loaded from Supabase successfully');
    } catch (e) {
      print('ERROR loading data from Supabase: $e');
    }
  }

  Future<void> loadClientsAdaptive() async {
    try {
      // Intentar diferentes nombres de tabla comunes
      List<String> possibleTables = ['clients', 'clientes', 'customers', 'customer'];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*')
              .order('created_at', ascending: false);

          _clients = List<Map<String, dynamic>>.from(response);
          print('DEBUG: Clients loaded from Supabase table "$tableName": ${_clients.length}');
          return;
        } catch (e) {
          print('DEBUG: Table "$tableName" not found, trying next...');
          continue;
        }
      }
      
      print('WARNING: No clients table found in database');
    } catch (e) {
      print('ERROR loading clients: $e');
    }
  }

  Future<void> loadServicesAdaptive() async {
    try {
      List<String> possibleTables = ['services', 'servicios', 'treatments', 'treatment'];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*')
              .order('created_at', ascending: false);

          _services = List<Map<String, dynamic>>.from(response);
          print('DEBUG: Services loaded from Supabase table "$tableName": ${_services.length}');
          return;
        } catch (e) {
          print('DEBUG: Table "$tableName" not found, trying next...');
          continue;
        }
      }
      
      print('WARNING: No services table found in database');
    } catch (e) {
      print('ERROR loading services: $e');
    }
  }

  Future<void> loadSuppliesAdaptive() async {
    try {
      List<String> possibleTables = ['supplies', 'suministros', 'products', 'inventory', 'inventario'];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*')
              .order('created_at', ascending: false);

          _supplies = List<Map<String, dynamic>>.from(response);
          print('DEBUG: Supplies loaded from Supabase table "$tableName": ${_supplies.length}');
          return;
        } catch (e) {
          print('DEBUG: Table "$tableName" not found, trying next...');
          continue;
        }
      }
      
      print('WARNING: No supplies table found in database');
    } catch (e) {
      print('ERROR loading supplies: $e');
    }
  }

  Future<void> loadAppointmentsAdaptive() async {
    try {
      List<String> possibleTables = ['appointments', 'citas', 'bookings', 'reservations'];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*')
              .order('date_time', ascending: true);

          _appointments = List<Map<String, dynamic>>.from(response);
          print('DEBUG: Appointments loaded from Supabase table "$tableName": ${_appointments.length}');
          return;
        } catch (e) {
          print('DEBUG: Table "$tableName" not found, trying next...');
          continue;
        }
      }
      
      print('WARNING: No appointments table found in database');
    } catch (e) {
      print('ERROR loading appointments: $e');
    }
  }

  Future<void> loadCompletedAppointmentsAdaptive() async {
    try {
      List<String> possibleTables = ['completed_appointments', 'citas_completadas', 'completed_bookings'];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*')
              .order('date_time', ascending: false);

          _completedAppointments = List<Map<String, dynamic>>.from(response);
          print('DEBUG: Completed appointments loaded from Supabase table "$tableName": ${_completedAppointments.length}');
          return;
        } catch (e) {
          print('DEBUG: Table "$tableName" not found, trying next...');
          continue;
        }
      }
      
      print('WARNING: No completed appointments table found in database');
    } catch (e) {
      print('ERROR loading completed appointments: $e');
    }
  }

  Future<void> loadFinancialDataAdaptive() async {
    try {
      List<String> possibleTables = ['financial_data', 'datos_financieros', 'financials', 'config'];
      
      for (String tableName in possibleTables) {
        try {
          final response = await _supabase
              .from(tableName)
              .select('*')
              .limit(1);

          if (response.isNotEmpty) {
            final data = response.first;
            _monthlyIncome = (data['monthly_income'] ?? data['ingresos'] ?? data['income'] ?? 0.0).toDouble();
            _monthlyCosts = (data['monthly_costs'] ?? data['costos'] ?? data['costs'] ?? 0.0).toDouble();
            _monthlyProfit = (data['monthly_profit'] ?? data['ganancias'] ?? data['profit'] ?? 0.0).toDouble();
          }
          
          print('DEBUG: Financial data loaded from Supabase table "$tableName": Income=$_monthlyIncome, Costs=$_monthlyCosts, Profit=$_monthlyProfit');
          return;
        } catch (e) {
          print('DEBUG: Table "$tableName" not found, trying next...');
          continue;
        }
      }
      
      print('WARNING: No financial data table found in database');
    } catch (e) {
      print('ERROR loading financial data: $e');
    }
  }

  // Métodos de CRUD adaptativos
  Future<void> addClient(Map<String, dynamic> client) async {
    if (!_isInitialized) return;

    try {
      // Intentar encontrar la tabla correcta
      String tableName = await _findTable(['clients', 'clientes', 'customers', 'customer']);
      
      final response = await _supabase
          .from(tableName)
          .insert({
            'name': client['name'],
            'phone': client['phone'],
            'email': client['email'],
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      _clients.insert(0, response);
      _notifyListeners();
      
      print('DEBUG: Client added to Supabase table "$tableName": ${client['name']}');
    } catch (e) {
      print('ERROR adding client: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    if (!_isInitialized) return;

    try {
      String tableName = await _findTable(['clients', 'clientes', 'customers', 'customer']);
      
      await _supabase.from(tableName).delete().eq('id', id);
      _clients.removeWhere((client) => client['id'] == id);
      _notifyListeners();
      
      print('DEBUG: Client deleted from Supabase table "$tableName": $id');
    } catch (e) {
      print('ERROR deleting client: $e');
    }
  }

  Future<String> _findTable(List<String> possibleTables) async {
    for (String tableName in possibleTables) {
      try {
        await _supabase.from(tableName).select('*').limit(1);
        return tableName;
      } catch (e) {
        continue;
      }
    }
    return possibleTables.first; // fallback
  }

  // Métodos similares para services, supplies, appointments...
  // (Implementación adaptativa para cada entidad)

  // Métodos de utilidad
  int get totalClients => _clients.length;
  int get activeServices => _services.length;
  int get todayAppointments => _appointments.where((appointment) {
    final now = DateTime.now();
    DateTime appointmentDate;
    
    try {
      appointmentDate = DateTime.parse(appointment['date_time']);
    } catch (e) {
      // Intentar otros campos de fecha posibles
      try {
        appointmentDate = DateTime.parse(appointment['dateTime']);
      } catch (e2) {
        return false;
      }
    }
    
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }).length;

  int get todayCompletedAppointments => _completedAppointments.where((appointment) {
    final now = DateTime.now();
    DateTime appointmentDate;
    
    try {
      appointmentDate = DateTime.parse(appointment['date_time']);
    } catch (e) {
      try {
        appointmentDate = DateTime.parse(appointment['dateTime']);
      } catch (e2) {
        return false;
      }
    }
    
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }).length;

  List<Map<String, dynamic>> getAppointmentsForDay(DateTime day) {
    return _appointments.where((appointment) {
      DateTime appointmentDate;
      
      try {
        appointmentDate = DateTime.parse(appointment['date_time']);
      } catch (e) {
        try {
          appointmentDate = DateTime.parse(appointment['dateTime']);
        } catch (e2) {
          return false;
        }
      }
      
      return appointmentDate.year == day.year &&
             appointmentDate.month == day.month &&
             appointmentDate.day == day.day;
    }).toList();
  }

  List<String> getAvailableHours(DateTime day) {
    final List<String> hours = [];
    for (int hour = 8; hour <= 20; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final appointmentTime = DateTime(day.year, day.month, day.day, hour, minute);
        
        final isBooked = _appointments.any((appointment) {
          DateTime appointmentDate;
          
          try {
            appointmentDate = DateTime.parse(appointment['date_time']);
          } catch (e) {
            try {
              appointmentDate = DateTime.parse(appointment['dateTime']);
            } catch (e2) {
              return false;
            }
          }
          
          return appointmentDate.year == appointmentTime.year &&
                 appointmentDate.month == appointmentTime.month &&
                 appointmentDate.day == appointmentTime.day &&
                 appointmentDate.hour == appointmentTime.hour &&
                 appointmentDate.minute == appointmentTime.minute;
        });
        
        if (!isBooked) {
          hours.add(timeStr);
        }
      }
    }
    return hours;
  }

  // Método de sincronización forzada
  Future<void> forceSync() async {
    if (!_isInitialized) return;
    
    print('DEBUG: Force syncing with Supabase...');
    await loadAllData();
    print('DEBUG: Force sync completed');
  }

  // Métodos placeholder para las demás operaciones
  Future<void> addService(Map<String, dynamic> service) async {
    if (!_isInitialized) return;
    print('DEBUG: addService called - needs implementation');
  }

  Future<void> deleteService(int id) async {
    if (!_isInitialized) return;
    print('DEBUG: deleteService called - needs implementation');
  }

  Future<void> addSupply(Map<String, dynamic> supply) async {
    if (!_isInitialized) return;
    print('DEBUG: addSupply called - needs implementation');
  }

  Future<void> updateSupply(int id, Map<String, dynamic> updates) async {
    if (!_isInitialized) return;
    print('DEBUG: updateSupply called - needs implementation');
  }

  Future<void> deleteSupply(int id) async {
    if (!_isInitialized) return;
    print('DEBUG: deleteSupply called - needs implementation');
  }

  Future<void> addAppointment(Map<String, dynamic> appointment) async {
    if (!_isInitialized) return;
    print('DEBUG: addAppointment called - needs implementation');
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    if (!_isInitialized) return;
    print('DEBUG: updateAppointmentStatus called - needs implementation');
  }

  Future<void> updateAppointment(int id, Map<String, dynamic> updates) async {
    if (!_isInitialized) return;
    print('DEBUG: updateAppointment called - needs implementation');
  }

  Future<void> deleteAppointment(int id) async {
    if (!_isInitialized) return;
    print('DEBUG: deleteAppointment called - needs implementation');
  }

  Future<void> deleteCompletedAppointment(int id) async {
    if (!_isInitialized) return;
    print('DEBUG: deleteCompletedAppointment called - needs implementation');
  }

  Future<void> updateFinancialData({double? income, double? costs}) async {
    if (!_isInitialized) return;
    print('DEBUG: updateFinancialData called - needs implementation');
  }
}
