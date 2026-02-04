import 'package:drift/drift.dart';

@DataClassName('Client')
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable().withLength(max: 20)();
  TextColumn get email => text().nullable().withLength(max: 100)();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('Service')
class Services extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable().withLength(max: 500)();
  RealColumn get price => real()();
  IntColumn get duration => integer()(); // in minutes
  TextColumn get category => text().withLength(max: 50)();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('Supply')
class Supplies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get unitCost => real()();
  TextColumn get unit => text().withLength(max: 20)(); // kg, ml, units, etc.
  RealColumn get currentStock => real()();
  RealColumn get minimumStock => real()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('ServiceSupply')
class ServiceSupplies extends Table {
  IntColumn get serviceId => integer().references(Services, #id)();
  IntColumn get supplyId => integer().references(Supplies, #id)();
  RealColumn get quantity => real()(); // amount of supply used per service
  
  @override
  Set<Column> get primaryKey => {serviceId, supplyId};
}

@DataClassName('Appointment')
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  IntColumn get serviceId => integer().references(Services, #id)();
  DateTimeColumn get dateTime => dateTime()();
  TextColumn get status => text().withLength(min: 1, max: 20)(); // scheduled, completed, canceled
  RealColumn get amount => real()(); // price charged
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
