import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/data_manager.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  final DataManager _dataManager = DataManager();
  final TextEditingController _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _incomeController.text = _dataManager.monthlyIncome.toString();
    _dataManager.addListener(_updateUI);
  }

  @override
  void dispose() {
    _dataManager.removeListener(_updateUI);
    _incomeController.dispose();
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {
        _incomeController.text = _dataManager.monthlyIncome.toString();
      });
    }
  }

  void _showEditFinancialDialog() {
    final incomeController = TextEditingController(text: _dataManager.monthlyIncome.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Datos Financieros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: incomeController,
              decoration: const InputDecoration(
                labelText: 'Ingresos del mes',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Gastos:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildExpenseSummaryItem('Casa', _dataManager.casaExpenses),
                  _buildExpenseSummaryItem('Luz', _dataManager.luzExpenses),
                  _buildExpenseSummaryItem('Agua', _dataManager.aguaExpenses),
                  _buildExpenseSummaryItem('Teléfono/Internet', _dataManager.telefonoInternetExpenses),
                  _buildExpenseSummaryItem('Materiales de Belleza', _dataManager.materialesBellezaExpenses),
                  _buildExpenseSummaryItem('Suministros', _dataManager.suministrosExpenses),
                  _buildExpenseSummaryItem('Marketing', _dataManager.marketingExpenses),
                  _buildExpenseSummaryItem('Transporte', _dataManager.transporteExpenses),
                  _buildExpenseSummaryItem('Seguros', _dataManager.segurosExpenses),
                  _buildExpenseSummaryItem('Impuestos', _dataManager.impuestosExpenses),
                  _buildExpenseSummaryItem('Mantenimiento', _dataManager.mantenimientoExpenses),
                  _buildExpenseSummaryItem('Otros', _dataManager.otrosExpenses),
                  const Divider(),
                  _buildExpenseSummaryItem('TOTAL GASTOS', _dataManager.totalMonthlyExpenses, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Ganancia estimada: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(
                      (double.tryParse(incomeController.text) ?? 0) - _dataManager.totalMonthlyExpenses
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
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
              final income = double.tryParse(incomeController.text);
              
              if (income == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa valores numéricos válidos'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              _dataManager.updateFinancialData(income: income);

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Datos financieros actualizados exitosamente'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseSummaryItem(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Otros';
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isMonthly = false;

    final categories = [
      'Casa', 'Luz', 'Agua', 'Teléfono/Internet', 'Materiales de Belleza',
      'Suministros', 'Marketing', 'Transporte', 'Seguros', 'Impuestos',
      'Mantenimiento', 'Otros'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Gasto'),
          content: SizedBox(
            width: 400,
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
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('d/M/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Gasto mensual recurrente'),
                  value: isMonthly,
                  onChanged: (value) {
                    setState(() {
                      isMonthly = value!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
              onPressed: () {
                final description = descriptionController.text.trim();
                final amount = double.tryParse(amountController.text);
                
                if (description.isEmpty || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa todos los campos correctamente'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final expense = {
                  'description': description,
                  'amount': amount,
                  'category': selectedCategory,
                  'date': selectedDate,
                  'notes': notesController.text.trim(),
                  'isMonthly': isMonthly,
                };

                _dataManager.addExpense(expense).then((success) {
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gasto agregado exitosamente'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${_dataManager.lastError}'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                });
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteExpense(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el gasto "${expense['description']}" por \$${expense['amount']}?\n\n'
          'Esta acción no se podrá deshacer.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataManager.deleteExpense(expense['id']).then((success) {
                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gasto eliminado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${_dataManager.lastError}'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, size: 16, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text('Supabase', style: TextStyle(color: AppTheme.successColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial Summary
            Row(
              children: [
                Text(
                  'Resumen Financiero del Mes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showEditFinancialDialog,
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  tooltip: 'Editar datos financieros',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [AppTheme.successColor.withOpacity(0.1), AppTheme.successColor.withOpacity(0.05)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingresos del Mes',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_dataManager.monthlyIncome),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [AppTheme.errorColor.withOpacity(0.1), AppTheme.errorColor.withOpacity(0.05)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gastos del Mes',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_dataManager.totalMonthlyExpenses),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ganancia del Mes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_dataManager.monthlyProfit),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Expense Categories Breakdown
            Text(
              'Desglose de Gastos por Categoría',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildExpenseCategoriesGrid(),
            const SizedBox(height: 24),

            // Expenses Management
            Row(
              children: [
                Text(
                  'Gastos Registrados',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddExpenseDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Gasto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _dataManager.expenses.isEmpty
                ? Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No hay gastos registrados',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega tu primer gasto para empezar a controlar tus finanzas',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dataManager.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _dataManager.expenses[index];
                      return Card(
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getCategoryColor(expense['category']).withOpacity(0.1),
                                    child: Icon(
                                      _getCategoryIcon(expense['category']),
                                      color: _getCategoryColor(expense['category']),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense['description'],
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          expense['category'],
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'delete':
                                          _deleteExpense(expense);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 16, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    'Fecha: ${DateFormat('d/M/yyyy').format(expense['date'])}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                  const Spacer(),
                                  Text(
                                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(expense['amount']),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.errorColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (expense['isMonthly'] == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Gasto mensual recurrente',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              if (expense['notes'] != null && expense['notes'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      expense['notes'],
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategoriesGrid() {
    final categories = [
      {'name': 'Casa', 'amount': _dataManager.casaExpenses, 'icon': Icons.home, 'color': Colors.red},
      {'name': 'Luz', 'amount': _dataManager.luzExpenses, 'icon': Icons.lightbulb, 'color': Colors.orange},
      {'name': 'Agua', 'amount': _dataManager.aguaExpenses, 'icon': Icons.water_drop, 'color': Colors.blue},
      {'name': 'Teléfono/Internet', 'amount': _dataManager.telefonoInternetExpenses, 'icon': Icons.phone, 'color': Colors.purple},
      {'name': 'Materiales de Belleza', 'amount': _dataManager.materialesBellezaExpenses, 'icon': Icons.spa, 'color': Colors.pink},
      {'name': 'Suministros', 'amount': _dataManager.suministrosExpenses, 'icon': Icons.inventory, 'color': Colors.green},
      {'name': 'Marketing', 'amount': _dataManager.marketingExpenses, 'icon': Icons.campaign, 'color': Colors.deepOrange},
      {'name': 'Transporte', 'amount': _dataManager.transporteExpenses, 'icon': Icons.directions_car, 'color': Colors.cyan},
      {'name': 'Seguros', 'amount': _dataManager.segurosExpenses, 'icon': Icons.security, 'color': Colors.lime},
      {'name': 'Impuestos', 'amount': _dataManager.impuestosExpenses, 'icon': Icons.receipt_long, 'color': Colors.red.shade700},
      {'name': 'Mantenimiento', 'amount': _dataManager.mantenimientoExpenses, 'icon': Icons.build, 'color': Colors.teal},
      {'name': 'Otros', 'amount': _dataManager.otrosExpenses, 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  (category['color'] as Color).withOpacity(0.1),
                  (category['color'] as Color).withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(category['amount'] as double),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: category['color'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'casa':
        return Colors.red;
      case 'luz':
        return Colors.orange;
      case 'agua':
        return Colors.blue;
      case 'teléfono/internet':
      case 'telefono/internet':
        return Colors.purple;
      case 'materiales de belleza':
      case 'materiales_belleza':
        return Colors.pink;
      case 'suministros':
        return Colors.green;
      case 'marketing':
        return Colors.deepOrange;
      case 'transporte':
        return Colors.cyan;
      case 'seguros':
        return Colors.lime;
      case 'impuestos':
        return Colors.red.shade700;
      case 'mantenimiento':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'casa':
        return Icons.home;
      case 'luz':
        return Icons.lightbulb;
      case 'agua':
        return Icons.water_drop;
      case 'teléfono/internet':
      case 'telefono/internet':
        return Icons.phone;
      case 'materiales de belleza':
      case 'materiales_belleza':
        return Icons.spa;
      case 'suministros':
        return Icons.inventory;
      case 'marketing':
        return Icons.campaign;
      case 'transporte':
        return Icons.directions_car;
      case 'seguros':
        return Icons.security;
      case 'impuestos':
        return Icons.receipt_long;
      case 'mantenimiento':
        return Icons.build;
      default:
        return Icons.more_horiz;
    }
  }
}
