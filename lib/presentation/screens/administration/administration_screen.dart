import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../bloc/database/database_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/administration/financial_summary_card.dart';
import '../../widgets/administration/completed_appointment_item.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  List<Appointment> _completedAppointments = [];
  List<Client> _clients = [];
  List<Service> _services = [];
  double _monthlyIncome = 0.0;
  double _monthlyCosts = 0.0;
  double _monthlyProfit = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final database = context.read<DatabaseBloc>().database;
      
      final completedAppointments = await database.getCompletedAppointments();
      final clients = await database.getAllClients();
      final services = await database.getAllServices();
      final monthlyIncome = await database.getMonthlyIncome();
      final monthlyCosts = await database.getMonthlyCosts();
      final monthlyProfit = await database.getMonthlyProfit();

      setState(() {
        _completedAppointments = completedAppointments;
        _clients = clients;
        _services = services;
        _monthlyIncome = monthlyIncome;
        _monthlyCosts = monthlyCosts;
        _monthlyProfit = monthlyProfit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
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
                Icon(
                  Icons.database,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'BD Local',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFinancialData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial Summary
                    Text(
                      'Resumen Financiero del Mes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Ingresos del Mes',
                            value: NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(_monthlyIncome),
                            icon: Icons.trending_up,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Costos del Mes',
                            value: NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(_monthlyCosts),
                            icon: Icons.trending_down,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FinancialSummaryCard(
                      title: 'Ganancia del Mes',
                      value: NumberFormat.currency(
                        symbol: '\$',
                        decimalDigits: 2,
                      ).format(_monthlyProfit),
                      icon: Icons.account_balance,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),

                    // Completed Appointments History
                    Row(
                      children: [
                        Text(
                          'Historial de Citas Completadas',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        Text(
                          '${_completedAppointments.length} citas',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_completedAppointments.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay citas completadas',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _completedAppointments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final appointment = _completedAppointments[index];
                          final client = _clients.firstWhere(
                            (client) => client.id == appointment.clientId,
                            orElse: () => Client(
                              id: appointment.clientId,
                              name: 'Cliente desconocido',
                              createdAt: DateTime.now(),
                            ),
                          );
                          final service = _services.firstWhere(
                            (service) => service.id == appointment.serviceId,
                            orElse: () => Service(
                              id: appointment.serviceId,
                              name: 'Servicio desconocido',
                              price: 0.0,
                              duration: 0,
                              category: 'Desconocido',
                              createdAt: DateTime.now(),
                            ),
                          );
                          return CompletedAppointmentItem(
                            appointment: appointment,
                            client: client,
                            service: service,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
