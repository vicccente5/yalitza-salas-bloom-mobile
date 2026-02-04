import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database_complete.dart';
import '../../bloc/database/database_bloc_complete.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog_complete.dart';
import '../../widgets/clients/client_card_complete.dart';
import '../../widgets/clients/client_form_dialog_complete.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadClients() {
    if (_searchQuery.isEmpty) {
      context.read<DatabaseBloc>().add(LoadClients());
    } else {
      context.read<DatabaseBloc>().add(SearchClients(_searchQuery));
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.isEmpty) {
      context.read<DatabaseBloc>().add(LoadClients());
    } else {
      context.read<DatabaseBloc>().add(SearchClients(query));
    }
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        onSave: (name, phone, email) {
          final client = ClientsCompanion.insert(
            name: name,
            phone: Value(phone),
            email: Value(email),
          );
          context.read<DatabaseBloc>().add(AddClient(client));
        },
      ),
    );
  }

  void _showEditClientDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        onSave: (name, phone, email) {
          final updatedClient = client.copyWith(
            name: name,
            phone: phone,
            email: email,
          );
          context.read<DatabaseBloc>().add(UpdateClient(updatedClient));
        },
      ),
    );
  }

  void _deleteClient(Client client) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Eliminar Cliente',
        content: '¿Estás seguro de que deseas eliminar a ${client.name}?',
        onConfirm: () {
          context.read<DatabaseBloc>().add(DeleteClient(client.id));
        },
      ),
    );
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar cliente por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          
          // Clients List
          Expanded(
            child: BlocBuilder<DatabaseBloc, DatabaseState>(
              builder: (context, state) {
                if (state is DatabaseStateLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando clientes...'),
                      ],
                    ),
                  );
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
                          onPressed: _loadClients,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DatabaseStateSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.successColor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                }

                if (state is DatabaseStateClientsLoaded) {
                  if (state.clients.isEmpty) {
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
                            _searchQuery.isEmpty
                                ? 'No hay clientes registrados'
                                : 'No se encontraron clientes',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_searchQuery.isEmpty)
                            Text(
                              'Agrega tu primer cliente para comenzar',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadClients();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.clients.length,
                      itemBuilder: (context, index) {
                        final client = state.clients[index];
                        return ClientCard(
                          client: client,
                          onTap: () => _showEditClientDialog(client),
                          onDelete: () => _deleteClient(client),
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
        onPressed: _showAddClientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
