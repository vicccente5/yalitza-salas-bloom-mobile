import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/data_manager.dart';

class ProfitHistoryScreen extends StatefulWidget {
  const ProfitHistoryScreen({super.key});

  @override
  State<ProfitHistoryScreen> createState() => _ProfitHistoryScreenState();
}

class _ProfitHistoryScreenState extends State<ProfitHistoryScreen> {
  final DataManager _dataManager = DataManager();
  List<Map<String, dynamic>> _profits = [];
  List<int> _availableYears = [];
  int? _selectedYear;
  bool _isLoading = true;

  // Método seguro para formatear fechas
  String _formatMonth(DateTime date) {
    try {
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '${date.month}/${date.year}';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfits();
    _dataManager.addListener(_loadProfits);
  }

  @override
  void dispose() {
    _dataManager.removeListener(_loadProfits);
    super.dispose();
  }

  Future<void> _loadProfits() async {
    setState(() => _isLoading = true);
    try {
      final profits = await _dataManager.getMonthlyProfits();
      
      // Filtrar solo datos válidos y extraer años disponibles
      final validProfits = profits.where((profit) {
        final monthValue = profit['month'];
        return monthValue != null && monthValue.toString().isNotEmpty;
      }).toList();
      
      final years = validProfits
          .map((item) {
            final monthValue = item['month'];
            if (monthValue is String) {
              return DateTime.tryParse(monthValue)?.year ?? DateTime.now().year;
            }
            return (monthValue as DateTime?)?.year ?? DateTime.now().year;
          })
          .where((year) => year > 0) // Filtrar años inválidos
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _profits = validProfits;
        _availableYears = years;
        _selectedYear = years.isNotEmpty ? years.last : null; // Seleccionar el año más reciente
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ganancias: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredProfits {
    if (_selectedYear == null) return _profits;
    return _profits.where((profit) {
      final profitDate = profit['month'] is String 
          ? DateTime.parse(profit['month'])
          : profit['month'] as DateTime;
      return profitDate.year == _selectedYear;
    }).toList();
  }

  double _calculateVariation(double current, double previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Ganancias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await _dataManager.updateCurrentMonthProfits();
              _loadProfits();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ganancias actualizadas'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar ganancias',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtro por año
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text(
                        'Filtrar por año:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Todos los años'),
                                ),
                                ..._availableYears.map((year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedYear = value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Lista de ganancias
                Expanded(
                  child: _filteredProfits.isEmpty
                      ? Center(
                          child: Text(
                            'No hay datos de ganancias disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProfits.length,
                          itemBuilder: (context, index) {
                            final profit = _filteredProfits[index];
                            
                            // Validación segura de datos
                            if (profit == null || profit.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            
                            final monthValue = profit['month'];
                            if (monthValue == null) {
                              return const SizedBox.shrink();
                            }
                            
                            final monthData = monthValue is String 
                                ? DateTime.tryParse(monthValue) ?? DateTime.now()
                                : monthValue as DateTime;
                            final income = (profit['total_income'] as num?)?.toDouble() ?? 0.0;
                            final expenses = (profit['total_expenses'] as num?)?.toDouble() ?? 0.0;
                            final netProfit = (profit['net_profit'] as num?)?.toDouble() ?? 0.0;
                            final appointmentsCount = (profit['appointments_count'] as num?)?.toInt() ?? 0;
                            final expensesCount = (profit['expenses_count'] as num?)?.toInt() ?? 0;

                            // Calcular variación con el mes anterior
                            double? variation;
                            if (index < _filteredProfits.length - 1) {
                              final nextProfit = _filteredProfits[index + 1];
                              if (nextProfit != null && nextProfit['net_profit'] != null) {
                                final nextNetProfit = (nextProfit['net_profit'] as num?)?.toDouble() ?? 0.0;
                                variation = _calculateVariation(netProfit, nextNetProfit);
                              }
                            }

                            return _ProfitCard(
                              month: profit,
                              income: income,
                              expenses: expenses,
                              netProfit: netProfit,
                              appointmentsCount: appointmentsCount,
                              expensesCount: expensesCount,
                              variation: variation,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final Map<String, dynamic> month;
  final double income;
  final double expenses;
  final double netProfit;
  final int appointmentsCount;
  final int expensesCount;
  final double? variation;

  // Método seguro para formatear fechas
  String _formatMonth(DateTime date) {
    try {
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '${date.month}/${date.year}';
    }
  }

  const _ProfitCard({
    required this.month,
    required this.income,
    required this.expenses,
    required this.netProfit,
    required this.appointmentsCount,
    required this.expensesCount,
    this.variation,
  });

  @override
  Widget build(BuildContext context) {
    // Validación segura de datos
    if (month == null || month.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final monthValue = month['month'];
    if (monthValue == null) {
      return const SizedBox.shrink();
    }
    
    final monthData = monthValue is String 
        ? DateTime.tryParse(monthValue) ?? DateTime.now()
        : monthValue as DateTime;
    final monthName = _formatMonth(monthData);
    final isPositive = (variation ?? 0) >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con mes y variación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (variation != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${variation!.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Métricas principales
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'Ingresos',
                    value: '\$${income.toStringAsFixed(2)}',
                    color: Colors.blue,
                    icon: Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricItem(
                    label: 'Gastos',
                    value: '\$${expenses.toStringAsFixed(2)}',
                    color: Colors.orange,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricItem(
                    label: 'Ganancia',
                    value: '\$${netProfit.toStringAsFixed(2)}',
                    color: netProfit >= 0 ? Colors.green : Colors.red,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Citas del mes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$appointmentsCount citas completadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Gastos del mes
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 16,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$expensesCount gastos registrados',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
