import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Clients, Services, Supplies, ServiceSupplies, Appointments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // DAO methods for complex queries
  Future<List<Client>> getAllClients() => select(clients).get();
  
  Future<List<Service>> getAllServices() => select(services).get();
  
  Future<List<Supply>> getAllSupplies() => select(supplies).get();
  
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
          ..where((tbl) => tbl.status.equals('completed')))
        .get();
  }
  
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
      ..where((tbl) => 
        tbl.dateTime.isBetweenValues(startOfDay, endOfDay) &
        tbl.status.equals('completed'));
    
    return query.map((row) => row.read(appointments.id.count)!).getSingle();
  }
  
  Future<double> getMonthlyIncome() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    final query = selectOnly(appointments)
      ..addColumns([appointments.amount.sum()])
      ..where((tbl) => 
        tbl.dateTime.isBetweenValues(startOfMonth, endOfMonth) &
        tbl.status.equals('completed'));
    
    return query.map((row) => row.read(appointments.amount.sum()) ?? 0.0).getSingle();
  }
  
  Future<double> getMonthlyCosts() {
    // For now, return 0 as costs are not tracked in appointments
    // This could be extended to track supply usage costs
    return Future.value(0.0);
  }
  
  Future<double> getMonthlyProfit() async {
    final income = await getMonthlyIncome();
    final costs = await getMonthlyCosts();
    return income - costs;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yalitza_salas_db.sqlite'));
    return NativeDatabase(file);
  });
}
