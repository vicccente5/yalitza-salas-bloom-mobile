import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/database/app_database.dart';
import '../../bloc/database/database_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/services/service_card.dart';
import '../../widgets/services/service_form_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DatabaseBloc>().add(LoadServices());
  }

  void _refreshServices() {
    context.read<DatabaseBloc>().add(LoadServices());
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
      body: BlocBuilder<DatabaseBloc, DatabaseState>(
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
                    'Error al cargar servicios',
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
                    onPressed: _refreshServices,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is DatabaseStateServicesLoaded) {
            if (state.services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay servicios registrados',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showServiceForm();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Primer Servicio'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _refreshServices();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.services.length,
                itemBuilder: (context, index) {
                  final service = state.services[index];
                  return ServiceCard(
                    service: service,
                    onEdit: () {
                      _showServiceForm(service: service);
                    },
                    onDelete: () {
                      _showDeleteConfirmation(service);
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showServiceForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showServiceForm({Service? service}) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        service: service,
        onSave: (name, description, price, duration, category) async {
          try {
            final database = context.read<DatabaseBloc>().database;
            if (service != null) {
              // Update existing service
              await database.updateServices(
                ServicesCompanion(
                  id: Value(service.id),
                  name: Value(name),
                  description: Value(description),
                  price: Value(price),
                  duration: Value(duration),
                  category: Value(category),
                ),
              );
            } else {
              // Create new service
              await database.into(database.services).insert(
                ServicesCompanion.insert(
                  name: name,
                  description: Value(description),
                  price: price,
                  duration: duration,
                  category: category,
                  createdAt: DateTime.now(),
                ),
              );
            }
            _refreshServices();
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(service == null ? 'Servicio creado' : 'Servicio actualizado'),
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

  void _showDeleteConfirmation(Service service) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Eliminar Servicio',
      content: '¿Estás seguro de eliminar el servicio "${service.name}"? Esta acción no se puede deshacer.',
    );

    if (confirmed) {
      try {
        final database = context.read<DatabaseBloc>().database;
        await database.deleteServices(service.id);
        _refreshServices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Servicio eliminado'),
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
