import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../theme/app_theme.dart';

class SupplyFormDialog extends StatefulWidget {
  final Supply? supply;
  final Function(String name, double unitCost, String unit, double currentStock, double minimumStock) onSave;

  const SupplyFormDialog({
    super.key,
    this.supply,
    required this.onSave,
  });

  @override
  State<SupplyFormDialog> createState() => _SupplyFormDialogState();
}

class _SupplyFormDialogState extends State<SupplyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _currentStockController;
  late final TextEditingController _minimumStockController;
  late String _selectedUnit;

  final List<String> _units = [
    'kg',
    'g',
    'l',
    'ml',
    'unidades',
    'paquetes',
    'botellas',
    'otro',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supply?.name ?? '');
    _unitCostController = TextEditingController(text: widget.supply?.unitCost.toString() ?? '0.00');
    _currentStockController = TextEditingController(text: widget.supply?.currentStock.toString() ?? '0.0');
    _minimumStockController = TextEditingController(text: widget.supply?.minimumStock.toString() ?? '0.0');
    _selectedUnit = widget.supply?.unit ?? _units.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitCostController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.supply == null ? 'Nuevo Suministro' : 'Editar Suministro'),
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
                  labelText: 'Nombre del Suministro *',
                  hintText: 'Ej: Cera para depilación',
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
                controller: _unitCostController,
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El costo unitario es requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un costo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidad *',
                  hintText: 'Seleccionar unidad',
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentStockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Actual *',
                  hintText: '0.0',
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El stock actual es requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un stock válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minimumStockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Mínimo *',
                  hintText: '0.0',
                  prefixIcon: Icon(Icons.warning),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El stock mínimo es requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un stock mínimo válido';
                  }
                  return null;
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
                double.parse(_unitCostController.text),
                _selectedUnit,
                double.parse(_currentStockController.text),
                double.parse(_minimumStockController.text),
              );
            }
          },
          child: Text(widget.supply == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}
