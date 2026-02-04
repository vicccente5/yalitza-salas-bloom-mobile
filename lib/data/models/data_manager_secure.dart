import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DataManagerSecure {
  static final DataManagerSecure _instance = DataManagerSecure._internal();
  factory DataManagerSecure() => _instance;
  DataManagerSecure._internal();

  final List<Map<String, dynamic>> _clients = [];
  final List<Map<String, dynamic>> _services = [];
  final List<Map<String, dynamic>> _supplies = [];
  final List<Map<String, dynamic>> _appointments = [];
  final List<Map<String, dynamic>> _completedAppointments = [];

  double _monthlyIncome = 0.0;
  double _monthlyCosts = 0.0;
  double _monthlyProfit = 0.0;

  final List<VoidCallback> _listeners = [];

  Future<void> _loadData() async {
    try {
      print('DEBUG: Starting SECURE data loading...');
      
      // Método 1: SharedPreferences (primario)
      final prefs = await SharedPreferences.getInstance();
      bool loadedFromPrefs = false;
      
      // Load clients
      final clientsJson = prefs.getString('clients');
      if (clientsJson != null) {
        final clientsList = json.decode(clientsJson) as List;
        _clients.clear();
        _clients.addAll(clientsList.map((e) => Map<String, dynamic>.from(e)));
        print('DEBUG: Clients loaded from SharedPreferences: ${_clients.length}');
        loadedFromPrefs = true;
      }
      
      // Load services
      final servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        final servicesList = json.decode(servicesJson) as List;
        _services.clear();
        _services.addAll(servicesList.map((e) => Map<String, dynamic>.from(e)));
        print('DEBUG: Services loaded from SharedPreferences: ${_services.length}');
        loadedFromPrefs = true;
      }
      
      // Load supplies
      final suppliesJson = prefs.getString('supplies');
      if (suppliesJson != null) {
        final suppliesList = json.decode(suppliesJson) as List;
        _supplies.clear();
        _supplies.addAll(suppliesList.map((e) => Map<String, dynamic>.from(e)));
        print('DEBUG: Supplies loaded from SharedPreferences: ${_supplies.length}');
        loadedFromPrefs = true;
      }
      
      // Load appointments
      final appointmentsJson = prefs.getString('appointments');
      if (appointmentsJson != null) {
        final appointmentsList = json.decode(appointmentsJson) as List;
        _appointments.clear();
        _appointments.addAll(appointmentsList.map((e) {
          final appointment = Map<String, dynamic>.from(e);
          appointment['dateTime'] = DateTime.parse(appointment['dateTime']);
          return appointment;
        }));
        print('DEBUG: Appointments loaded from SharedPreferences: ${_appointments.length}');
        loadedFromPrefs = true;
      }
      
      // Load completed appointments
      final completedAppointmentsJson = prefs.getString('completedAppointments');
      if (completedAppointmentsJson != null) {
        final completedAppointmentsList = json.decode(completedAppointmentsJson) as List;
        _completedAppointments.clear();
        _completedAppointments.addAll(completedAppointmentsList.map((e) {
          final appointment = Map<String, dynamic>.from(e);
          appointment['dateTime'] = DateTime.parse(appointment['dateTime']);
          return appointment;
        }));
        print('DEBUG: Completed appointments loaded from SharedPreferences: ${_completedAppointments.length}');
        loadedFromPrefs = true;
      }
      
      // Load financial data
      _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 0.0;
      _monthlyCosts = prefs.getDouble('monthlyCosts') ?? 0.0;
      _monthlyProfit = prefs.getDouble('monthlyProfit') ?? 0.0;
      print('DEBUG: Financial data loaded from SharedPreferences: Income=$_monthlyIncome, Costs=$_monthlyCosts, Profit=$_monthlyProfit');
      
      // Método 2: Archivo local (backup si SharedPreferences falla)
      if (!loadedFromPrefs) {
        print('DEBUG: SharedPreferences empty, trying file backup...');
        await _loadFromFile();
      }
      
      _notifyListeners();
      print('DEBUG: SECURE data load completed successfully!');
    } catch (e) {
      print('ERROR loading SECURE data: $e');
      // Intentar cargar desde archivo como último recurso
      await _loadFromFile();
    }
  }

  Future<void> _loadFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/yalitza_data.json');
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents);
        
        if (data['clients'] != null) {
          _clients.clear();
          _clients.addAll(List<Map<String, dynamic>>.from(data['clients']));
          print('DEBUG: Clients loaded from file: ${_clients.length}');
        }
        
        if (data['services'] != null) {
          _services.clear();
          _services.addAll(List<Map<String, dynamic>>.from(data['services']));
          print('DEBUG: Services loaded from file: ${_services.length}');
        }
        
        if (data['supplies'] != null) {
          _supplies.clear();
          _supplies.addAll(List<Map<String, dynamic>>.from(data['supplies']));
          print('DEBUG: Supplies loaded from file: ${_supplies.length}');
        }
        
        if (data['appointments'] != null) {
          _appointments.clear();
          _appointments.addAll(List<Map<String, dynamic>>.from(data['appointments']).map((e) {
            e['dateTime'] = DateTime.parse(e['dateTime']);
            return e;
          }));
          print('DEBUG: Appointments loaded from file: ${_appointments.length}');
        }
        
        if (data['completedAppointments'] != null) {
          _completedAppointments.clear();
          _completedAppointments.addAll(List<Map<String, dynamic>>.from(data['completedAppointments']).map((e) {
            e['dateTime'] = DateTime.parse(e['dateTime']);
            return e;
          }));
          print('DEBUG: Completed appointments loaded from file: ${_completedAppointments.length}');
        }
        
        if (data['monthlyIncome'] != null) _monthlyIncome = data['monthlyIncome'];
        if (data['monthlyCosts'] != null) _monthlyCosts = data['monthlyCosts'];
        if (data['monthlyProfit'] != null) _monthlyProfit = data['monthlyProfit'];
        
        print('DEBUG: File backup load completed');
      }
    } catch (e) {
      print('ERROR loading from file: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      print('DEBUG: Starting SECURE save data...');
      
      // Método 1: SharedPreferences (primario)
      final prefs = await SharedPreferences.getInstance();
      
      // Save clients
      await prefs.setString('clients', json.encode(_clients));
      print('DEBUG: SECURE Clients saved: ${_clients.length}');
      
      // Save services
      await prefs.setString('services', json.encode(_services));
      print('DEBUG: SECURE Services saved: ${_services.length}');
      
      // Save supplies
      await prefs.setString('supplies', json.encode(_supplies));
      print('DEBUG: SECURE Supplies saved: ${_supplies.length}');
      
      // Save appointments
      final appointmentsJson = _appointments.map((e) {
        final appointment = Map<String, dynamic>.from(e);
        appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
        return appointment;
      }).toList();
      await prefs.setString('appointments', json.encode(appointmentsJson));
      print('DEBUG: SECURE Appointments saved: ${_appointments.length}');
      
      // Save completed appointments
      final completedAppointmentsJson = _completedAppointments.map((e) {
        final appointment = Map<String, dynamic>.from(e);
        appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
        return appointment;
      }).toList();
      await prefs.setString('completedAppointments', json.encode(completedAppointmentsJson));
      print('DEBUG: SECURE Completed appointments saved: ${_completedAppointments.length}');
      
      // Save financial data
      await prefs.setDouble('monthlyIncome', _monthlyIncome);
      await prefs.setDouble('monthlyCosts', _monthlyCosts);
      await prefs.setDouble('monthlyProfit', _monthlyProfit);
      print('DEBUG: SECURE Financial data saved: Income=$_monthlyIncome, Costs=$_monthlyCosts, Profit=$_monthlyProfit');
      
      // Forzar commit de datos
      await prefs.reload();
      print('DEBUG: SharedPreferences save completed!');
      
      // Método 2: Archivo local (backup)
      await _saveToFile();
      
      print('DEBUG: SECURE data save completed successfully!');
    } catch (e) {
      print('ERROR saving SECURE data: $e');
      // Intentar guardar en archivo como fallback
      await _saveToFile();
    }
  }

  Future<void> _saveToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/yalitza_data.json');
      
      final data = {
        'clients': _clients,
        'services': _services,
        'supplies': _supplies,
        'appointments': _appointments.map((e) {
          final appointment = Map<String, dynamic>.from(e);
          appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
          return appointment;
        }).toList(),
        'completedAppointments': _completedAppointments.map((e) {
          final appointment = Map<String, dynamic>.from(e);
          appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
          return appointment;
        }).toList(),
        'monthlyIncome': _monthlyIncome,
        'monthlyCosts': _monthlyCosts,
        'monthlyProfit': _monthlyProfit,
        'lastSaved': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(data));
      print('DEBUG: File backup save completed');
    } catch (e) {
      print('ERROR saving to file: $e');
    }
  }

  Future<void> initializeData() async {
    await _loadData();
  }

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
    _saveData();
  }

  Future<void> forceSaveData() async {
    print('DEBUG: Force SECURE save data called...');
    await _saveData();
    print('DEBUG: Force SECURE save data completed');
  }

  void syncSaveData() {
    print('DEBUG: Sync SECURE save data called...');
    try {
      final prefsFuture = SharedPreferences.getInstance();
      prefsFuture.then((prefs) async {
        try {
          await prefs.setString('clients', json.encode(_clients));
          await prefs.setString('services', json.encode(_services));
          await prefs.setString('supplies', json.encode(_supplies));
          
          final appointmentsJson = _appointments.map((e) {
            final appointment = Map<String, dynamic>.from(e);
            appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
            return appointment;
          }).toList();
          await prefs.setString('appointments', json.encode(appointmentsJson));
          
          final completedAppointmentsJson = _completedAppointments.map((e) {
            final appointment = Map<String, dynamic>.from(e);
            appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
            return appointment;
          }).toList();
          await prefs.setString('completedAppointments', json.encode(completedAppointmentsJson));
          
          await prefs.setDouble('monthlyIncome', _monthlyIncome);
          await prefs.setDouble('monthlyCosts', _monthlyCosts);
          await prefs.setDouble('monthlyProfit', _monthlyProfit);
          
          await prefs.reload();
          print('DEBUG: Sync SECURE save completed successfully!');
          
          // También guardar en archivo
          await _saveToFile();
        } catch (e) {
          print('ERROR in sync SECURE save: $e');
        }
      });
    } catch (e) {
      print('ERROR starting sync SECURE save: $e');
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

  // Client operations
  void addClient(Map<String, dynamic> client) {
    _clients.add(client);
    _notifyListeners();
  }

  void deleteClient(int id) {
    _clients.removeWhere((client) => client['id'] == id);
    _notifyListeners();
  }

  // Service operations
  void addService(Map<String, dynamic> service) {
    _services.add(service);
    _notifyListeners();
  }

  void deleteService(int id) {
    _services.removeWhere((service) => service['id'] == id);
    _notifyListeners();
  }

  // Supply operations
  void addSupply(Map<String, dynamic> supply) {
    _supplies.add(supply);
    _notifyListeners();
  }

  void updateSupply(int id, Map<String, dynamic> updates) {
    final index = _supplies.indexWhere((supply) => supply['id'] == id);
    if (index != -1) {
      _supplies[index] = {..._supplies[index], ...updates};
      _notifyListeners();
    }
  }

  void deleteSupply(int id) {
    _supplies.removeWhere((supply) => supply['id'] == id);
    _notifyListeners();
  }

  // Appointment operations
  void addAppointment(Map<String, dynamic> appointment) {
    _appointments.add(appointment);
    _notifyListeners();
  }

  void updateAppointmentStatus(int id, String status) {
    final index = _appointments.indexWhere((appointment) => appointment['id'] == id);
    if (index != -1) {
      _appointments[index]['status'] = status;
      
      if (status == 'completed') {
        final completedAppointment = {
          ..._appointments[index],
          'notes': 'Cita completada exitosamente',
        };
        _completedAppointments.add(completedAppointment);
        _monthlyIncome += _appointments[index]['amount'];
        _monthlyProfit += _appointments[index]['amount'];
      } else if (status == 'canceled') {
        _monthlyIncome -= _appointments[index]['amount'];
        _monthlyProfit -= _appointments[index]['amount'];
      }
      
      _notifyListeners();
    }
  }

  void updateAppointment(int id, Map<String, dynamic> updates) {
    final index = _appointments.indexWhere((appointment) => appointment['id'] == id);
    if (index != -1) {
      _appointments[index] = {..._appointments[index], ...updates};
      _notifyListeners();
    }
  }

  void deleteAppointment(int id) {
    _appointments.removeWhere((appointment) => appointment['id'] == id);
    _notifyListeners();
  }

  void deleteCompletedAppointment(int id) {
    final index = _completedAppointments.indexWhere((appointment) => appointment['id'] == id);
    if (index != -1) {
      _monthlyIncome -= _completedAppointments[index]['amount'];
      _monthlyProfit -= _completedAppointments[index]['amount'];
      _completedAppointments.removeAt(index);
      _notifyListeners();
    }
  }

  // Financial operations
  void updateFinancialData({double? income, double? costs}) {
    if (income != null) _monthlyIncome = income;
    if (costs != null) _monthlyCosts = costs;
    _monthlyProfit = _monthlyIncome - _monthlyCosts;
    _notifyListeners();
  }

  // Statistics
  int get totalClients => _clients.length;
  int get activeServices => _services.length;
  int get todayAppointments => _appointments.where((appointment) {
    final now = DateTime.now();
    final appointmentDate = appointment['dateTime'] as DateTime;
    return appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }).length;

  int get todayCompletedAppointments => _appointments.where((appointment) {
    final now = DateTime.now();
    final appointmentDate = appointment['dateTime'] as DateTime;
    return appointment['status'] == 'completed' &&
           appointmentDate.year == now.year &&
           appointmentDate.month == now.month &&
           appointmentDate.day == now.day;
  }).length;

  List<Map<String, dynamic>> getAppointmentsForDay(DateTime day) {
    return _appointments.where((appointment) {
      final appointmentDate = appointment['dateTime'] as DateTime;
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
          final appointmentDate = appointment['dateTime'] as DateTime;
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
}
