// CORRECCIONES PARA FINANZAS_SCREEN - SOLUCIÓN PROBLEMA DE VISUALIZACIÓN

// 1. MÉTODO CORREGIDO: _buildFinancialSummary() - Ahora muestra gastos reales
Widget _buildFinancialSummary() {
  // Obtener ingresos del mes actual usando el método corregido
  final now = DateTime.now();
  final monthIncome = _dataManager.getMonthlyIncomeForMonth(now);
  
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: monthIncome,
    builder: (context, snapshot) {
      double currentMonthIncome = 0;
      
      if (snapshot.hasData) {
        for (final income in snapshot.data!) {
          currentMonthIncome += (income['amount'] as num?)?.toDouble() ?? 0.0;
        }
      }
      
      // CORREGIDO: Obtener gastos reales del mes actual
      return FutureBuilder<double>(
        future: _dataManager.getCurrentMonthExpenses(), // Nuevo método
        builder: (context, expensesSnapshot) {
          double currentMonthExpenses = 0;
          
          if (expensesSnapshot.hasData) {
            currentMonthExpenses = expensesSnapshot.data!;
          }
          
          final currentMonthProfit = currentMonthIncome - currentMonthExpenses;
          
          print('DEBUG: Financial Summary - Income: $currentMonthIncome, Expenses: $currentMonthExpenses, Profit: $currentMonthProfit');
          
          return Column(
            children: [
              _buildExpenseSummaryItem('Ingresos del Mes:', currentMonthIncome, color: Colors.blue),
              _buildExpenseSummaryItem('Gastos del Mes:', currentMonthExpenses, isBold: true, color: Colors.red),
              _buildExpenseSummaryItem('Ganancia Estimada:', currentMonthProfit, isBold: true, color: currentMonthProfit >= 0 ? Colors.green : Colors.red),
            ],
          );
        },
      );
    },
  );
}

// 2. MÉTODO CORREGIDO: _buildExpenseSummaryItem() - Con colores y mejor visualización
Widget _buildExpenseSummaryItem(String label, double value, {bool isBold = false, Color? color}) {
  final displayColor = color ?? (value >= 0 ? Colors.black87 : Colors.red);
  
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: displayColor.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: displayColor,
          ),
        ),
      ],
    ),
  );
}

// 3. MÉTODO CORREGIDO: _showEditFinancialDialog() - Con valores reales
void _showEditFinancialDialog() {
  final incomeController = TextEditingController(text: _dataManager.monthlyIncome.toStringAsFixed(2));
  final costsController = TextEditingController(text: _dataManager.totalMonthlyExpenses.toStringAsFixed(2)); // Ahora usa el valor real
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Editar Datos Financieros'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: incomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ingresos del Mes',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: costsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Gastos del Mes',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ganancia Estimada:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${(double.tryParse(incomeController.text) ?? 0 - double.tryParse(costsController.text) ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final income = double.tryParse(incomeController.text) ?? 0;
            final costs = double.tryParse(costsController.text) ?? 0;
            
            // Actualizar datos financieros
            _dataManager.updateFinancialData(income: income, costs: costs);
            
            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Datos financieros actualizados'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

// 4. MÉTODO CORREGIDO: _showAddExpenseDialog() - Con mejor manejo de errores
void _showAddExpenseDialog() {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final categoryController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isMonthly = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Agregar Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: categoryController.text.isEmpty ? null : categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  'casa',
                  'luz',
                  'agua',
                  'teléfono/internet',
                  'materiales de belleza',
                  'suministros',
                  'marketing',
                  'transporte',
                  'seguros',
                  'impuestos',
                  'mantenimiento',
                  'otros',
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  categoryController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Gasto mensual recurrente'),
                value: isMonthly,
                onChanged: (value) {
                  setState(() {
                    isMonthly = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descriptionController.text.isEmpty || 
                  amountController.text.isEmpty || 
                  categoryController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos requeridos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor ingresa un monto válido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final expense = {
                'description': descriptionController.text,
                'amount': amount,
                'category': categoryController.text,
                'date': selectedDate,
                'notes': notesController.text,
                'isMonthly': isMonthly,
              };

              // Agregar gasto usando el método corregido
              final success = await _dataManager.addExpense(expense);
              
              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gasto agregado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Actualizar las ganancias del mes actual automáticamente
                await _dataManager.updateCurrentMonthProfits();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al agregar gasto: ${_dataManager.lastError}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
}

// 5. MÉTODO CORREGIDO: _deleteExpense() - Con actualización automática
void _deleteExpense(Map<String, dynamic> expense) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar Gasto'),
      content: Text('¿Estás seguro de que deseas eliminar el gasto "${expense['description'] ?? 'Sin descripción'}" por \$${(expense['amount'] ?? 0).toStringAsFixed(2)}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await _dataManager.deleteExpense(expense['id']);
            
            if (success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gasto eliminado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Actualizar las ganancias del mes actual automáticamente
              await _dataManager.updateCurrentMonthProfits();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al eliminar gasto: ${_dataManager.lastError}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
