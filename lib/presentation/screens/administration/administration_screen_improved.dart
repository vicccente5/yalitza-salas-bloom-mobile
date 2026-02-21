import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/data_manager.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final DataManager _dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    _dataManager.addListener(_updateUI);
  }

  @override
  void dispose() {
    _dataManager.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {
        // Actualizar cualquier estado necesario
      });
    }
  }

  void _editCompletedAppointment(Map<String, dynamic> appointment) {
    final incomeController = TextEditingController(text: appointment['income']?.toString() ?? '0');
    final costController = TextEditingController(text: appointment['cost']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ver Detalles de Cita Completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cliente: ${appointment['clientName'] ?? 'Sin nombre'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Servicio: ${appointment['serviceName'] ?? 'Sin servicio'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Ingreso: ${NumberFormat.currency(symbol: '\$').format(appointment['income'] ?? 0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.successColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Costo: ${NumberFormat.currency(symbol: '\$').format(appointment['cost'] ?? 0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Ganancia: ${NumberFormat.currency(symbol: '\$').format((appointment['income'] ?? 0) - (appointment['cost'] ?? 0))}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: (appointment['income'] ?? 0) > (appointment['cost'] ?? 0) 
                  ? AppTheme.successColor 
                  : AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _deleteCompletedAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita Completada'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la cita completada del cliente "${appointment['clientName']}"?\n\n'
          'Esta acción no se podrá deshacer.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataManager.deleteCompletedAppointment(appointment['id']);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita eliminada exitosamente'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
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
        title: const Text('Administración'),
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
            // Header
            Row(
              children: [
                Text(
                  'Citas Completadas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_dataManager.completedAppointments.length} citas',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Completed Appointments List
            _dataManager.completedAppointments.isEmpty
                ? Card(
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No hay citas completadas',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Las citas que se completen aparecerán aquí para su administración',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dataManager.completedAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _dataManager.completedAppointments[index];
                      final total = (appointment['income'] ?? 0.0) + (appointment['cost'] ?? 0.0);
                      final profit = (appointment['income'] ?? 0.0) - (appointment['cost'] ?? 0.0);
                      
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
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    child: Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appointment['clientName'] ?? 'Cliente sin nombre',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          appointment['serviceName'] ?? 'Servicio sin nombre',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _editCompletedAppointment(appointment);
                                          break;
                                        case 'delete':
                                          _deleteCompletedAppointment(appointment);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16, color: AppTheme.primaryColor),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
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
                                    'Fecha: ${DateFormat('d/M/yyyy').format(appointment['dateTime'])}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getProfitColor(profit).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(profit),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _getProfitColor(profit),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ingreso',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(appointment['income'] ?? 0),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: AppTheme.successColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Costo',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(appointment['cost'] ?? 0),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: AppTheme.errorColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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

  Color _getProfitColor(double profit) {
    if (profit > 0) return AppTheme.successColor;
    if (profit < 0) return AppTheme.errorColor;
    return AppTheme.textSecondary;
  }
}
