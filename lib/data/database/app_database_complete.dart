import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database_complete.g.dart';

@DriftDatabase(tables: [Clients, Services, Supplies, ServiceSupplies, Appointments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CLIENTS CRUD
  Future<List<Client>> getAllClients() => select(clients).get();
  
  Future<Client?> getClientById(int id) => (select(clients)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  
  Future<int> insertClient(Insertable<Client> client) => into(clients).insert(client);
  
  Future<bool> updateClient(Insertable<Client> client) => update(clients).replace(client);
  
  Future<int> deleteClient(int id) => (delete(clients)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Client>> searchClients(String query) {
    return (select(clients)
          ..where((tbl) => tbl.name.contains(query))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  // SERVICES CRUD
  Future<List<Service>> getAllServices() => select(services).get();
  
  Future<Service?> getServiceById(int id) => (select(services)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  
  Future<int> insertService(Insertable<Service> service) => into(services).insert(service);
  
  Future<bool> updateService(Insertable<Service> service) => update(services).replace(service);
  
  Future<int> deleteService(int id) => (delete(services)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Service>> getActiveServices() => select(services).get();

  // SUPPLIES CRUD
  Future<List<Supply>> getAllSupplies() => select(supplies).get();
  
  Future<Supply?> getSupplyById(int id) => (select(supplies)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  
  Future<int> insertSupply(Insertable<Supply> supply) => into(supplies).insert(supply);
  
  Future<bool> updateSupply(Insertable<Supply> supply) => update(supplies).replace(supply);
  
  Future<int> deleteSupply(int id) => (delete(supplies)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Supply>> getLowStockSupplies() {
    return (select(supplies)
          ..where((tbl) => tbl.currentStock.isSmallerThanValue(tbl.minimumStock)))
        .get();
  }

  // APPOINTMENTS CRUD
  Future<List<Appointment>> getAllAppointments() => select(appointments).get();
  
  Future<Appointment?> getAppointmentById(int id) => (select(appointments)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  
  Future<int> insertAppointment(Insertable<Appointment> appointment) => into(appointments).insert(appointment);
  
  Future<bool> updateAppointment(Insertable<Appointment> appointment) => update(appointments).replace(appointment);
  
  Future<int> deleteAppointment(int id) => (delete(appointments)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<Appointment>> getAppointmentsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (select(appointments)
          ..where((tbl) => tbl.dateTime.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateTime)]))
        .get();
  }
  
  Future<List<Appointment>> getTodayAppointments() {
    final now = DateTime.now();
    return getAppointmentsForDate(now);
  }
  
  Future<List<Appointment>> getCompletedAppointments() {
    return (select(appointments)
          ..where((tbl) => tbl.status.equals('completed'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateTime)]))
        .get();
  }

  Future<List<Appointment>> getCompletedAppointmentsForMonth(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    
    return (select(appointments)
          ..where((tbl) => tbl.status.equals('completed') & 
                        tbl.dateTime.isBetweenValues(startOfMonth, endOfMonth)))
        .get();
  }

  // DASHBOARD STATISTICS
  Future<int> getTotalClientsCount() {
    final query = selectOnly(clients)..addColumns([clients.id.count()]);
    return query.map((row) => row.read(clients.id.count)!).getSingle();
  }
  
  Future<int> getActiveServicesCount() {
    final query = selectOnly(services)..addColumns([services.id.count()]);
    return query.map((row) => row.read(services.id.count)!).getSingle();
  }
  
  Future<int> getTodayAppointmentsCount() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final query = selectOnly(appointments)
      ..addColumns([appointments.id.count()])
      ..where((tbl) => tbl.dateTime.isBetweenValues(startOfDay, endOfDay));
    
    return query.map((row) => row.read(appointments.id.count)!).getSingle();
  }
  
  Future<int> getCompletedTodayAppointmentsCount() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final query = selectOnly(appointments)
      ..addColumns([appointments.id.count()])
      ..where((tbl) => tbl.status.equals('completed') & 
                    tbl.dateTime.isBetweenValues(startOfDay, endOfDay));
    
    return query.map((row) => row.read(appointments.id.count)!).getSingle();
  }

  // FINANCIAL CALCULATIONS
  Future<double> getMonthlyIncome() async {
    final now = DateTime.now();
    final completedAppointments = await getCompletedAppointmentsForMonth(now);
    return completedAppointments.fold(0.0, (sum, appointment) => sum + appointment.amount);
  }

  Future<double> getMonthlyCosts() async {
    // For now, return 0.0 - can be enhanced with supply cost tracking
    return 0.0;
  }

  Future<double> getMonthlyProfit() async {
    final income = await getMonthlyIncome();
    final costs = await getMonthlyCosts();
    return income - costs;
  }

  // SERVICE-SUPPLY RELATIONSHIPS
  Future<List<ServiceSupply>> getServiceSupplies(int serviceId) {
    return (select(serviceSupplies)..where((tbl) => tbl.serviceId.equals(serviceId))).get();
  }

  Future<int> addSupplyToService(int serviceId, int supplyId, double quantity) {
    return into(serviceSupplies).insert(
      ServiceSuppliesCompanion.insert(
        serviceId: serviceId,
        supplyId: supplyId,
        quantity: quantity,
      ),
    );
  }

  Future<int> removeSupplyFromService(int serviceId, int supplyId) {
    return (delete(serviceSupplies)
          ..where((tbl) => tbl.serviceId.equals(serviceId) & tbl.supplyId.equals(supplyId)))
        .go();
  }

  // JOIN QUERIES FOR DETAILED VIEWS
  Future<List<AppointmentWithDetails>> getAppointmentsWithDetails() {
    final query = select(appointments).join([
      innerJoin(clients, clients.id.equalsExp(appointments.clientId)),
      innerJoin(services, services.id.equalsExp(appointments.serviceId)),
    ]);

    return query.map((row) {
      return AppointmentWithDetails(
        appointment: row.readTable(appointments),
        client: row.readTable(clients),
        service: row.readTable(services),
      );
    }).get();
  }

  Future<List<AppointmentWithDetails>> getTodayAppointmentsWithDetails() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final query = select(appointments).join([
      innerJoin(clients, clients.id.equalsExp(appointments.clientId)),
      innerJoin(services, services.id.equalsExp(appointments.serviceId)),
    ]);

    query.where(appointments.dateTime.isBetweenValues(startOfDay, endOfDay));
    query.orderBy([OrderingTerm.asc(appointments.dateTime)]);

    return query.map((row) {
      return AppointmentWithDetails(
        appointment: row.readTable(appointments),
        client: row.readTable(clients),
        service: row.readTable(services),
      );
    }).get();
  }

  Future<List<ServiceWithSupplies>> getServicesWithSupplies() {
    final query = select(services).join([
      leftOuterJoin(serviceSupplies, serviceSupplies.serviceId.equalsExp(services.id)),
      leftOuterJoin(supplies, supplies.id.equalsExp(serviceSupplies.supplyId)),
    ]);

    return query.map((row) {
      return ServiceWithSupplies(
        service: row.readTable(services),
        supply: row.readTableOrNull(supplies),
        quantity: row.readTableOrNull(serviceSupplies)?.quantity,
      );
    }).get();
  }
}

// Custom data classes for join results
class AppointmentWithDetails {
  final Appointment appointment;
  final Client client;
  final Service service;

  AppointmentWithDetails({
    required this.appointment,
    required this.client,
    required this.service,
  });
}

class ServiceWithSupplies {
  final Service service;
  final Supply? supply;
  final double? quantity;

  ServiceWithSupplies({
    required this.service,
    this.supply,
    this.quantity,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yalitza_salas_db.sqlite'));
    return NativeDatabase(file);
  });
}
