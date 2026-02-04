import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/database/app_database.dart';
import '../../bloc/database/database_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/supplies/supply_card.dart';
import '../../widgets/supplies/supply_form_dialog.dart';

class SuppliesScreen extends StatefulWidget {
  const SuppliesScreen({super.key});

  @override
  State<SuppliesScreen> createState() => _SuppliesScreenState();
}

class _SuppliesScreenState extends State<SuppliesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Supply> _filteredSupplies = [];

  @override
  void initState() {
    super.initState();
    context.read<DatabaseBloc>().add(LoadSupplies());
    _searchController.addListener(_filterSupplies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSupplies() {
    final state = context.read<DatabaseBloc>().state;
    if (state is DatabaseStateSuppliesLoaded) {
      setState(() {
        _filteredSupplies = state.supplies.where((supply) {
          return supply.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      });
    }
  }

  void _refreshSupplies() {
    context.read<DatabaseBloc>().add(LoadSupplies());
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar suministros...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Supplies List
          Expanded(
            child: BlocBuilder<DatabaseBloc, DatabaseState>(
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
                          'Error al cargar suministros',
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
                          onPressed: _refreshSupplies,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DatabaseStateSuppliesLoaded) {
                  final supplies = _searchController.text.isEmpty
                      ? state.supplies
                      : _filteredSupplies;

                  if (supplies.isEmpty) {
                    return Center(
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
                            _searchController.text.isEmpty
                                ? 'No hay suministros registrados'
                                : 'No se encontraron suministros',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshSupplies();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: supplies.length,
                      itemBuilder: (context, index) {
                        final supply = supplies[index];
                        return SupplyCard(
                          supply: supply,
                          onEdit: () {
                            _showSupplyForm(supply: supply);
                          },
                          onDelete: () {
                            _showDeleteConfirmation(supply);
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSupplyForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSupplyForm({Supply? supply}) {
    showDialog(
      context: context,
      builder: (context) => SupplyFormDialog(
        supply: supply,
        onSave: (name, unitCost, unit, currentStock, minimumStock) async {
          try {
            final database = context.read<DatabaseBloc>().database;
            if (supply != null) {
              // Update existing supply
              await database.updateSupplies(
                SuppliesCompanion(
                  id: Value(supply.id),
                  name: Value(name),
                  unitCost: Value(unitCost),
                  unit: Value(unit),
                  currentStock: Value(currentStock),
                  minimumStock: Value(minimumStock),
                ),
              );
            } else {
              // Create new supply
              await database.into(database.supplies).insert(
                SuppliesCompanion.insert(
                  name: name,
                  unitCost: unitCost,
                  unit: unit,
                  currentStock: currentStock,
                  minimumStock: minimumStock,
                  createdAt: DateTime.now(),
                ),
              );
            }
            _refreshSupplies();
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(supply == null ? 'Suministro creado' : 'Suministro actualizado'),
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

  void _showDeleteConfirmation(Supply supply) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Eliminar Suministro',
      content: '¿Estás seguro de eliminar el suministro "${supply.name}"? Esta acción no se puede deshacer.',
    );

    if (confirmed) {
      try {
        final database = context.read<DatabaseBloc>().database;
        await database.deleteSupplies(supply.id);
        _refreshSupplies();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suministro eliminado'),
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
