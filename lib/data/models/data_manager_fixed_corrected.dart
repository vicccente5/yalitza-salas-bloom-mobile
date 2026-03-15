// CORRECCIONES PARA DATA_MANAGER - VERSIÓN CORREGIDA
// PROBLEMA: Usar solo campos correctos (monto, fecha) de la tabla expenses

// 1. MÉTODO CORREGIDO: getMonthlyProfits() - Ahora usa la vista corregida
Future<List<Map<String, dynamic>>> getMonthlyProfits() async {
  await _ensureInitialized();
  await _ensureSchemaResolved();
  _lastError = null;
  
  try {
    // Usar la vista corregida monthly_profits_with_expenses
    final profits = await _supabase
        .from('monthly_profits_with_expenses')  // Vista corregida
        .select('*')
        .order('month', ascending: false);

    _monthlyProfits = List<Map<String, dynamic>>.from(profits);
    
    // Debug: Imprimir para verificar que los gastos ya no son 0
    print('DEBUG: Monthly profits loaded:');
    for (final profit in _monthlyProfits.take(3)) {
      print('Mes: ${profit['month']}, Ingresos: ${profit['total_income']}, Gastos: ${profit['total_expenses']}, Ganancia: ${profit['net_profit']}');
    }
    
    return _monthlyProfits;
  } catch (e) {
    print('ERROR en getMonthlyProfits: $e');
    _setError(e);
    return [];
  }
}

// 2. MÉTODO CORREGIDO: calculateAndSaveMonthlyProfit() - Solo campos correctos
Future<bool> calculateAndSaveMonthlyProfit(DateTime month) async {
  await _ensureInitialized();
  await _ensureSchemaResolved();
  _lastError = null;

  try {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    print('DEBUG: Calculando ganancias para ${monthStart.toIso8601String()}');
    
    // Obtener ingresos desde completed_appointments
    final completedAppointments = await _supabase
        .from(_completedAppointmentsTable!)
        .select('*')
        .gte('date_time', monthStart.toIso8601String())
        .lte('date_time', monthEnd.toIso8601String());

    double totalIncome = 0;
    int appointmentsCount = completedAppointments.length;
    
    for (final appointment in completedAppointments) {
      final amount = _asDouble(appointment['amount']);
      if (amount != null && amount > 0) {
        totalIncome += amount;
      }
    }
    
    print('DEBUG: Citas completadas: $appointmentsCount, Ingresos totales: $totalIncome');

    // CORREGIDO: Obtener gastos del mes usando solo campos correctos (monto, fecha)
    final expenses = await _supabase
        .from(_expensesTable!)
        .select('*')
        .gte('fecha', monthStart.toIso8601String())
        .lte('fecha', monthEnd.toIso8601String());

    double totalExpenses = 0;
    int expensesCount = 0;
    
    print('DEBUG: Procesando ${expenses.length} gastos...');
    
    for (final expense in expenses) {
      // SOLO campo correcto: monto
      final amount = _asDouble(expense['monto']);
      
      if (amount != null && amount > 0) {
        totalExpenses += amount;
        expensesCount++;
        print('DEBUG: Gasto encontrado - ${expense['descripcion'] ?? 'Sin descripción'}: $amount');
      }
    }
    
    print('DEBUG: Gastos encontrados: $expensesCount, Total gastos: $totalExpenses');

    // Calcular ganancia neta
    final netProfit = totalIncome - totalExpenses;
    
    print('DEBUG: Ganancia neta calculada: $netProfit');

    // Guardar en monthly_profits con todos los datos
    final success = await saveMonthlyProfit(
      month: month,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      appointmentsCount: appointmentsCount,
    );
    
    if (success) {
      print('DEBUG: Ganancias mensuales guardadas exitosamente');
    } else {
      print('ERROR: No se pudieron guardar las ganancias mensuales');
    }
    
    return success;
  } catch (e) {
    print('ERROR en calculateAndSaveMonthlyProfit: $e');
    _setError(e);
    return false;
  }
}

// 3. MÉTODO CORREGIDO: saveMonthlyProfit() - Mejor manejo de gastos
Future<bool> saveMonthlyProfit({
  required DateTime month,
  required double totalIncome,
  required double totalExpenses,
  required double netProfit,
  required int appointmentsCount,
}) async {
  await _ensureInitialized();
  await _ensureSchemaResolved();
  _lastError = null;
  
  try {
    final monthDate = DateTime(month.year, month.month, 1);
    
    // Contar gastos del mes para el registro (SOLO campo correcto: fecha)
    int expensesCount = 0;
    try {
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final expenses = await _supabase
          .from(_expensesTable!)
          .select('id')
          .gte('fecha', monthStart.toIso8601String())
          .lte('fecha', monthEnd.toIso8601String());
      
      expensesCount = expenses.length;
    } catch (e) {
      print('Error counting expenses: $e');
    }
    
    final data = {
      'month': monthDate.toIso8601String().split('T')[0],
      'total_income': totalIncome,
      'total_expenses': totalExpenses,  // Este campo ahora se guardará correctamente
      'net_profit': netProfit,
      'appointments_count': appointmentsCount,
      'expenses_count': expensesCount,  // Nuevo campo para contar gastos
    };

    // Verificar si ya existe un registro para este mes
    final existing = await _supabase
        .from(_monthlyProfitsTable!)
        .select()
        .eq('month', monthDate.toIso8601String().split('T')[0])
        .maybeSingle();

    Map<String, dynamic> result;
    if (existing != null) {
      // Actualizar registro existente
      result = await _supabase
          .from(_monthlyProfitsTable!)
          .update(data)
          .eq('id', existing['id'])
          .select()
          .single();
      
      // Actualizar en la lista local
      final index = _monthlyProfits.indexWhere((p) => p['id'] == existing['id']);
      if (index != -1) {
        _monthlyProfits[index] = result;
      }
    } else {
      // Insertar nuevo registro
      result = await _supabase
          .from(_monthlyProfitsTable!)
          .insert(data)
          .select()
          .single();
      
      _monthlyProfits.insert(0, result);
    }

    _notifyListeners();
    print('DEBUG: Monthly profit saved: $data');
    return true;
  } catch (e) {
    print('ERROR en saveMonthlyProfit: $e');
    _setError(e);
    return false;
  }
}

