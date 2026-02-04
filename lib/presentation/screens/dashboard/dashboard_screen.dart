import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../bloc/database/database_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/financial_card.dart';
import '../../widgets/dashboard/appointment_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DatabaseBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      body: BlocBuilder<DatabaseBloc, DatabaseState>(
        builder: (context, state) {
          if (state is DatabaseStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DatabaseStateError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar datos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DatabaseBloc>().add(LoadDashboardData());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is DatabaseStateLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DatabaseBloc>().add(LoadDashboardData());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Text(
                      'Resumen',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        StatsCard(
                          title: 'Total Clientes',
                          value: state.totalClients.toString(),
                          icon: Icons.people,
                          color: AppTheme.primaryColor,
                        ),
                        StatsCard(
                          title: 'Servicios Activos',
                          value: state.activeServices.toString(),
                          icon: Icons.spa,
                          color: AppTheme.secondaryColor,
                        ),
                        StatsCard(
                          title: 'Citas de Hoy',
                          value: state.todayAppointments.toString(),
                          icon: Icons.calendar_today,
                          color: AppTheme.warningColor,
                        ),
                        StatsCard(
                          title: 'Completadas Hoy',
                          value: state.completedTodayAppointments.toString(),
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Financial Cards
                    Text(
                      'Finanzas del Mes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FinancialCard(
                            title: 'Ingresos',
                            value: NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(state.monthlyIncome),
                            icon: Icons.trending_up,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FinancialCard(
                            title: 'Costos',
                            value: NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(state.monthlyCosts),
                            icon: Icons.trending_down,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FinancialCard(
                      title: 'Ganancias',
                      value: NumberFormat.currency(
                        symbol: '\$',
                        decimalDigits: 2,
                      ).format(state.monthlyProfit),
                      icon: Icons.account_balance,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),

                    // Today's Appointments
                    Text(
                      'Citas Programadas para Hoy',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (state.todayAppointmentsList.isEmpty)
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
                              Icons.calendar_today_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No hay citas programadas',
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
                        itemCount: state.todayAppointmentsList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final appointment = state.todayAppointmentsList[index];
                          return AppointmentListItem(appointment: appointment);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
