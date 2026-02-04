import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/data_manager.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final DataManager _dataManager = DataManager();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _dataManager.addListener(_updateUI);
  }

  @override
  void dispose() {
    _dataManager.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  void _showAddAppointmentDialog() {
    final selectedClient = ValueNotifier<String?>(null);
    final selectedService = ValueNotifier<String?>(null);
    final selectedHour = ValueNotifier<String?>(null);
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva Cita'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Dropdown
                ValueListenableBuilder<String?>(
                  valueListenable: selectedClient,
                  builder: (context, clientValue, child) {
                    return DropdownButtonFormField<String>(
                      value: clientValue,
                      decoration: const InputDecoration(
                        labelText: 'Cliente *',
                        border: OutlineInputBorder(),
                      ),
                      items: _dataManager.clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client['name'],
                          child: Text(client['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedClient.value = value;
                        selectedService.value = null;
                        selectedHour.value = null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Service Dropdown
                ValueListenableBuilder<String?>(
                  valueListenable: selectedService,
                  builder: (context, serviceValue, child) {
                    return DropdownButtonFormField<String>(
                      value: serviceValue,
                      decoration: const InputDecoration(
                        labelText: 'Servicio *',
                        border: OutlineInputBorder(),
                      ),
                      items: _dataManager.services.map((service) {
                        return DropdownMenuItem<String>(
                          value: service['name'],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(service['name']),
                              Text(
                                '${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(service['price'])} - ${service['duration']} min',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedService.value = value;
                        selectedHour.value = null;
                        
                        // Auto-fill amount based on selected service
                        final service = _dataManager.services.firstWhere(
                          (s) => s['name'] == value,
                          orElse: () => {},
                        );
                        if (service.isNotEmpty) {
                          amountController.text = service['price'].toString();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Hour Dropdown
                ValueListenableBuilder<String?>(
                  valueListenable: selectedHour,
                  builder: (context, hourValue, child) {
                    final availableHours = _dataManager.getAvailableHours(_selectedDay!);
                    return DropdownButtonFormField<String>(
                      value: hourValue,
                      decoration: const InputDecoration(
                        labelText: 'Hora *',
                        border: OutlineInputBorder(),
                      ),
                      items: availableHours.map((hour) {
                        return DropdownMenuItem<String>(
                          value: hour,
                          child: Text(hour),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedHour.value = value;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount Field
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                if (selectedClient.value == null ||
                    selectedService.value == null ||
                    selectedHour.value == null ||
                    amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final timeParts = selectedHour.value!.split(':');
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                
                final newAppointment = {
                  'id': _dataManager.appointments.length + 1,
                  'clientName': selectedClient.value,
                  'serviceName': selectedService.value,
                  'dateTime': DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                    hour,
                    minute,
                  ),
                  'status': 'scheduled',
                  'amount': double.tryParse(amountController.text.trim()) ?? 0.0,
                };

                final ok = await _dataManager.addAppointment(newAppointment);
                if (!context.mounted) return;
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_dataManager.lastError ?? 'No se pudo agregar la cita'),
                      backgroundColor: AppTheme.errorColor,
                      duration: const Duration(seconds: 6),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita agregada exitosamente'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editAppointment(Map<String, dynamic> appointment) {
    final selectedClient = ValueNotifier<String>(appointment['clientName']);
    final selectedService = ValueNotifier<String>(appointment['serviceName']);
    final selectedDay = ValueNotifier<DateTime>(appointment['dateTime']);
    final selectedHour = ValueNotifier<String>(DateFormat('HH:mm').format(appointment['dateTime']));
    final amountController = TextEditingController(text: appointment['amount'].toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Cita'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDay,
                  builder: (context, dayValue, child) {
                    return InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: dayValue,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          selectedDay.value = pickedDate;
                          selectedHour.value = '';
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('d/M/yyyy').format(dayValue)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Client Dropdown
                ValueListenableBuilder<String>(
                  valueListenable: selectedClient,
                  builder: (context, clientValue, child) {
                    return DropdownButtonFormField<String>(
                      value: clientValue,
                      decoration: const InputDecoration(
                        labelText: 'Cliente *',
                        border: OutlineInputBorder(),
                      ),
                      items: _dataManager.clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client['name'],
                          child: Text(client['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedClient.value = value!;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Service Dropdown
                ValueListenableBuilder<String>(
                  valueListenable: selectedService,
                  builder: (context, serviceValue, child) {
                    return DropdownButtonFormField<String>(
                      value: serviceValue,
                      decoration: const InputDecoration(
                        labelText: 'Servicio *',
                        border: OutlineInputBorder(),
                      ),
                      items: _dataManager.services.map((service) {
                        return DropdownMenuItem<String>(
                          value: service['name'],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(service['name']),
                              Text(
                                '${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(service['price'])} - ${service['duration']} min',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedService.value = value!;
                        
                        // Auto-fill amount based on selected service
                        final service = _dataManager.services.firstWhere(
                          (s) => s['name'] == value,
                          orElse: () => {},
                        );
                        if (service.isNotEmpty) {
                          amountController.text = service['price'].toString();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Hour Dropdown
                ValueListenableBuilder<String>(
                  valueListenable: selectedHour,
                  builder: (context, hourValue, child) {
                    final availableHours = _dataManager.getAvailableHours(selectedDay.value);
                    return DropdownButtonFormField<String>(
                      value: hourValue,
                      decoration: const InputDecoration(
                        labelText: 'Hora *',
                        border: OutlineInputBorder(),
                      ),
                      items: availableHours.map((hour) {
                        return DropdownMenuItem<String>(
                          value: hour,
                          child: Text(hour),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedHour.value = value!;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Amount Field
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                if (selectedClient.value.isEmpty ||
                    selectedService.value.isEmpty ||
                    selectedHour.value == null ||
                    amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final timeParts = selectedHour.value!.split(':');
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                
                final updates = {
                  'clientName': selectedClient.value,
                  'serviceName': selectedService.value,
                  'dateTime': DateTime(
                    selectedDay.value.year,
                    selectedDay.value.month,
                    selectedDay.value.day,
                    hour,
                    minute,
                  ),
                  'amount': double.tryParse(amountController.text.trim()) ?? 0.0,
                };

                _dataManager.updateAppointment(appointment['id'], updates);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita actualizada exitosamente'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAppointmentStatus(Map<String, dynamic> appointment, String newStatus) {
    _dataManager.updateAppointmentStatus(appointment['id'], newStatus);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cita ${newStatus == 'completed' ? 'completada' : 'cancelada'} exitosamente'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _deleteAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content: Text('¿Estás seguro de que deseas eliminar la cita de ${appointment['clientName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataManager.deleteAppointment(appointment['id']);
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'canceled':
        return AppTheme.errorColor;
      case 'scheduled':
      default:
        return AppTheme.warningColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Completada';
      case 'canceled':
        return 'Cancelada';
      case 'scheduled':
      default:
        return 'Programada';
    }
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
                Icon(Icons.cloud_done, size: 16, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text('Supabase', style: TextStyle(color: AppTheme.successColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _dataManager.getAppointmentsForDay(day);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppTheme.warningColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Appointments for selected day
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Citas para ${DateFormat('d/M/yyyy').format(_selectedDay!)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_dataManager.getAppointmentsForDay(_selectedDay!).length} citas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Appointments list
          Expanded(
            child: _dataManager.getAppointmentsForDay(_selectedDay!).isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No hay citas para este día', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Agrega una nueva cita para comenzar', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dataManager.getAppointmentsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final appointment = _dataManager.getAppointmentsForDay(_selectedDay!)[index];
                      final dateTime = appointment['dateTime'] as DateTime;
                      final isCompleted = appointment['status'] == 'completed';
                      
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
                                          appointment['clientName'],
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          appointment['serviceName'],
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _editAppointment(appointment);
                                          break;
                                        case 'complete':
                                          if (!isCompleted) {
                                            _updateAppointmentStatus(appointment, 'completed');
                                          }
                                          break;
                                        case 'cancel':
                                          _updateAppointmentStatus(appointment, 'canceled');
                                          break;
                                        case 'delete':
                                          _deleteAppointment(appointment);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      if (!isCompleted)
                                        const PopupMenuItem(
                                          value: 'complete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, size: 16, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('Completar'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'cancel',
                                        child: Row(
                                          children: [
                                            Icon(Icons.cancel, size: 16, color: Colors.orange),
                                            SizedBox(width: 8),
                                            Text('Cancelar'),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(appointment['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(appointment['status']),
                                      style: TextStyle(
                                        color: _getStatusColor(appointment['status']),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('HH:mm').format(dateTime),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(appointment['amount']),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
