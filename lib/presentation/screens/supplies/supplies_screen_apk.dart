import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class SuppliesScreen extends StatefulWidget {
  const SuppliesScreen({super.key});

  @override
  State<SuppliesScreen> createState() => _SuppliesScreenState();
}

class _SuppliesScreenState extends State<SuppliesScreen> {
  final List<Map<String, dynamic>> _supplies = [
    {
      'id': 1,
      'name': 'Cera Depilatoria',
      'unitCost': 5000.0,
      'unit': 'kg',
      'currentStock': 15.0,
      'minimumStock': 2.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 2,
      'name': 'Aceites Esenciales',
      'unitCost': 8000.0,
      'unit': 'ml',
      'currentStock': 8.0,
      'minimumStock': 10.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
    },
    {
      'id': 3,
      'name': 'Toallas de Masaje',
      'unitCost': 3000.0,
      'unit': 'unidades',
      'currentStock': 20.0,
      'minimumStock': 5.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 4,
      'name': 'Productos Faciales',
      'unitCost': 12000.0,
      'unit': 'ml',
      'currentStock': 25.0,
      'minimumStock': 8.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 5,
      'name': 'Guantes Desechables',
      'unitCost': 500.0,
      'unit': 'unidades',
      'currentStock': 3.0,
      'minimumStock': 10.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  void _showAddSupplyDialog() {
    final nameController = TextEditingController();
    final unitCostController = TextEditingController();
    final unitController = TextEditingController();
    final currentStockController = TextEditingController();
    final minimumStockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Suministro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del suministro *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitCostController,
              decoration: const InputDecoration(
                labelText: 'Costo unitario *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unidad (kg, ml, unidades) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentStockController,
              decoration: const InputDecoration(
                labelText: 'Stock actual *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: minimumStockController,
              decoration: const InputDecoration(
                labelText: 'Stock mínimo *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
                  unitCostController.text.trim().isEmpty ||
                  unitController.text.trim().isEmpty ||
                  currentStockController.text.trim().isEmpty ||
                  minimumStockController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos los campos son obligatorios'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              setState(() {
                _supplies.add({
                  'id': _supplies.length + 1,
                  'name': nameController.text.trim(),
                  'unitCost': double.tryParse(unitCostController.text.trim()) ?? 0.0,
                  'unit': unitController.text.trim(),
                  'currentStock': double.tryParse(currentStockController.text.trim()) ?? 0.0,
                  'minimumStock': double.tryParse(minimumStockController.text.trim()) ?? 0.0,
                  'createdAt': DateTime.now(),
                });
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suministro agregado exitosamente'),
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

  void _updateStock(Map<String, dynamic> supply) {
    final stockController = TextEditingController(text: supply['currentStock'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Stock - ${supply['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actual: ${supply['currentStock']} ${supply['unit']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Nuevo stock',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final newStock = double.tryParse(stockController.text.trim());
              if (newStock == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa un valor válido'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              setState(() {
                supply['currentStock'] = newStock;
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock actualizado exitosamente'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _deleteSupply(Map<String, dynamic> supply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Suministro'),
        content: Text('¿Estás seguro de que deseas eliminar el suministro "${supply['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _supplies.removeWhere((s) => s['id'] == supply['id']);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suministro eliminado exitosamente'),
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

  bool _isLowStock(Map<String, dynamic> supply) {
    return supply['currentStock'] <= supply['minimumStock'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suministros'),
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
      body: _supplies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay suministros registrados',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primer suministro para comenzar',
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
              itemCount: _supplies.length,
              itemBuilder: (context, index) {
                final supply = _supplies[index];
                final isLowStock = _isLowStock(supply);
                
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
                              backgroundColor: isLowStock 
                                  ? AppTheme.errorColor.withOpacity(0.1)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.inventory,
                                color: isLowStock ? AppTheme.errorColor : AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supply['name'],
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'update_stock':
                                    _updateStock(supply);
                                    break;
                                  case 'delete':
                                    _deleteSupply(supply);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'update_stock',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Actualizar Stock'),
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
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Costo unitario: ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(supply['unitCost'])}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Stock actual: ${supply['currentStock']} ${supply['unit']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isLowStock ? AppTheme.errorColor : AppTheme.textSecondary,
                                fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stock mínimo: ${supply['minimumStock']} ${supply['unit']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isLowStock 
                                    ? AppTheme.errorColor.withOpacity(0.1)
                                    : AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isLowStock ? 'Bajo Stock' : 'Disponible',
                                style: TextStyle(
                                  color: isLowStock ? AppTheme.errorColor : AppTheme.successColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Creado: ${DateFormat('d/M/yyyy').format(supply['createdAt'])}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            if (isLowStock) ...[
                              const Spacer(),
                              Icon(
                                Icons.warning,
                                size: 16,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '¡Reabastecer!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSupplyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
