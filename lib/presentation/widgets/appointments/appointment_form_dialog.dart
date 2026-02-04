import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_theme.dart';

class AppointmentFormDialog extends StatefulWidget {
  final Appointment? appointment;
  final List<Client> clients;
  final List<Service> services;
  final DateTime selectedDate;
  final Function(int clientId, int serviceId, DateTime dateTime, String status, double amount) onSave;

  const AppointmentFormDialog({
    super.key,
    this.appointment,
    required this.clients,
    required this.services,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late int _selectedClientId;
  late int _selectedServiceId;
  late DateTime _selectedDateTime;
  late String _selectedStatus;
  late double _amount;
  
  @override
  void initState() {
    super.initState();
    
    _selectedClientId = widget.appointment?.clientId ?? 
        (widget.clients.isNotEmpty ? widget.clients.first.id : 0);
    _selectedServiceId = widget.appointment?.serviceId ?? 
        (widget.services.isNotEmpty ? widget.services.first.id : 0);
    _selectedDateTime = widget.appointment?.dateTime ?? widget.selectedDate;
    _selectedStatus = widget.appointment?.status ?? 'scheduled';
    _amount = widget.appointment?.amount ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedService = widget.services.firstWhere(
      (service) => service.id == _selectedServiceId,
      orElse: () => Service(
        id: 0,
        name: 'Servicio desconocido',
        price: 0.0,
        duration: 0,
        category: 'Desconocido',
        createdAt: DateTime.now(),
      ),
    );

    return AlertDialog(
      title: Text(widget.appointment == null ? 'Nueva Cita' : 'Editar Cita'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Client Selection
              DropdownButtonFormField<int>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: 'Cliente *',
                  hintText: 'Seleccionar cliente',
                ),
                items: widget.clients.map((client) {
                  return DropdownMenuItem<int>(
                    value: client.id,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClientId = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Seleccione un cliente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Service Selection
              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                decoration: const InputDecoration(
                  labelText: 'Servicio *',
                  hintText: 'Seleccionar servicio',
                ),
                items: widget.services.map((service) {
                  return DropdownMenuItem<int>(
                    value: service.id,
                    child: Text('${service.name} - \$${service.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedServiceId = value!;
                    // Update amount when service changes
                    final newService = widget.services.firstWhere((s) => s.id == value);
                    _amount = newService.price;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Seleccione un servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Date Selection
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Fecha *',
                  hintText: 'dd-mm-aaaa',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: DateFormat('dd-MM-yyyy').format(_selectedDateTime),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        _selectedDateTime.hour,
                        _selectedDateTime.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Time Selection
              DropdownButtonFormField<String>(
                value: DateFormat('HH:mm').format(_selectedDateTime),
                decoration: const InputDecoration(
                  labelText: 'Hora *',
                  hintText: 'Seleccionar hora',
                  prefixIcon: Icon(Icons.access_time),
                ),
                items: List.generate(24 * 4, (index) {
                  final hour = index ~/ 4;
                  final minute = (index % 4) * 15;
                  final time = '$hour:${minute.toString().padLeft(2, '0')}';
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    final parts = value.split(':');
                    final hour = int.parse(parts[0]);
                    final minute = int.parse(parts[1]);
                    setState(() {
                      _selectedDateTime = DateTime(
                        _selectedDateTime.year,
                        _selectedDateTime.month,
                        _selectedDateTime.day,
                        hour,
                        minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Status Selection
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado *',
                  hintText: 'Seleccionar estado',
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'scheduled',
                    child: Text('Programada'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'completed',
                    child: Text('Completada'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'canceled',
                    child: Text('Cancelada'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Monto *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                controller: TextEditingController(
                  text: _amount.toStringAsFixed(2),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setState(() {
                      _amount = parsed;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _selectedClientId,
                _selectedServiceId,
                _selectedDateTime,
                _selectedStatus,
                _amount,
              );
            }
          },
          child: Text(widget.appointment == null ? 'Crear Cita' : 'Actualizar'),
        ),
      ],
    );
  }
}
