import 'package:flutter/material.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  final List<Map<String, dynamic>> _clients = [
    {
      'id': 1,
      'name': 'Valeska Moreno Salas',
      'phone': '3001234567',
      'email': 'valeska@email.com',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 2,
      'name': 'María González',
      'phone': '3109876543',
      'email': 'maria@email.com',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 3,
      'name': 'Ana Martínez',
      'phone': '3155551234',
      'email': 'ana@email.com',
      'createdAt': DateTime.now().subtract(const Duration(days: 7)),
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'Depilación Facial',
      'description': 'Tratamiento completo con productos de alta calidad',
      'price': 25000.0,
      'duration': 60,
      'category': 'Facial',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'supplies': ['Cera Depilatoria', 'Productos Faciales'],
    },
    {
      'id': 2,
      'name': 'Masaje Relajante',
      'description': 'Sesión completa con aceites esenciales',
      'price': 18000.0,
      'duration': 45,
      'category': 'Relajante',
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
      'supplies': ['Aceites Esenciales', 'Toallas de Masaje'],
    },
    {
      'id': 3,
      'name': 'Limpieza de Pestañas',
      'description': 'Servicio rápido de mantenimiento',
      'price': 15000.0,
      'duration': 30,
      'category': 'Express',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      'supplies': ['Guantes Desechables'],
    },
    {
      'id': 4,
      'name': 'Tratamiento Corporal',
      'description': 'Exfoliación completa del cuerpo',
      'price': 35000.0,
      'duration': 90,
      'category': 'Corporal',
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
      'supplies': ['Productos Faciales', 'Toallas de Masaje'],
    },
    {
      'id': 5,
      'name': 'Peeling Químico',
      'description': 'Renovación celular profunda',
      'price': 28000.0,
      'duration': 75,
      'category': 'Facial',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'supplies': ['Productos Faciales', 'Guantes Desechables'],
    },
  ];

  final List<Map<String, dynamic>> _supplies = [
    {
      'id': 1,
      'name': 'Cera Depilatoria',
      'unitCost': 5000.0,
      'unit': 'kg',
      'currentStock': 15.0,
      'minimumStock': 2.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 2,
      'name': 'Aceites Esenciales',
      'unitCost': 8000.0,
      'unit': 'ml',
      'currentStock': 8.0,
      'minimumStock': 10.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
    },
    {
      'id': 3,
      'name': 'Toallas de Masaje',
      'unitCost': 3000.0,
      'unit': 'unidades',
      'currentStock': 20.0,
      'minimumStock': 5.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 4,
      'name': 'Productos Faciales',
      'unitCost': 12000.0,
      'unit': 'ml',
      'currentStock': 25.0,
      'minimumStock': 8.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 5,
      'name': 'Guantes Desechables',
      'unitCost': 500.0,
      'unit': 'unidades',
      'currentStock': 3.0,
      'minimumStock': 10.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  final List<Map<String, dynamic>> _appointments = [
    {
      'id': 1,
      'clientName': 'Valeska Moreno Salas',
      'serviceName': 'Depilación Facial',
      'dateTime': DateTime.now().add(const Duration(hours: 2)),
      'status': 'scheduled',
      'amount': 25000.0,
    },
    {
      'id': 2,
      'clientName': 'María González',
      'serviceName': 'Masaje Relajante',
      'dateTime': DateTime.now().add(const Duration(hours: 4)),
      'status': 'scheduled',
      'amount': 18000.0,
    },
    {
      'id': 3,
      'clientName': 'Ana Martínez',
      'serviceName': 'Limpieza de Pestañas',
      'dateTime': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'completed',
      'amount': 15000.0,
    },
  ];

  final List<Map<String, dynamic>> _completedAppointments = [
    {
      'id': 1,
      'clientName': 'Valeska Moreno Salas',
      'serviceName': 'Depilación Facial',
      'dateTime': DateTime.now().subtract(const Duration(hours: 2)),
      'amount': 25000.0,
      'status': 'completed',
      'notes': 'Cliente satisfecho, servicio completado exitosamente',
    },
    {
      'id': 2,
      'clientName': 'María González',
      'serviceName': 'Masaje Relajante',
      'dateTime': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 18000.0,
      'status': 'completed',
      'notes': 'Excelente respuesta del cliente',
    },
    {
      'id': 3,
      'clientName': 'Ana Martínez',
      'serviceName': 'Limpieza de Pestañas',
      'dateTime': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 15000.0,
      'status': 'completed',
      'notes': 'Servicio rápido y eficiente',
    },
  ];

  double _monthlyIncome = 150000.0;
  double _monthlyCosts = 30000.0;
  double _monthlyProfit = 120000.0;

  final List<VoidCallback> _listeners = [];

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
