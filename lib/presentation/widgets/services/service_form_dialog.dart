import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_theme.dart';

class ServiceFormDialog extends StatefulWidget {
  final Service? service;
  final Function(String name, String? description, double price, int duration, String category) onSave;

  const ServiceFormDialog({
    super.key,
    this.service,
    required this.onSave,
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late String _selectedCategory;

  final List<String> _categories = [
    'Cabello',
    'Facial',
    'Corporal',
    'Manos y Pies',
    'Depilación',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController = TextEditingController(text: widget.service?.description ?? '');
    _priceController = TextEditingController(text: widget.service?.price.toString() ?? '0.00');
    _durationController = TextEditingController(text: widget.service?.duration.toString() ?? '30');
    _selectedCategory = widget.service?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null ? 'Nuevo Servicio' : 'Editar Servicio'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Servicio *',
                  hintText: 'Ej: Corte de Cabello',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe el servicio...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio ($) *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio es requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duración (min) *',
                  hintText: '30',
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La duración es requerida';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese una duración válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  hintText: 'Seleccionar categoría',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
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
                _nameController.text.trim(),
                _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                double.parse(_priceController.text),
                int.parse(_durationController.text),
                _selectedCategory,
              );
            }
          },
          child: Text(widget.service == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}
