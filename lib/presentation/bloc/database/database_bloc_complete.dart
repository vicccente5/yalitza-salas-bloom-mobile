import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/database/app_database_complete.dart';

// Events
abstract class DatabaseEvent extends Equatable {
  const DatabaseEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DatabaseEvent {}
class LoadClients extends DatabaseEvent {}
class SearchClients extends DatabaseEvent {
  final String query;
  const SearchClients(this.query);
  @override
  List<Object> get props => [query];
}
class LoadAppointments extends DatabaseEvent {}
class LoadAppointmentsForDate extends DatabaseEvent {
  final DateTime date;
  const LoadAppointmentsForDate(this.date);
  @override
  List<Object> get props => [date];
}
class LoadServices extends DatabaseEvent {}
class LoadSupplies extends DatabaseEvent {}

// CRUD Events for Clients
class AddClient extends DatabaseEvent {
  final Client client;
  const AddClient(this.client);
  @override
  List<Object> get props => [client];
}
class UpdateClient extends DatabaseEvent {
  final Client client;
  const UpdateClient(this.client);
  @override
  List<Object> get props => [client];
}
class DeleteClient extends DatabaseEvent {
  final int clientId;
  const DeleteClient(this.clientId);
  @override
  List<Object> get props => [clientId];
}

// CRUD Events for Appointments
class AddAppointment extends DatabaseEvent {
  final Appointment appointment;
  const AddAppointment(this.appointment);
  @override
  List<Object> get props => [appointment];
}
class UpdateAppointment extends DatabaseEvent {
  final Appointment appointment;
  const UpdateAppointment(this.appointment);
  @override
  List<Object> get props => [appointment];
}
class DeleteAppointment extends DatabaseEvent {
  final int appointmentId;
  const DeleteAppointment(this.appointmentId);
  @override
  List<Object> get props => [appointmentId];
}

// CRUD Events for Services
class AddService extends DatabaseEvent {
  final Service service;
  const AddService(this.service);
  @override
  List<Object> get props => [service];
}
class UpdateService extends DatabaseEvent {
  final Service service;
  const UpdateService(this.service);
  @override
  List<Object> get props => [service];
}
class DeleteService extends DatabaseEvent {
  final int serviceId;
  const DeleteService(this.serviceId);
  @override
  List<Object> get props => [serviceId];
}

// CRUD Events for Supplies
class AddSupply extends DatabaseEvent {
  final Supply supply;
  const AddSupply(this.supply);
  @override
  List<Object> get props => [supply];
}
class UpdateSupply extends DatabaseEvent {
  final Supply supply;
  const UpdateSupply(this.supply);
  @override
  List<Object> get props => [supply];
}
class DeleteSupply extends DatabaseEvent {
  final int supplyId;
  const DeleteSupply(this.supplyId);
  @override
  List<Object> get props => [supplyId];
}

// States
abstract class DatabaseState extends Equatable {
  const DatabaseState();

  @override
  List<Object> get props => [];
}

class DatabaseStateInitial extends DatabaseState {
  const DatabaseState.initial();
}

class DatabaseStateLoading extends DatabaseState {
  const DatabaseState.loading();
}

class DatabaseStateLoaded extends DatabaseState {
  final int totalClients;
  final int activeServices;
  final int todayAppointments;
  final int completedTodayAppointments;
  final double monthlyIncome;
  final double monthlyCosts;
  final double monthlyProfit;
  final List<AppointmentWithDetails> todayAppointmentsList;

  const DatabaseStateLoaded({
    required this.totalClients,
    required this.activeServices,
    required this.todayAppointments,
    required this.completedTodayAppointments,
    required this.monthlyIncome,
    required this.monthlyCosts,
    required this.monthlyProfit,
    required this.todayAppointmentsList,
  });

  @override
  List<Object> get props => [
        totalClients,
        activeServices,
        todayAppointments,
        completedTodayAppointments,
        monthlyIncome,
        monthlyCosts,
        monthlyProfit,
        todayAppointmentsList,
      ];
}

class DatabaseStateClientsLoaded extends DatabaseState {
  final List<Client> clients;

  const DatabaseState.clientsLoaded(this.clients);

  @override
  List<Object> get props => [clients];
}

class DatabaseStateAppointmentsLoaded extends DatabaseState {
  final List<AppointmentWithDetails> appointments;

  const DatabaseState.appointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class DatabaseStateServicesLoaded extends DatabaseState {
  final List<Service> services;

  const DatabaseState.servicesLoaded(this.services);

  @override
  List<Object> get props => [services];
}

class DatabaseStateSuppliesLoaded extends DatabaseState {
  final List<Supply> supplies;

  const DatabaseState.suppliesLoaded(this.supplies);

  @override
  List<Object> get props => [supplies];
}

class DatabaseStateError extends DatabaseState {
  final String message;

  const DatabaseState.error(this.message);

  @override
  List<Object> get props => [message];
}

class DatabaseStateSuccess extends DatabaseState {
  final String message;

