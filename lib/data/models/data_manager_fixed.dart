// CORRECCIONES PARA DATA_MANAGER - SOLUCIÓN PROBLEMA DE GASTOS $0.00

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

// 2. MÉTODO CORREGIDO: calculateAndSaveMonthlyProfit() - Mejor cálculo de gastos
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

    // MEJORADO: Obtener gastos del mes con soporte para ambos campos (monto/amount y fecha/date)
    final expenses = await _supabase
        .from(_expensesTable!)
        .select('*')
        .or('fecha.gte.${monthStart.toIso8601String()},date.gte.${monthStart.toIso8601String()}')
        .or('fecha.lte.${monthEnd.toIso8601String()},date.lte.${monthEnd.toIso8601String()}');

    double totalExpenses = 0;
    int expensesCount = 0;
    
    print('DEBUG: Procesando ${expenses.length} gastos...');
    
    for (final expense in expenses) {
      // Soporte para ambos campos de cantidad: monto (español) o amount (inglés)
      double? amount;
      
      if (expense['monto'] != null) {
        amount = _asDouble(expense['monto']);
      } else if (expense['amount'] != null) {
        amount = _asDouble(expense['amount']);
      }
      
      if (amount != null && amount > 0) {
        totalExpenses += amount;
        expensesCount++;
        print('DEBUG: Gasto encontrado - ${expense['descripcion'] ?? expense['description'] ?? 'Sin descripción'}: $amount');
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
    
    // Contar gastos del mes para el registro
    int expensesCount = 0;
    try {
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final expenses = await _supabase
          .from(_expensesTable!)
          .select('id')
          .or('fecha.gte.${monthStart.toIso8601String()},date.gte.${monthStart.toIso8601String()}')
          .or('fecha.lte.${monthEnd.toIso8601String()},date.lte.${monthEnd.toIso8601String()}');
      
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
    
    // Obtener gastos del mes actual
    final expenses = await _supabase
        .from(_expensesTable!)
        .select('*')
        .or('fecha.gte.${monthStart.toIso8601String()},date.gte.${monthStart.toIso8601String()}')
        .or('fecha.lte.${monthEnd.toIso8601String()},date.lte.${monthEnd.toIso8601String()}');

    double totalExpenses = 0;
    
    for (final expense in expenses) {
      double? amount;
      
      if (expense['monto'] != null) {
        amount = _asDouble(expense['monto']);
      } else if (expense['amount'] != null) {
        amount = _asDouble(expense['amount']);
      }
      
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

// 5. MÉTODO CORREGIDO: getExpensesForMonth() - Mejor soporte para campos
List<Map<String, dynamic>> getExpensesForMonth(DateTime month) {
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 1).subtract(const Duration(days: 1));
  
  return _expenses.where((expense) {
    DateTime? expenseDate;
    
    // Soporte para ambos campos de fecha
    if (expense['fecha'] != null) {
      expenseDate = expense['fecha'] as DateTime?;
    } else if (expense['date'] != null) {
      expenseDate = expense['date'] as DateTime?;
    }
    
    if (expenseDate == null) return false;
    
    return expenseDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
           expenseDate.isBefore(endOfMonth.add(const Duration(days: 1)));
  }).toList();
}

// 6. MÉTODO CORREGIDO: _calculateMonthlyExpensesByCategory() - Para actualizar totalMonthlyExpenses
void _calculateMonthlyExpensesByCategory() {
  final now = DateTime.now();
  final currentMonthExpenses = getExpensesForMonth(now);
  
  _monthlyExpensesByCategory.clear();
  _totalMonthlyExpenses = 0;
  
  for (final expense in currentMonthExpenses) {
    final category = expense['category']?.toString() ?? 'Sin categoría';
    double? amount;
    
    // Soporte para ambos campos de cantidad
    if (expense['monto'] != null) {
      amount = _asDouble(expense['monto']);
    } else if (expense['amount'] != null) {
      amount = _asDouble(expense['amount']);
    }
    
    if (amount != null && amount > 0) {
      _totalMonthlyExpenses += amount;
      _monthlyExpensesByCategory[category] = (_monthlyExpensesByCategory[category] ?? 0) + amount;
    }
  }
  
  print('DEBUG: Monthly expenses calculated: $_totalMonthlyExpenses');
  print('DEBUG: Expenses by category: $_monthlyExpensesByCategory');
}
