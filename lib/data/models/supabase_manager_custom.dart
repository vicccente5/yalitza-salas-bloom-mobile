import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class SupabaseManagerCustom {
  static final SupabaseManagerCustom _instance = SupabaseManagerCustom._internal();
  factory SupabaseManagerCustom() => _instance;
  SupabaseManagerCustom._internal();

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
      print('DEBUG: Initializing Supabase with custom schema...');
      
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

  // Métodos de carga desde Supabase (adaptado a tu esquema)
  Future<void> loadAllData() async {
    if (!_isInitialized) return;

    try {
      print('DEBUG: Loading all data from Supabase with custom schema...');
      
      await Future.wait([
        loadClients(),
        loadServices(),
        loadSupplies(),
        loadAppointments(),
        loadCompletedAppointments(),
        loadFinancialData(),
      ]);

      _notifyListeners();
      print('DEBUG: All data loaded from Supabase successfully');
    } catch (e) {
      print('ERROR loading data from Supabase: $e');
    }
  }

  Future<void> loadClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select('*')
          .order('created_at', ascending: false);

      _clients = List<Map<String, dynamic>>.from(response);
      print('DEBUG: Clients loaded from Supabase: ${_clients.length}');
    } catch (e) {
      print('ERROR loading clients: $e');
    }
  }

  Future<void> loadServices() async {
    try {
      final response = await _supabase
          .from('services')
          .select('*')
          .order('created_at', ascending: false);

      _services = List<Map<String, dynamic>>.from(response);
      print('DEBUG: Services loaded from Supabase: ${_services.length}');
    } catch (e) {
      print('ERROR loading services: $e');
    }
  }

  Future<void> loadSupplies() async {
    try {
      final response = await _supabase
          .from('supplies')
          .select('*')
          .order('created_at', ascending: false);

      _supplies = List<Map<String, dynamic>>.from(response);
      print('DEBUG: Supplies loaded from Supabase: ${_supplies.length}');
    } catch (e) {
      print('ERROR loading supplies: $e');
    }
  }

  Future<void> loadAppointments() async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('*')
          .order('date_time', ascending: true);

      _appointments = List<Map<String, dynamic>>.from(response);
      print('DEBUG: Appointments loaded from Supabase: ${_appointments.length}');
    } catch (e) {
      print('ERROR loading appointments: $e');
    }
  }

  Future<void> loadCompletedAppointments() async {
    try {
      final response = await _supabase
          .from('completed_appointments')
          .select('*')
          .order('date_time', ascending: false);

      _completedAppointments = List<Map<String, dynamic>>.from(response);
      print('DEBUG: Completed appointments loaded from Supabase: ${_completedAppointments.length}');
    } catch (e) {
      print('ERROR loading completed appointments: $e');
    }
  }

  Future<void> loadFinancialData() async {
    try {
      final response = await _supabase
          .from('financial_data')
          .select('*')
          .limit(1);

      if (response.isNotEmpty) {
        final data = response.first;
        _monthlyIncome = (data['monthly_income'] ?? 0.0).toDouble();
        _monthlyCosts = (data['monthly_costs'] ?? 0.0).toDouble();
        _monthlyProfit = (data['monthly_profit'] ?? 0.0).toDouble();
      }
      
      print('DEBUG: Financial data loaded from Supabase: Income=$_monthlyIncome, Costs=$_monthlyCosts, Profit=$_monthlyProfit');
    } catch (e) {
      print('ERROR loading financial data: $e');
    }
  }

  // Métodos de CRUD para Clients
  Future<void> addClient(Map<String, dynamic> client) async {
    if (!_isInitialized) return;

    try {
      final response = await _supabase
          .from('clients')
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
      
      print('DEBUG: Client added to Supabase: ${client['name']}');
    } catch (e) {
      print('ERROR adding client: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    if (!_isInitialized) return;

    try {
      await _supabase.from('clients').delete().eq('id', id);
      _clients.removeWhere((client) => client['id'] == id);
      _notifyListeners();
      
      print('DEBUG: Client deleted from Supabase: $id');
    } catch (e) {
      print('ERROR deleting client: $e');
    }
  }

  // Métodos de CRUD para Services
  Future<void> addService(Map<String, dynamic> service) async {
    if (!_isInitialized) return;

    try {
      final response = await _supabase
          .from('services')
          .insert({
            'name': service['name'],
            'description': service['description'],
            'price': service['price'],
            'duration': service['duration'],
            'category': service['category'],
            'supplies': service['supplies'],
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      _services.insert(0, response);
      _notifyListeners();
      
      print('DEBUG: Service added to Supabase: ${service['name']}');
    } catch (e) {
      print('ERROR adding service: $e');
    }
  }

  Future<void> deleteService(int id) async {
    if (!_isInitialized) return;

    try {
      await _supabase.from('services').delete().eq('id', id);
      _services.removeWhere((service) => service['id'] == id);
      _notifyListeners();
      
      print('DEBUG: Service deleted from Supabase: $id');
    } catch (e) {
      print('ERROR deleting service: $e');
    }
  }

  // Métodos de CRUD para Supplies
  Future<void> addSupply(Map<String, dynamic> supply) async {
    if (!_isInitialized) return;

    try {
      final response = await _supabase
          .from('supplies')
          .insert({
            'name': supply['name'],
            'unit_cost': supply['unitCost'],
            'unit': supply['unit'],
            'current_stock': supply['currentStock'],
            'minimum_stock': supply['minimumStock'],
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      _supplies.insert(0, response);
      _notifyListeners();
      
      print('DEBUG: Supply added to Supabase: ${supply['name']}');
    } catch (e) {
      print('ERROR adding supply: $e');
    }
  }

  Future<void> updateSupply(int id, Map<String, dynamic> updates) async {
    if (!_isInitialized) return;

    try {
      final response = await _supabase
          .from('supplies')
          .update({
            'name': updates['name'],
            'unit_cost': updates['unitCost'],
            'unit': updates['unit'],
            'current_stock': updates['currentStock'],
            'minimum_stock': updates['minimumStock'],
          })
          .eq('id', id)
          .select()
          .single();

      final index = _supplies.indexWhere((supply) => supply['id'] == id);
      if (index != -1) {
        _supplies[index] = response;
        _notifyListeners();
      }
      
      print('DEBUG: Supply updated in Supabase: $id');
    } catch (e) {
      print('ERROR updating supply: $e');
    }
  }

  Future<void> deleteSupply(int id) async {
    if (!_isInitialized) return;

    try {
      await _supabase.from('supplies').delete().eq('id', id);
      _supplies.removeWhere((supply) => supply['id'] == id);
      _notifyListeners();
      
      print('DEBUG: Supply deleted from Supabase: $id');
    } catch (e) {
      print('ERROR deleting supply: $e');
    }
  }

  // Métodos de CRUD para Appointments
  Future<void> addAppointment(Map<String, dynamic> appointment) async {
    if (!_isInitialized) return;

    try {
      final response = await _supabase
          .from('appointments')
          .insert({
            'client_name': appointment['clientName'],
            'service_name': appointment['serviceName'],
            'date_time': (appointment['dateTime'] as DateTime).toIso8601String(),
            'status': appointment['status'],
            'amount': appointment['amount'],
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      _appointments.add(response);
      _notifyListeners();
      
      print('DEBUG: Appointment added to Supabase: ${appointment['clientName']}');
    } catch (e) {
      print('ERROR adding appointment: $e');
    }
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    if (!_isInitialized) return;

    try {
      final appointment = _appointments.firstWhere((apt) => apt['id'] == id);
      
      if (status == 'completed') {
        // Mover a completed_appointments
        await _supabase.from('completed_appointments').insert({
          'client_name': appointment['client_name'],
          'service_name': appointment['service_name'],
          'date_time': appointment['date_time'],
          'amount': appointment['amount'],
          'notes': 'Cita completada exitosamente',
          'created_at': DateTime.now().toIso8601String(),
        });

        // Eliminar de appointments
        await _supabase.from('appointments').delete().eq('id', id);
        
        // Actualizar finanzas
        _monthlyIncome += appointment['amount'];
        _monthlyProfit += appointment['amount'];
        await updateFinancialData();
        
        _appointments.removeWhere((apt) => apt['id'] == id);
        _completedAppointments.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          'client_name': appointment['client_name'],
          'service_name': appointment['service_name'],
          'date_time': appointment['date_time'],
          'amount': appointment['amount'],
          'notes': 'Cita completada exitosamente',
        });
      } else {
        // Actualizar status
        await _supabase.from('appointments').update({'status': status}).eq('id', id);
        
        final index = _appointments.indexWhere((apt) => apt['id'] == id);
        if (index != -1) {
          _appointments[index]['status'] = status;
        }
      }
      
      _notifyListeners();
      print('DEBUG: Appointment status updated in Supabase: $id -> $status');
    } catch (e) {
      print('ERROR updating appointment status: $e');
    }
  }

  Future<void> updateAppointment(int id, Map<String, dynamic> updates) async {
    if (!_isInitialized) return;

    try {
      final response = await _supabase
          .from('appointments')
          .update({
            'client_name': updates['clientName'],
            'service_name': updates['serviceName'],
            'date_time': (updates['dateTime'] as DateTime).toIso8601String(),
            'amount': updates['amount'],
          })
          .eq('id', id)
          .select()
          .single();

      final index = _appointments.indexWhere((apt) => apt['id'] == id);
      if (index != -1) {
        _appointments[index] = response;
        _notifyListeners();
      }
      
      print('DEBUG: Appointment updated in Supabase: $id');
    } catch (e) {
      print('ERROR updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(int id) async {
    if (!_isInitialized) return;

    try {
      await _supabase.from('appointments').delete().eq('id', id);
      _appointments.removeWhere((appointment) => appointment['id'] == id);
      _notifyListeners();
      
      print('DEBUG: Appointment deleted from Supabase: $id');
    } catch (e) {
      print('ERROR deleting appointment: $e');
    }
  }

  Future<void> deleteCompletedAppointment(int id) async {
    if (!_isInitialized) return;

    try {
      final appointment = _completedAppointments.firstWhere((apt) => apt['id'] == id);
      
      await _supabase.from('completed_appointments').delete().eq('id', id);
      
      _monthlyIncome -= appointment['amount'];
      _monthlyProfit -= appointment['amount'];
      await updateFinancialData();
      
      _completedAppointments.removeWhere((apt) => apt['id'] == id);
      _notifyListeners();
      
      print('DEBUG: Completed appointment deleted from Supabase: $id');
    } catch (e) {
      print('ERROR deleting completed appointment: $e');
    }
  }

  // Métodos para Financial Data
  Future<void> updateFinancialData({double? income, double? costs}) async {
    if (!_isInitialized) return;

    try {
      if (income != null) _monthlyIncome = income;
      if (costs != null) _monthlyCosts = costs;
      _monthlyProfit = _monthlyIncome - _monthlyCosts;

      await _supabase.from('financial_data').upsert({
        'id': 1,
        'monthly_income': _monthlyIncome,
        'monthly_costs': _monthlyCosts,
        'monthly_profit': _monthlyProfit,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      _notifyListeners();
      print('DEBUG: Financial data updated in Supabase: Income=$_monthlyIncome, Costs=$_monthlyCosts, Profit=$_monthlyProfit');
    } catch (e) {
      print('ERROR updating financial data: $e');
    }
  }

  // Métodos de utilidad
  int get totalClients => _clients.length;
  int get activeServices => _services.length;
  int get todayAppointments => _appointments.where((appointment) {
    final now = DateTime.now();
    final appointmentDate = DateTime.parse(appointment['date_time']);
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }).length;

  int get todayCompletedAppointments => _completedAppointments.where((appointment) {
    final now = DateTime.now();
    final appointmentDate = DateTime.parse(appointment['date_time']);
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }).length;

  List<Map<String, dynamic>> getAppointmentsForDay(DateTime day) {
    return _appointments.where((appointment) {
      final appointmentDate = DateTime.parse(appointment['date_time']);
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
          final appointmentDate = DateTime.parse(appointment['date_time']);
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
}