  const DatabaseState.success(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC Implementation
class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final AppDatabase database;

  DatabaseBloc(this.database) : super(const DatabaseState.initial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadClients>(_onLoadClients);
    on<SearchClients>(_onSearchClients);
    on<LoadAppointments>(_onLoadAppointments);
    on<LoadAppointmentsForDate>(_onLoadAppointmentsForDate);
    on<LoadServices>(_onLoadServices);
    on<LoadSupplies>(_onLoadSupplies);
    
    // Client CRUD
    on<AddClient>(_onAddClient);
    on<UpdateClient>(_onUpdateClient);
    on<DeleteClient>(_onDeleteClient);
    
    // Appointment CRUD
    on<AddAppointment>(_onAddAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
    
    // Service CRUD
    on<AddService>(_onAddService);
    on<UpdateService>(_onUpdateService);
    on<DeleteService>(_onDeleteService);
    
    // Supply CRUD
    on<AddSupply>(_onAddSupply);
    on<UpdateSupply>(_onUpdateSupply);
    on<DeleteSupply>(_onDeleteSupply);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final totalClients = await database.getTotalClientsCount();
      final activeServices = await database.getActiveServicesCount();
      final todayAppointments = await database.getTodayAppointmentsCount();
      final completedTodayAppointments = await database.getCompletedTodayAppointmentsCount();
      final monthlyIncome = await database.getMonthlyIncome();
      final monthlyCosts = await database.getMonthlyCosts();
      final monthlyProfit = await database.getMonthlyProfit();
      final todayAppointmentsList = await database.getTodayAppointmentsWithDetails();

      emit(DatabaseStateLoaded(
        totalClients: totalClients,
        activeServices: activeServices,
        todayAppointments: todayAppointments,
        completedTodayAppointments: completedTodayAppointments,
        monthlyIncome: monthlyIncome,
        monthlyCosts: monthlyCosts,
        monthlyProfit: monthlyProfit,
        todayAppointmentsList: todayAppointmentsList,
      ));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onLoadClients(
    LoadClients event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final clients = await database.getAllClients();
      emit(DatabaseState.clientsLoaded(clients));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onSearchClients(
    SearchClients event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final clients = await database.searchClients(event.query);
      emit(DatabaseState.clientsLoaded(clients));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final appointments = await database.getAppointmentsWithDetails();
      emit(DatabaseState.appointmentsLoaded(appointments));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onLoadAppointmentsForDate(
    LoadAppointmentsForDate event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final appointments = await database.getAppointmentsForDate(event.date);
      final appointmentsWithDetails = <AppointmentWithDetails>[];
      
      for (final appointment in appointments) {
        final client = await database.getClientById(appointment.clientId);
        final service = await database.getServiceById(appointment.serviceId);
        
        if (client != null && service != null) {
          appointmentsWithDetails.add(AppointmentWithDetails(
            appointment: appointment,
            client: client,
            service: service,
          ));
        }
      }
      
      emit(DatabaseState.appointmentsLoaded(appointmentsWithDetails));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final services = await database.getAllServices();
      emit(DatabaseState.servicesLoaded(services));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onLoadSupplies(
    LoadSupplies event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final supplies = await database.getAllSupplies();
      emit(DatabaseState.suppliesLoaded(supplies));
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  // Client CRUD Handlers
  Future<void> _onAddClient(
    AddClient event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.insertClient(event.client);
      emit(const DatabaseState.success('Cliente agregado exitosamente'));
      add(LoadClients());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onUpdateClient(
    UpdateClient event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.updateClient(event.client);
      emit(const DatabaseState.success('Cliente actualizado exitosamente'));
      add(LoadClients());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onDeleteClient(
    DeleteClient event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.deleteClient(event.clientId);
      emit(const DatabaseState.success('Cliente eliminado exitosamente'));
      add(LoadClients());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  // Appointment CRUD Handlers
  Future<void> _onAddAppointment(
    AddAppointment event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.insertAppointment(event.appointment);
      emit(const DatabaseState.success('Cita agregada exitosamente'));
      add(LoadAppointments());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointment event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.updateAppointment(event.appointment);
      emit(const DatabaseState.success('Cita actualizada exitosamente'));
      add(LoadAppointments());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointment event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.deleteAppointment(event.appointmentId);
      emit(const DatabaseState.success('Cita eliminada exitosamente'));
      add(LoadAppointments());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  // Service CRUD Handlers
  Future<void> _onAddService(
    AddService event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.insertService(event.service);
      emit(const DatabaseState.success('Servicio agregado exitosamente'));
      add(LoadServices());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onUpdateService(
    UpdateService event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.updateService(event.service);
      emit(const DatabaseState.success('Servicio actualizado exitosamente'));
      add(LoadServices());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onDeleteService(
    DeleteService event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.deleteService(event.serviceId);
      emit(const DatabaseState.success('Servicio eliminado exitosamente'));
      add(LoadServices());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  // Supply CRUD Handlers
  Future<void> _onAddSupply(
    AddSupply event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.insertSupply(event.supply);
      emit(const DatabaseState.success('Suministro agregado exitosamente'));
      add(LoadSupplies());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onUpdateSupply(
    UpdateSupply event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.updateSupply(event.supply);
      emit(const DatabaseState.success('Suministro actualizado exitosamente'));
      add(LoadSupplies());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }

  Future<void> _onDeleteSupply(
    DeleteSupply event,
    Emitter<DatabaseState> emit,
  ) async {
    try {
      await database.deleteSupply(event.supplyId);
      emit(const DatabaseState.success('Suministro eliminado exitosamente'));
      add(LoadSupplies());
    } catch (e) {
      emit(DatabaseState.error(e.toString()));
    }
  }
}
