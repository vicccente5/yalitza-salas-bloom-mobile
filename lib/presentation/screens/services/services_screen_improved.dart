import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/data_manager.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
    if (mounted) setState(() {});
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final nameController = TextEditingController(text: service['name']?.toString() ?? '');
    final descriptionController = TextEditingController(text: service['description']?.toString() ?? '');
    final priceController = TextEditingController(text: service['price']?.toString() ?? '');
    final durationController = TextEditingController(text: service['duration']?.toString() ?? '');
    final categoryController = TextEditingController(text: service['category']?.toString() ?? '');
    final selectedSupplies = <String>{
      ...((service['supplies'] as List?)?.map((e) => e.toString()) ?? const <String>[]),
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modificar Servicio'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del servicio *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duración (minutos) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoryController.text.isNotEmpty ? categoryController.text : null,
                    decoration: const InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Facial', child: Text('Facial')),
                      DropdownMenuItem(value: 'Corporal', child: Text('Corporal')),
                      DropdownMenuItem(value: 'Relajante', child: Text('Relajante')),
                      DropdownMenuItem(value: 'Express', child: Text('Express')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) {
                      categoryController.text = value ?? '';
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Suministros utilizados:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dataManager.supplies.map((supply) {
                      final isSelected = selectedSupplies.contains(supply['name']);
                      return FilterChip(
                        label: Text(supply['name']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSupplies.add(supply['name']);
                            } else {
                              selectedSupplies.remove(supply['name']);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    durationController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Los campos marcados con * son obligatorios'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final updates = {
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                  'duration': int.tryParse(durationController.text.trim()) ?? 0,
                  'category': categoryController.text.trim(),
                  'supplies': selectedSupplies.toList(),
                };

                final ok = await _dataManager.updateService(service['id'], updates);
                if (!context.mounted) return;

                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_dataManager.lastError ?? 'No se pudo modificar el servicio'),
                      backgroundColor: AppTheme.errorColor,
                      duration: const Duration(seconds: 6),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servicio modificado exitosamente'),
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

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final categoryController = TextEditingController();
    final selectedSupplies = <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Servicio'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del servicio *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duración (minutos) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoryController.text.isNotEmpty ? categoryController.text : null,
                    decoration: const InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Facial', child: Text('Facial')),
                      DropdownMenuItem(value: 'Corporal', child: Text('Corporal')),
                      DropdownMenuItem(value: 'Relajante', child: Text('Relajante')),
                      DropdownMenuItem(value: 'Express', child: Text('Express')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) {
                      categoryController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Suministros utilizados:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dataManager.supplies.map((supply) {
                      final isSelected = selectedSupplies.contains(supply['name']);
                      return FilterChip(
                        label: Text(supply['name']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedSupplies.add(supply['name']);
                            } else {
                              selectedSupplies.remove(supply['name']);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    durationController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Los campos marcados con * son obligatorios'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                final newService = {
                  'id': _dataManager.services.length + 1,
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                  'duration': int.tryParse(durationController.text.trim()) ?? 0,
                  'category': categoryController.text.trim(),
                  'createdAt': DateTime.now(),
                  'supplies': selectedSupplies.toList(),
                };

                final ok = await _dataManager.addService(newService);
                if (!context.mounted) return;

                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_dataManager.lastError ?? 'No se pudo agregar el servicio'),
                      backgroundColor: AppTheme.errorColor,
                      duration: const Duration(seconds: 6),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servicio agregado exitosamente'),
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

  void _deleteService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Servicio'),
        content: Text('¿Estás seguro de que deseas eliminar el servicio "${service['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await _dataManager.deleteService(service['id']);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Servicio eliminado exitosamente'
                      : (_dataManager.lastError ?? 'No se pudo eliminar el servicio')),
                  backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
                  duration: Duration(seconds: ok ? 2 : 6),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'facial': return AppTheme.primaryColor;
      case 'relajante': return AppTheme.secondaryColor;
      case 'express': return AppTheme.warningColor;
      case 'corporal': return AppTheme.successColor;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
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
      body: _dataManager.services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa, color: Colors.grey.shade400, size: 64),
                  const SizedBox(height: 16),
                  Text('No hay servicios registrados', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Agrega tu primer servicio para comenzar', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dataManager.services.length,
              itemBuilder: (context, index) {
                final service = _dataManager.services[index];
                final categoryColor = _getCategoryColor(service['category']);
                final supplies = service['supplies'] as List<String>? ?? [];
                
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
                              backgroundColor: categoryColor.withOpacity(0.1),
                              child: Icon(Icons.spa, color: categoryColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service['name'], style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  if (service['description'] != null && service['description'].toString().isNotEmpty)
                                    Text(service['description'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit': _showEditServiceDialog(service); break;
                                  case 'delete': _deleteService(service); break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Modificar'),
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
                              decoration: BoxDecoration(color: categoryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(service['category'], style: TextStyle(color: categoryColor, fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                            const Spacer(),
                            Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(service['price']), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text('${service['duration']} min', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                            const Spacer(),
                            Text('Creado: ${DateFormat('d/M/yyyy').format(service['createdAt'])}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                          ],
                        ),
                        if (supplies.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Suministros:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: supplies.map((supply) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  supply,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
