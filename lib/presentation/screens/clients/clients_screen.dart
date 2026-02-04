import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../bloc/database/database_bloc.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/clients/client_card.dart';
import '../../widgets/clients/client_form_dialog.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    context.read<DatabaseBloc>().add(LoadClients());
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClients() {
    final state = context.read<DatabaseBloc>().state;
    if (state is DatabaseStateClientsLoaded) {
      setState(() {
        _filteredClients = state.clients.where((client) {
          return client.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      });
    }
  }

  void _refreshClients() {
    context.read<DatabaseBloc>().add(LoadClients());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
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
                hintText: 'Buscar clientes por nombre...',
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
          // Clients List
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
                          'Error al cargar clientes',
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
                          onPressed: _refreshClients,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DatabaseStateClientsLoaded) {
                  final clients = _searchController.text.isEmpty
                      ? state.clients
                      : _filteredClients;

                  if (clients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No hay clientes registrados'
                                : 'No se encontraron clientes',
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
                      _refreshClients();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ClientCard(
                          client: client,
                          onEdit: () {
                            _showClientForm(client: client);
                          },
                          onDelete: () {
                            _showDeleteConfirmation(client);
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
          _showClientForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showClientForm({Client? client}) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (name, phone, email) async {
          try {
            final database = context.read<DatabaseBloc>().database;
            if (client != null) {
              // Update existing client
              await database.updateClients(
                ClientsCompanion(
                  id: Value(client.id),
                  name: Value(name),
                  phone: Value(phone),
                  email: Value(email),
                ),
              );
            } else {
              // Create new client
              await database.into(database.clients).insert(
                ClientsCompanion.insert(
                  name: name,
                  phone: Value(phone),
                  email: Value(email),
                  createdAt: DateTime.now(),
                ),
              );
            }
            _refreshClients();
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(client == null ? 'Cliente creado' : 'Cliente actualizado'),
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

  void _showDeleteConfirmation(Client client) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Eliminar Cliente',
      content: '¿Estás seguro de eliminar a ${client.name}? Esta acción no se puede deshacer.',
    );

    if (confirmed) {
      try {
        final database = context.read<DatabaseBloc>().database;
        await database.deleteClients(client.id);
        _refreshClients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente eliminado'),
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