// 4. MÉTODO NUEVO: getCurrentMonthExpenses() - Para obtener gastos del mes actual
Future<double> getCurrentMonthExpenses() async {
  await _ensureInitialized();
  await _ensureSchemaResolved();
  _lastError = null;
  
  try {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    // Obtener gastos del mes actual (SOLO campos correctos: monto, fecha)
    final expenses = await _supabase
        .from(_expensesTable!)
        .select('*')
        .gte('fecha', monthStart.toIso8601String())
        .lte('fecha', monthEnd.toIso8601String());

    double totalExpenses = 0;
    
    for (final expense in expenses) {
      // SOLO campo correcto: monto
      final amount = _asDouble(expense['monto']);
      
      if (amount != null && amount > 0) {
        totalExpenses += amount;
      }
    }
    
    print('DEBUG: Current month expenses calculated: $totalExpenses');
    return totalExpenses;
  } catch (e) {
    print('ERROR en getCurrentMonthExpenses: $e');
    _setError(e);
    return 0;
  }
}

// 5. MÉTODO CORREGIDO: getExpensesForMonth() - Solo campo correcto
List<Map<String, dynamic>> getExpensesForMonth(DateTime month) {
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 1).subtract(const Duration(days: 1));
  
  return _expenses.where((expense) {
    // SOLO campo correcto: fecha
    final expenseDate = expense['fecha'] as DateTime?;
    
    if (expenseDate == null) return false;
    
    return expenseDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
           expenseDate.isBefore(endOfMonth.add(const Duration(days: 1)));
  }).toList();
}

// 6. MÉTODO CORREGIDO: _calculateMonthlyExpensesByCategory() - Solo campo correcto
void _calculateMonthlyExpensesByCategory() {
  final now = DateTime.now();
  final currentMonthExpenses = getExpensesForMonth(now);
  
  _monthlyExpensesByCategory.clear();
  _totalMonthlyExpenses = 0;
  
  for (final expense in currentMonthExpenses) {
    final category = expense['category']?.toString() ?? 'Sin categoría';
    
    // SOLO campo correcto: monto
    final amount = _asDouble(expense['monto']);
    
    if (amount != null && amount > 0) {
      _totalMonthlyExpenses += amount;
      _monthlyExpensesByCategory[category] = (_monthlyExpensesByCategory[category] ?? 0) + amount;
    }
  }
  
  print('DEBUG: Monthly expenses calculated: $_totalMonthlyExpenses');
  print('DEBUG: Expenses by category: $_monthlyExpensesByCategory');
}

// 7. MÉTODO CORREGIDO: addExpense() - Solo campos correctos
Future<bool> addExpense(Map<String, dynamic> expense) async {
  await _ensureInitialized();
  await _ensureSchemaResolved();
  _lastError = null;
    
  print('DEBUG: Intentando agregar gasto: $expense');
    
  try {
    final data = {
      'descripcion': expense['description'] ?? '',
      'monto': expense['amount'] ?? 0,  // Mapear amount a monto
      'categoria': expense['category'] ?? '',
      'fecha': (expense['date'] as DateTime).toIso8601String(),
      'notas': expense['notes'] ?? '',
      'receipt_url': expense['receiptUrl'] ?? '',
      'is_monthly': expense['isMonthly'] ?? false,
    };

    print('DEBUG: Enviando a Supabase: $data');
    print('DEBUG: Tabla de gastos: $_expensesTable');

    try {
      print('DEBUG: Insertando en tabla $_expensesTable');
      final inserted = await _supabase.from(_expensesTable!).insert(data).select('*').single();
      print('DEBUG: Inserción exitosa: $inserted');
      _expenses.insert(0, _mapExpenseFromDb(Map<String, dynamic>.from(inserted)));
      _calculateMonthlyExpensesByCategory();
      _notifyListeners();
      print('DEBUG: Gasto agregado exitosamente');
        
      // Actualizar ganancias del mes actual automáticamente
      await updateCurrentMonthProfits();
        
      return true;
    } catch (e) {
      print('ERROR en inserción: $e');
      _setError(e);
      return false;
    }
  } catch (e) {
    print('ERROR en addExpense: $e');
    _setError(e);
    return false;
  }
}
