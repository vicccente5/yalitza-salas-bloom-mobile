import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'Depilación Facial',
      'description': 'Tratamiento completo con productos de alta calidad',
      'price': 25000.0,
      'duration': 60,
      'category': 'Facial',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 2,
      'name': 'Masaje Relajante',
      'description': 'Sesión completa con aceites esenciales',
      'price': 18000.0,
      'duration': 45,
      'category': 'Relajante',
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
    },
    {
      'id': 3,
      'name': 'Limpieza de Pestañas',
      'description': 'Servicio rápido de mantenimiento',
      'price': 15000.0,
      'duration': 30,
      'category': 'Express',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 4,
      'name': 'Tratamiento Corporal',
      'description': 'Exfoliación completa del cuerpo',
      'price': 35000.0,
      'duration': 90,
      'category': 'Corporal',
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 5,
      'name': 'Peeling Químico',
      'description': 'Renovación celular profunda',
      'price': 28000.0,
      'duration': 75,
      'category': 'Facial',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Servicio'),
        content: Column(
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
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
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

              setState(() {
                _services.add({
                  'id': _services.length + 1,
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                  'duration': int.tryParse(durationController.text.trim()) ?? 0,
                  'category': categoryController.text.trim(),
                  'createdAt': DateTime.now(),
                });
              });

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
            onPressed: () {
              setState(() {
                _services.removeWhere((s) => s['id'] == service['id']);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Servicio eliminado exitosamente'),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'facial':
        return AppTheme.primaryColor;
      case 'relajante':
        return AppTheme.secondaryColor;
      case 'express':
        return AppTheme.warningColor;
      case 'corporal':
        return AppTheme.successColor;
      default:
        return Colors.grey;
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
                Icon(
                  Icons.storage,
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
      body: _services.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.spa,
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay servicios registrados',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primer servicio para comenzar',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                final categoryColor = _getCategoryColor(service['category']);
                
                return Card(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: categoryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.spa,
                                color: categoryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service['name'],
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (service['description'] != null && service['description'].toString().isNotEmpty)
                                    Text(
                                      service['description'],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'delete':
                                    _deleteService(service);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
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
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service['category'],
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              NumberFormat.currency(
                                symbol: '\$',
                                decimalDigits: 2,
                              ).format(service['price']),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service['duration']} min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Creado: ${DateFormat('d/M/yyyy').format(service['createdAt'])}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
