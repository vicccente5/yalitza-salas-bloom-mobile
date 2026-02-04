import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

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
      final prefs = await SharedPreferences.getInstance();
      
      // Load clients
      final clientsJson = prefs.getString('clients');
      if (clientsJson != null) {
        final clientsList = json.decode(clientsJson) as List;
        _clients.clear();
        _clients.addAll(clientsList.map((e) => Map<String, dynamic>.from(e)));
      }
      
      // Load services
      final servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        final servicesList = json.decode(servicesJson) as List;
        _services.clear();
        _services.addAll(servicesList.map((e) => Map<String, dynamic>.from(e)));
      }
      
      // Load supplies
      final suppliesJson = prefs.getString('supplies');
      if (suppliesJson != null) {
        final suppliesList = json.decode(suppliesJson) as List;
        _supplies.clear();
        _supplies.addAll(suppliesList.map((e) => Map<String, dynamic>.from(e)));
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
      }
      
      // Load financial data
      _monthlyIncome = prefs.getDouble('monthlyIncome') ?? 0.0;
      _monthlyCosts = prefs.getDouble('monthlyCosts') ?? 0.0;
      _monthlyProfit = prefs.getDouble('monthlyProfit') ?? 0.0;
      
      _notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save clients
      await prefs.setString('clients', json.encode(_clients));
      
      // Save services
      await prefs.setString('services', json.encode(_services));
      
      // Save supplies
      await prefs.setString('supplies', json.encode(_supplies));
      
      // Save appointments
      final appointmentsJson = _appointments.map((e) {
        final appointment = Map<String, dynamic>.from(e);
        appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
        return appointment;
      }).toList();
      await prefs.setString('appointments', json.encode(appointmentsJson));
      
      // Save completed appointments
      final completedAppointmentsJson = _completedAppointments.map((e) {
        final appointment = Map<String, dynamic>.from(e);
        appointment['dateTime'] = (appointment['dateTime'] as DateTime).toIso8601String();
        return appointment;
      }).toList();
      await prefs.setString('completedAppointments', json.encode(completedAppointmentsJson));
      
      // Save financial data
      await prefs.setDouble('monthlyIncome', _monthlyIncome);
      await prefs.setDouble('monthlyCosts', _monthlyCosts);
      await prefs.setDouble('monthlyProfit', _monthlyProfit);
    } catch (e) {
      print('Error saving data: $e');
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
    // Guardar datos de forma asíncrona sin bloquear la UI
    _saveData();
  }

  // Método público para forzar guardado manual
  Future<void> forceSaveData() async {
    await _saveData();
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
