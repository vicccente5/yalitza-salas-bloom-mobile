import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/data_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/administration/financial_summary_card.dart';
import '../../widgets/administration/completed_appointment_item.dart';

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
    _dataManager.addListener(_loadFinancialData);
    _loadFinancialData();
  }

  @override
  void dispose() {
    _dataManager.removeListener(_loadFinancialData);
    super.dispose();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Los datos se cargan automáticamente desde DataManager
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
        }
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
                  Icons.cloud_done,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Supabase',
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
              onRefresh: () async {
                await _dataManager.refreshFromCloud();
                _loadFinancialData();
              },
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
                            ).format(_dataManager.monthlyIncome),
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
                            ).format(_dataManager.totalMonthlyExpenses),
                            icon: Icons.trending_down,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Ganancia del Mes',
                            value: NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(_dataManager.monthlyIncome - _dataManager.totalMonthlyExpenses),
                            icon: Icons.account_balance,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Completed Appointments
                    Text(
                      'Citas Completadas del Mes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _dataManager.completedAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _dataManager.completedAppointments[index];
                        return CompletedAppointmentItem(
                          appointment: appointment,
                          onTap: () {
                            // Aquí podrías agregar funcionalidad para ver detalles
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Statistics
                    Text(
                      'Estadísticas del Mes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Total Citas',
                            value: _dataManager.completedAppointments.length.toString(),
                            icon: Icons.calendar_today,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Total Clientes',
                            value: _dataManager.clients.length.toString(),
                            icon: Icons.people,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Total Servicios',
                            value: _dataManager.services.length.toString(),
                            icon: Icons.spa,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FinancialSummaryCard(
                            title: 'Total Suministros',
                            value: _dataManager.supplies.length.toString(),
                            icon: Icons.inventory,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
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
