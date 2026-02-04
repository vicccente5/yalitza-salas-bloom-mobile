import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/database/app_database.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final AppDatabase database;

  DatabaseBloc(this.database) : super(const DatabaseState.initial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadClients>(_onLoadClients);
    on<LoadAppointments>(_onLoadAppointments);
    on<LoadServices>(_onLoadServices);
    on<LoadSupplies>(_onLoadSupplies);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      // Simplified version with hardcoded data for testing
      emit(DatabaseState.loaded(
        totalClients: 5,
        activeServices: 3,
        todayAppointments: 2,
        completedTodayAppointments: 1,
        monthlyIncome: 120000.0,
        monthlyCosts: 0.0,
        monthlyProfit: 120000.0,
        todayAppointmentsList: [],
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

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(const DatabaseState.loading());
    try {
      final appointments = await database.getAllAppointments();
      emit(DatabaseState.appointmentsLoaded(appointments));
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
}

// Events
abstract class DatabaseEvent extends Equatable {
  const DatabaseEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DatabaseEvent {}

class LoadClients extends DatabaseEvent {}

class LoadAppointments extends DatabaseEvent {}

class LoadServices extends DatabaseEvent {}

class LoadSupplies extends DatabaseEvent {}

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
  final List<Appointment> todayAppointmentsList;

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
  final List<Appointment> appointments;

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
