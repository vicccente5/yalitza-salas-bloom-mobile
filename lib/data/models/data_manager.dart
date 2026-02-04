import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  static const String _supabaseUrl = 'https://dbrlbhtgymicwggahake.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRicmxiaHRneW1pY3dnZ2FoYWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzcyNzAsImV4cCI6MjA4NTgxMzI3MH0.xcZtWEHWPIrCgudAOvHjIuqDdYoYbacXR_Xy_zd9uPE';

  bool _isInitialized = false;
  late final SupabaseClient _supabase;
  Future<void>? _initFuture;

  bool _schemaResolved = false;
  Future<void>? _schemaFuture;
  String? _clientsTable;
  String? _servicesTable;
  String? _suppliesTable;
  String? _appointmentsTable;
  String? _completedAppointmentsTable;
  String? _financialTable;

  String? _lastError;
  String? get lastError => _lastError;

  final List<Map<String, dynamic>> _clients = [];
  final List<Map<String, dynamic>> _services = [];
  final List<Map<String, dynamic>> _supplies = [];
  final List<Map<String, dynamic>> _appointments = [];
  final List<Map<String, dynamic>> _completedAppointments = [];

  double _monthlyIncome = 0.0;
  double _monthlyCosts = 0.0;
  double _monthlyProfit = 0.0;

  final List<VoidCallback> _listeners = [];

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = () async {
      // If another part of the app already initialized Supabase, reuse it.
      try {
        _supabase = Supabase.instance.client;
        _isInitialized = true;
        return;
      } catch (_) {
        // Not initialized yet
      }

      await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
      _supabase = Supabase.instance.client;
      _isInitialized = true;
    }();

    return _initFuture;
  }

  Future<void> _ensureSchemaResolved() async {
    await _ensureInitialized();
    if (_schemaResolved) return;
    if (_schemaFuture != null) return _schemaFuture;

    _schemaFuture = () async {
      Future<String?> resolve(List<String> candidates) async {
        for (final t in candidates) {
          try {
            await _supabase.from(t).select('*').limit(1);
            return t;
          } catch (_) {
            continue;
          }
        }
        return null;
      }

      _clientsTable = await resolve(['clients', 'clientes', 'customers', 'customer']);
      _servicesTable = await resolve(['services', 'servicios', 'treatments', 'treatment']);
      _suppliesTable = await resolve(['supplies', 'suministros', 'products', 'inventory', 'inventario']);
      _appointmentsTable = await resolve(['appointments', 'citas', 'bookings', 'reservations']);
      _completedAppointmentsTable = await resolve(['completed_appointments', 'citas_completadas', 'completed_bookings']);
      _financialTable = await resolve(['financial_data', 'finanzas', 'financial', 'datos_financieros']);

      _clientsTable ??= 'clients';
      _servicesTable ??= 'services';
      _suppliesTable ??= 'supplies';
      _appointmentsTable ??= 'appointments';
      _completedAppointmentsTable ??= 'completed_appointments';
      _financialTable ??= 'financial_data';

      _schemaResolved = true;
    }();

    return _schemaFuture;
  }

  void _setError(Object e) {
    final raw = e.toString();
    final missingColumnMatch = RegExp(r"Could not find the '([^']+)' column of '([^']+)'", caseSensitive: false).firstMatch(raw);
    if (missingColumnMatch != null) {
      final col = missingColumnMatch.group(1);
      final table = missingColumnMatch.group(2);
      _lastError = 'La tabla "$table" no tiene la columna "$col". Ajusta tu esquema en Supabase o avísame el nombre correcto de la columna.';
    } else {
      _lastError = raw;
    }
    print('ERROR DataManager: $_lastError');
  }

  bool _isMissingColumn(Object e, {required String table, required String column}) {
    final raw = e.toString();
    return raw.contains('PGRST204') &&
        raw.toLowerCase().contains("could not find the '$column' column of '$table'".toLowerCase());
  }

  Future<List> _selectAllWithOrderFallback(
    String table, {
    required String orderColumn,
    required bool ascending,
  }) async {
    try {
      return await _supabase.from(table).select('*').order(orderColumn, ascending: ascending);
    } catch (e) {
      if (_isMissingColumn(e, table: table, column: orderColumn)) {
        return await _supabase.from(table).select('*');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _insertSingleWithFallback(
    String table,
    List<Map<String, dynamic>> candidates,
  ) async {
    Object? last;
    for (final data in candidates) {
      try {
        final inserted = await _supabase.from(table).insert(data).select('*').single();
        return Map<String, dynamic>.from(inserted);
      } catch (e) {
        last = e;
      }
    }
    throw last ?? Exception('Insert failed');
  }

  Future<Map<String, dynamic>> _updateSingleWithFallback(
    String table,
    Object id,
    List<Map<String, dynamic>> candidates,
  ) async {
    Object? last;
    for (final data in candidates) {
      if (data.isEmpty) continue;
      try {
        final updated = await _supabase.from(table).update(data).eq('id', id).select('*').single();
        return Map<String, dynamic>.from(updated);
      } catch (e) {
        last = e;
      }
    }
    throw last ?? Exception('Update failed');
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  DateTime _asDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  Map<String, dynamic> _mapClientFromDb(Map<String, dynamic> row) {
    final createdAtRaw = row['created_at'] ?? row['createdAt'];
    return {
      'id': row['id'],
      'name': row['name'] ?? row['nombre'] ?? '',
      'phone': row['phone'] ?? row['telefono'] ?? '',
      'email': row['email'] ?? '',
      'createdAt': _asDateTime(createdAtRaw),
    };
  }

  Map<String, dynamic> _mapServiceFromDb(Map<String, dynamic> row) {
    final createdAtRaw = row['created_at'] ?? row['createdAt'];
    return {
      'id': row['id'],
      'name': row['name'] ?? row['nombre'] ?? '',
      'description': row['description'] ?? row['descripcion'] ?? '',
      'price': _asDouble(row['price'] ?? row['precio'] ?? 0),
      'duration': _asInt(row['duration'] ?? row['duracion'] ?? 0),
      'category': row['category'] ?? row['categoria'] ?? 'Otro',
      'createdAt': _asDateTime(createdAtRaw),
      'supplies': (row['supplies'] is List) ? List<String>.from(row['supplies']) : <String>[],
    };
  }

  Map<String, dynamic> _mapSupplyFromDb(Map<String, dynamic> row) {
    final createdAtRaw = row['created_at'] ?? row['createdAt'];
    return {
      'id': row['id'],
      'name': row['name'] ?? row['nombre'] ?? '',
      'unitCost': _asDouble(row['unit_cost'] ?? row['unitCost'] ?? row['costo_unitario'] ?? 0),
      'unit': row['unit'] ?? row['unidad'] ?? '',
      'currentStock': _asDouble(row['current_stock'] ?? row['currentStock'] ?? row['stock_actual'] ?? 0),
      'minimumStock': _asDouble(row['minimum_stock'] ?? row['minimumStock'] ?? row['stock_minimo'] ?? 0),
      'createdAt': _asDateTime(createdAtRaw),
    };
  }

  Map<String, dynamic> _mapAppointmentFromDb(Map<String, dynamic> row) {
    final dateRaw = row['date_time'] ?? row['dateTime'] ?? row['fecha_hora'];
    return {
      'id': row['id'],
      'clientName': row['client_name'] ?? row['clientName'] ?? row['cliente'] ?? '',
      'serviceName': row['service_name'] ?? row['serviceName'] ?? row['servicio'] ?? '',
      'dateTime': _asDateTime(dateRaw),
      'status': row['status'] ?? 'scheduled',
      'amount': _asDouble(row['amount'] ?? row['monto'] ?? 0),
    };
  }

  Map<String, dynamic> _mapCompletedAppointmentFromDb(Map<String, dynamic> row) {
    final dateRaw = row['date_time'] ?? row['dateTime'] ?? row['fecha_hora'];
    return {
      'id': row['id'],
      'clientName': row['client_name'] ?? row['clientName'] ?? row['cliente'] ?? '',
      'serviceName': row['service_name'] ?? row['serviceName'] ?? row['servicio'] ?? '',
      'dateTime': _asDateTime(dateRaw),
      'status': 'completed',
      'amount': _asDouble(row['amount'] ?? row['monto'] ?? 0),
      'notes': row['notes'] ?? row['nota'] ?? '',
    };
  }

  Future<void> _loadFromSupabase() async {
    await _ensureInitialized();
    await _ensureSchemaResolved();

    try {
      final clientsRows = await _selectAllWithOrderFallback(
        _clientsTable!,
        orderColumn: 'created_at',
        ascending: false,
      );
      _clients
        ..clear()
        ..addAll((clientsRows as List).map((e) => _mapClientFromDb(Map<String, dynamic>.from(e))));
      print('DEBUG: Supabase clients loaded: ${_clients.length}');
    } catch (e) {
      print('ERROR loading clients from Supabase: $e');
    }

    try {
      final servicesRows = await _selectAllWithOrderFallback(
        _servicesTable!,
        orderColumn: 'created_at',
        ascending: false,
      );
      _services
        ..clear()
        ..addAll((servicesRows as List).map((e) => _mapServiceFromDb(Map<String, dynamic>.from(e))));
      print('DEBUG: Supabase services loaded: ${_services.length}');
    } catch (e) {
      print('ERROR loading services from Supabase: $e');
    }

    try {
      final suppliesRows = await _selectAllWithOrderFallback(
        _suppliesTable!,
        orderColumn: 'created_at',
        ascending: false,
      );
      _supplies
        ..clear()
        ..addAll((suppliesRows as List).map((e) => _mapSupplyFromDb(Map<String, dynamic>.from(e))));
      print('DEBUG: Supabase supplies loaded: ${_supplies.length}');
    } catch (e) {
      print('ERROR loading supplies from Supabase: $e');
    }

    try {
      final appointmentsRows = await _selectAllWithOrderFallback(
        _appointmentsTable!,
        orderColumn: 'date_time',
        ascending: true,
      );
      _appointments
        ..clear()
        ..addAll((appointmentsRows as List).map((e) => _mapAppointmentFromDb(Map<String, dynamic>.from(e))));
      print('DEBUG: Supabase appointments loaded: ${_appointments.length}');
    } catch (e) {
      print('ERROR loading appointments from Supabase: $e');
    }

    try {
      final completedRows = await _selectAllWithOrderFallback(
        _completedAppointmentsTable!,
        orderColumn: 'date_time',
        ascending: false,
      );
      _completedAppointments
        ..clear()
        ..addAll((completedRows as List).map((e) => _mapCompletedAppointmentFromDb(Map<String, dynamic>.from(e))));
      print('DEBUG: Supabase completed appointments loaded: ${_completedAppointments.length}');
    } catch (e) {
      print('ERROR loading completed appointments from Supabase: $e');
    }

    try {
      final financialRows = await _supabase.from(_financialTable!).select('*').limit(1);
      if ((financialRows as List).isNotEmpty) {
        final row = Map<String, dynamic>.from(financialRows.first);
        _monthlyIncome = (row['monthly_income'] ?? 0).toDouble();
        _monthlyCosts = (row['monthly_costs'] ?? 0).toDouble();
        _monthlyProfit = (row['monthly_profit'] ?? (_monthlyIncome - _monthlyCosts)).toDouble();
      }
      print('DEBUG: Supabase financial loaded: Income=$_monthlyIncome Costs=$_monthlyCosts Profit=$_monthlyProfit');
    } catch (e) {
      print('ERROR loading financial data from Supabase: $e');
    }

    _notifyListeners();
  }

  Future<void> initializeData() async {
    await _loadFromSupabase();
  }

  Future<void> refreshFromCloud() async {
    await _loadFromSupabase();
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
  }

  Future<void> forceSaveData() async {
    await refreshFromCloud();
  }

  void syncSaveData() {
    refreshFromCloud();
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
  Future<bool> addClient(Map<String, dynamic> client) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      final inserted = await _insertSingleWithFallback(_clientsTable!, [
        {
          'name': client['name'],
          'phone': client['phone'],
          'email': client['email'],
        },
        {
          'nombre': client['name'],
          'telefono': client['phone'],
          'email': client['email'],
        },
        {
          'nombre': client['name'],
          'telefono': client['phone'],
          'correo': client['email'],
        },
      ]);
      _clients.insert(0, _mapClientFromDb(Map<String, dynamic>.from(inserted)));
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> deleteClient(Object id) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      await _supabase.from(_clientsTable!).delete().eq('id', id);
      _clients.removeWhere((c) => c['id'] == id);
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Service operations
  Future<bool> addService(Map<String, dynamic> service) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      final base = {
        'name': service['name'],
        'description': service['description'],
        'price': service['price'],
        'duration': service['duration'],
        'category': service['category'],
        'supplies': service['supplies'],
      };

      final baseEs = {
        'nombre': service['name'],
        'descripcion': service['description'],
        'precio': service['price'],
        'duracion': service['duration'],
        'categoria': service['category'],
        'suministros': service['supplies'],
      };

      Map<String, dynamic> inserted;
      try {
        inserted = await _insertSingleWithFallback(_servicesTable!, [base, baseEs]);
      } catch (e) {
        if (_isMissingColumn(e, table: _servicesTable!, column: 'supplies')) {
          final withoutSupplies = Map<String, dynamic>.from(base)..remove('supplies');
          inserted = await _insertSingleWithFallback(_servicesTable!, [withoutSupplies, baseEs]);
        } else if (_isMissingColumn(e, table: _servicesTable!, column: 'suministros')) {
          final withoutSuppliesEs = Map<String, dynamic>.from(baseEs)..remove('suministros');
          inserted = await _insertSingleWithFallback(_servicesTable!, [base, withoutSuppliesEs]);
        } else {
          rethrow;
        }
      }
      _services.insert(0, _mapServiceFromDb(Map<String, dynamic>.from(inserted)));
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> updateService(Object id, Map<String, dynamic> updates) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;

    final data = <String, dynamic>{};
    if (updates.containsKey('name')) data['name'] = updates['name'];
    if (updates.containsKey('description')) data['description'] = updates['description'];
    if (updates.containsKey('price')) data['price'] = updates['price'];
    if (updates.containsKey('duration')) data['duration'] = updates['duration'];
    if (updates.containsKey('category')) data['category'] = updates['category'];
    if (updates.containsKey('supplies')) data['supplies'] = updates['supplies'];

    if (data.isEmpty) return true;

    try {
      Map<String, dynamic> updated;
      try {
        final dataEs = <String, dynamic>{};
        if (updates.containsKey('name')) dataEs['nombre'] = updates['name'];
        if (updates.containsKey('description')) dataEs['descripcion'] = updates['description'];
        if (updates.containsKey('price')) dataEs['precio'] = updates['price'];
        if (updates.containsKey('duration')) dataEs['duracion'] = updates['duration'];
        if (updates.containsKey('category')) dataEs['categoria'] = updates['category'];
        if (updates.containsKey('supplies')) dataEs['suministros'] = updates['supplies'];

        updated = await _updateSingleWithFallback(_servicesTable!, id, [data, dataEs]);
      } catch (e) {
        if (_isMissingColumn(e, table: _servicesTable!, column: 'supplies')) {
          final withoutSupplies = Map<String, dynamic>.from(data)..remove('supplies');
          updated = await _updateSingleWithFallback(_servicesTable!, id, [withoutSupplies]);
        } else if (_isMissingColumn(e, table: _servicesTable!, column: 'suministros')) {
          final withoutSupplies = Map<String, dynamic>.from(data);
          updated = await _updateSingleWithFallback(_servicesTable!, id, [withoutSupplies]);
        } else {
          rethrow;
        }
      }
      final index = _services.indexWhere((s) => s['id'] == id);
      if (index != -1) {
        _services[index] = _mapServiceFromDb(Map<String, dynamic>.from(updated));
        _notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> deleteService(Object id) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      await _supabase.from(_servicesTable!).delete().eq('id', id);
      _services.removeWhere((s) => s['id'] == id);
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Supply operations
  Future<bool> addSupply(Map<String, dynamic> supply) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      final snake = {
        'name': supply['name'],
        'unit_cost': supply['unitCost'],
        'unit': supply['unit'],
        'current_stock': supply['currentStock'],
        'minimum_stock': supply['minimumStock'],
      };
      final camel = {
        'name': supply['name'],
        'unitCost': supply['unitCost'],
        'unit': supply['unit'],
        'currentStock': supply['currentStock'],
        'minimumStock': supply['minimumStock'],
      };

      final esSnake = {
        'nombre': supply['name'],
        'costo_unitario': supply['unitCost'],
        'unidad': supply['unit'],
        'stock_actual': supply['currentStock'],
        'stock_minimo': supply['minimumStock'],
      };

      final inserted = await _insertSingleWithFallback(_suppliesTable!, [snake, camel, esSnake]);
      _supplies.insert(0, _mapSupplyFromDb(Map<String, dynamic>.from(inserted)));
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> updateSupply(Object id, Map<String, dynamic> updates) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;

    final data = <String, dynamic>{};
    if (updates.containsKey('name')) data['name'] = updates['name'];
    if (updates.containsKey('unitCost')) data['unit_cost'] = updates['unitCost'];
    if (updates.containsKey('unit')) data['unit'] = updates['unit'];
    if (updates.containsKey('currentStock')) data['current_stock'] = updates['currentStock'];
    if (updates.containsKey('minimumStock')) data['minimum_stock'] = updates['minimumStock'];

    if (data.isEmpty) return true;

    try {
      final camel = <String, dynamic>{};
      if (updates.containsKey('name')) camel['name'] = updates['name'];
      if (updates.containsKey('unitCost')) camel['unitCost'] = updates['unitCost'];
      if (updates.containsKey('unit')) camel['unit'] = updates['unit'];
      if (updates.containsKey('currentStock')) camel['currentStock'] = updates['currentStock'];
      if (updates.containsKey('minimumStock')) camel['minimumStock'] = updates['minimumStock'];

      final es = <String, dynamic>{};
      if (updates.containsKey('name')) es['nombre'] = updates['name'];
      if (updates.containsKey('unitCost')) es['costo_unitario'] = updates['unitCost'];
      if (updates.containsKey('unit')) es['unidad'] = updates['unit'];
      if (updates.containsKey('currentStock')) es['stock_actual'] = updates['currentStock'];
      if (updates.containsKey('minimumStock')) es['stock_minimo'] = updates['minimumStock'];

      final updated = await _updateSingleWithFallback(_suppliesTable!, id, [data, camel, es]);
      final index = _supplies.indexWhere((s) => s['id'] == id);
      if (index != -1) {
        _supplies[index] = _mapSupplyFromDb(Map<String, dynamic>.from(updated));
        _notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> deleteSupply(Object id) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      await _supabase.from(_suppliesTable!).delete().eq('id', id);
      _supplies.removeWhere((s) => s['id'] == id);
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // Appointment operations
  Future<bool> addAppointment(Map<String, dynamic> appointment) async {
    await _ensureInitialized();
    await _ensureSchemaResolved();
    _lastError = null;
    try {
      final dataEn = <String, dynamic>{
        'client_name': appointment['clientName'],
        'service_name': appointment['serviceName'],
        'date_time': (appointment['dateTime'] as DateTime).toIso8601String(),
        'status': appointment['status'] ?? 'scheduled',
      };
      final dataEnAmount = Map<String, dynamic>.from(dataEn);
      if (appointment.containsKey('amount')) dataEnAmount['amount'] = appointment['amount'];
      final dataEnMonto = Map<String, dynamic>.from(dataEn);
      if (appointment.containsKey('amount')) dataEnMonto['monto'] = appointment['amount'];

      final dataEs = <String, dynamic>{
        'cliente': appointment['clientName'],
        'servicio': appointment['serviceName'],
        'fecha_hora': (appointment['dateTime'] as DateTime).toIso8601String(),
        'status': appointment['status'] ?? 'scheduled',
      };
      final dataEsMonto = Map<String, dynamic>.from(dataEs);
      if (appointment.containsKey('amount')) dataEsMonto['monto'] = appointment['amount'];

      Map<String, dynamic> inserted;
      try {
        inserted = await _insertSingleWithFallback(_appointmentsTable!, [
          dataEnAmount,
          dataEnMonto,
          dataEn,
          dataEsMonto,
          dataEs,
        ]);
      } catch (e) {
        if (_isMissingColumn(e, table: _appointmentsTable!, column: 'amount')) {
          inserted = await _insertSingleWithFallback(_appointmentsTable!, [dataEn, dataEs]);
        } else {
          rethrow;
        }
      }
      _appointments.add(_mapAppointmentFromDb(Map<String, dynamic>.from(inserted)));
      _notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  void updateAppointmentStatus(Object id, String status) {
    () async {
      await _ensureInitialized();
      await _ensureSchemaResolved();
      final index = _appointments.indexWhere((a) => a['id'] == id);
      if (index == -1) return;
      final appointment = _appointments[index];

      try {
        if (status == 'completed') {
          try {
            final completed = <String, dynamic>{
              'client_name': appointment['clientName'],
              'service_name': appointment['serviceName'],
              'date_time': (appointment['dateTime'] as DateTime).toIso8601String(),
              'notes': 'Cita completada exitosamente',
            };
            if (appointment.containsKey('amount')) {
              completed['amount'] = appointment['amount'];
            }

            try {
              await _supabase.from(_completedAppointmentsTable!).insert(completed);
            } catch (e) {
              if (_isMissingColumn(e, table: _completedAppointmentsTable!, column: 'amount')) {
                final withoutAmount = Map<String, dynamic>.from(completed)..remove('amount');
                await _supabase.from(_completedAppointmentsTable!).insert(withoutAmount);
              } else {
                rethrow;
              }
            }
            await _supabase.from(_appointmentsTable!).delete().eq('id', id);
            _appointments.removeAt(index);
            _completedAppointments.insert(0, {
              ...appointment,
              'notes': 'Cita completada exitosamente',
            });
            final amount = _asDouble(appointment['amount']);
            _monthlyIncome += amount;
            _monthlyProfit = _monthlyIncome - _monthlyCosts;
            updateFinancialData();
          } catch (e) {
            await _supabase.from(_appointmentsTable!).update({'status': status}).eq('id', id);
            _appointments[index]['status'] = status;
          }
        } else {
          await _supabase.from(_appointmentsTable!).update({'status': status}).eq('id', id);
          _appointments[index]['status'] = status;
        }
        _notifyListeners();
      } catch (e) {
        print('ERROR updateAppointmentStatus Supabase: $e');
      }
    }();
  }

  void updateAppointment(Object id, Map<String, dynamic> updates) {
    () async {
      await _ensureInitialized();
      await _ensureSchemaResolved();
      try {
        final data = <String, dynamic>{
          'client_name': updates['clientName'],
          'service_name': updates['serviceName'],
          'date_time': (updates['dateTime'] as DateTime).toIso8601String(),
        };
        if (updates.containsKey('amount')) {
          data['amount'] = updates['amount'];
        }

        Map<String, dynamic> updated;
        try {
          updated = await _updateSingleWithFallback(_appointmentsTable!, id, [data]);
        } catch (e) {
          if (_isMissingColumn(e, table: _appointmentsTable!, column: 'amount')) {
            final withoutAmount = Map<String, dynamic>.from(data)..remove('amount');
            updated = await _updateSingleWithFallback(_appointmentsTable!, id, [withoutAmount]);
          } else {
            rethrow;
          }
        }
        final index = _appointments.indexWhere((a) => a['id'] == id);
        if (index != -1) {
          _appointments[index] = _mapAppointmentFromDb(Map<String, dynamic>.from(updated));
          _notifyListeners();
        }
      } catch (e) {
        print('ERROR updateAppointment Supabase: $e');
      }
    }();
  }

  void deleteAppointment(Object id) {
    () async {
      await _ensureInitialized();
      await _ensureSchemaResolved();
      try {
        await _supabase.from(_appointmentsTable!).delete().eq('id', id);
        _appointments.removeWhere((a) => a['id'] == id);
        _notifyListeners();
      } catch (e) {
        print('ERROR deleteAppointment Supabase: $e');
      }
    }();
  }

  void deleteCompletedAppointment(Object id) {
    () async {
      await _ensureInitialized();
      await _ensureSchemaResolved();
      final index = _completedAppointments.indexWhere((a) => a['id'] == id);
      if (index == -1) return;
      final amount = (_completedAppointments[index]['amount'] ?? 0).toDouble();
      try {
        await _supabase.from(_completedAppointmentsTable!).delete().eq('id', id);
        _monthlyIncome -= amount;
        _monthlyProfit = _monthlyIncome - _monthlyCosts;
        updateFinancialData();
        _completedAppointments.removeAt(index);
        _notifyListeners();
      } catch (e) {
        print('ERROR deleteCompletedAppointment Supabase: $e');
      }
    }();
  }

  // Financial operations
  void updateFinancialData({double? income, double? costs}) {
    () async {
      await _ensureInitialized();
      await _ensureSchemaResolved();
      if (income != null) _monthlyIncome = income;
      if (costs != null) _monthlyCosts = costs;
      _monthlyProfit = _monthlyIncome - _monthlyCosts;
      try {
        await _supabase.from(_financialTable!).upsert({
          'id': 1,
          'monthly_income': _monthlyIncome,
          'monthly_costs': _monthlyCosts,
          'monthly_profit': _monthlyProfit,
        });
      } catch (e) {
        print('ERROR updateFinancialData Supabase: $e');
      }
      _notifyListeners();
    }();
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

  int get todayCompletedAppointments => _completedAppointments.where((appointment) {
    final now = DateTime.now();
    final appointmentDate = appointment['dateTime'] as DateTime;
    return appointmentDate.year == now.year &&
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
