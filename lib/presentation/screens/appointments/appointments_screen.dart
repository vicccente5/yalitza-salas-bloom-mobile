import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../bloc/database/database_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/appointments/appointment_form_dialog.dart';
import '../../widgets/appointments/appointment_list_item.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Appointment> _selectedDayAppointments = [];
  List<Client> _clients = [];
  List<Service> _services = [];
  Map<DateTime, List<Appointment>> _appointmentsByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  Future<void> _loadData() async {
    final database = context.read<DatabaseBloc>().database;
    
    final clients = await database.getAllClients();
    final services = await database.getAllServices();
    final appointments = await database.getAllAppointments();
    
    // Group appointments by date
    final appointmentsByDate = <DateTime, List<Appointment>>{};
    for (final appointment in appointments) {
      final date = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );
      appointmentsByDate[date] = (appointmentsByDate[date] ?? [])..add(appointment);
    }
    
    setState(() {
      _clients = clients;
      _services = services;
      _appointmentsByDate = appointmentsByDate;
    });
    
    _updateSelectedDayAppointments();
  }

  void _updateSelectedDayAppointments() {
    if (_selectedDay != null) {
      final selectedDate = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      setState(() {
        _selectedDayAppointments = _appointmentsByDate[selectedDate] ?? [];
      });
    }
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _appointmentsByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
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
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TableCalendar<Appointment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: _getAppointmentsForDay,
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _updateSelectedDayAppointments();
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          
          // Appointments count and new appointment button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_selectedDayAppointments.length} cita(s) programada(s)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAppointmentForm();
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Nueva Cita para ${DateFormat('d/M/yyyy').format(_selectedDay!)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Appointments list for selected day
          Expanded(
            child: _selectedDayAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay citas para este día',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _selectedDayAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _selectedDayAppointments[index];
                      return AppointmentListItem(
                        appointment: appointment,
                        client: _clients.firstWhere(
                          (client) => client.id == appointment.clientId,
                          orElse: () => Client(
                            id: appointment.clientId,
                            name: 'Cliente desconocido',
                            createdAt: DateTime.now(),
                          ),
                        ),
                        service: _services.firstWhere(
                          (service) => service.id == appointment.serviceId,
                          orElse: () => Service(
                            id: appointment.serviceId,
                            name: 'Servicio desconocido',
                            price: 0.0,
                            duration: 0,
                            category: 'Desconocido',
                            createdAt: DateTime.now(),
                          ),
                        ),
                        onEdit: () {
                          _showAppointmentForm(appointment: appointment);
                        },
                        onDelete: () {
                          _showDeleteConfirmation(appointment);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAppointmentForm({Appointment? appointment}) {
    showDialog(
      context: context,
      builder: (context) => AppointmentFormDialog(
        appointment: appointment,
        clients: _clients,
        services: _services,
        selectedDate: _selectedDay!,
        onSave: (clientId, serviceId, dateTime, status, amount) async {
          try {
            final database = context.read<DatabaseBloc>().database;
            
            if (appointment != null) {
              // Update existing appointment
              await database.updateAppointments(
                AppointmentsCompanion(
                  id: Value(appointment.id),
                  clientId: Value(clientId),
                  serviceId: Value(serviceId),
                  dateTime: Value(dateTime),
                  status: Value(status),
                  amount: Value(amount),
                  updatedAt: Value(DateTime.now()),
                ),
              );
            } else {
              // Create new appointment
              await database.into(database.appointments).insert(
                AppointmentsCompanion.insert(
                  clientId: clientId,
                  serviceId: serviceId,
                  dateTime: dateTime,
                  status: status,
                  amount: amount,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
            }
            
            await _loadData();
            
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appointment == null ? 'Cita creada' : 'Cita actualizada'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Appointment appointment) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Eliminar Cita',
      content: '¿Estás seguro de eliminar esta cita? Esta acción no se puede deshacer.',
    );

    if (confirmed) {
      try {
        final database = context.read<DatabaseBloc>().database;
        await database.deleteAppointments(appointment.id);
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita eliminada'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}
