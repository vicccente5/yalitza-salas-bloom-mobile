// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_manager.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, email, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(Insertable<Client> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final DateTime createdAt;
  const Client(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      createdAt: Value(createdAt),
    );
  }

  factory Client.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Client copyWith(
          {int? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          DateTime? createdAt}) =>
      Client(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        createdAt: createdAt ?? this.createdAt,
      );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.createdAt == this.createdAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<DateTime> createdAt;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Client> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<DateTime>? createdAt}) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ServicesTable extends Services with TableInfo<$ServicesTable, Service> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, price, duration, category, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(Insertable<Service> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Service map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Service(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class Service extends DataClass implements Insertable<Service> {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final String category;
  final DateTime createdAt;
  const Service(
      {required this.id,
      required this.name,
      this.description,
      required this.price,
      required this.duration,
      required this.category,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    map['duration'] = Variable<int>(duration);
    map['category'] = Variable<String>(category);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      duration: Value(duration),
      category: Value(category),
      createdAt: Value(createdAt),
    );
  }

  factory Service.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Service(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      duration: serializer.fromJson<int>(json['duration']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'duration': serializer.toJson<int>(duration),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Service copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? price,
          int? duration,
          String? category,
          DateTime? createdAt}) =>
      Service(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        price: price ?? this.price,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
      );
  Service copyWithCompanion(ServicesCompanion data) {
    return Service(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      price: data.price.present ? data.price.value : this.price,
      duration: data.duration.present ? data.duration.value : this.duration,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Service(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('duration: $duration, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, price, duration, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Service &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.duration == this.duration &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class ServicesCompanion extends UpdateCompanion<Service> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> price;
  final Value<int> duration;
  final Value<String> category;
  final Value<DateTime> createdAt;
  const ServicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.duration = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ServicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required double price,
    required int duration,
    required String category,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        price = Value(price),
        duration = Value(duration),
        category = Value(category);
  static Insertable<Service> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<int>? duration,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (duration != null) 'duration': duration,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ServicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? price,
      Value<int>? duration,
      Value<String>? category,
      Value<DateTime>? createdAt}) {
    return ServicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('duration: $duration, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SuppliesTable extends Supplies with TableInfo<$SuppliesTable, Supply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _currentStockMeta =
      const VerificationMeta('currentStock');
  @override
  late final GeneratedColumn<double> currentStock = GeneratedColumn<double>(
      'current_stock', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _minimumStockMeta =
      const VerificationMeta('minimumStock');
  @override
  late final GeneratedColumn<double> minimumStock = GeneratedColumn<double>(
      'minimum_stock', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, unitCost, unit, currentStock, minimumStock, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplies';
  @override
  VerificationContext validateIntegrity(Insertable<Supply> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('current_stock')) {
      context.handle(
          _currentStockMeta,
          currentStock.isAcceptableOrUnknown(
              data['current_stock']!, _currentStockMeta));
    } else if (isInserting) {
      context.missing(_currentStockMeta);
    }
    if (data.containsKey('minimum_stock')) {
      context.handle(
          _minimumStockMeta,
          minimumStock.isAcceptableOrUnknown(
              data['minimum_stock']!, _minimumStockMeta));
    } else if (isInserting) {
      context.missing(_minimumStockMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supply(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      currentStock: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_stock'])!,
      minimumStock: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}minimum_stock'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SuppliesTable createAlias(String alias) {
    return $SuppliesTable(attachedDatabase, alias);
  }
}

class Supply extends DataClass implements Insertable<Supply> {
  final int id;
  final String name;
  final double unitCost;
  final String unit;
  final double currentStock;
  final double minimumStock;
  final DateTime createdAt;
  const Supply(
      {required this.id,
      required this.name,
      required this.unitCost,
      required this.unit,
      required this.currentStock,
      required this.minimumStock,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['unit_cost'] = Variable<double>(unitCost);
    map['unit'] = Variable<String>(unit);
    map['current_stock'] = Variable<double>(currentStock);
    map['minimum_stock'] = Variable<double>(minimumStock);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuppliesCompanion toCompanion(bool nullToAbsent) {
    return SuppliesCompanion(
      id: Value(id),
      name: Value(name),
      unitCost: Value(unitCost),
      unit: Value(unit),
      currentStock: Value(currentStock),
      minimumStock: Value(minimumStock),
      createdAt: Value(createdAt),
    );
  }

  factory Supply.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supply(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      unit: serializer.fromJson<String>(json['unit']),
      currentStock: serializer.fromJson<double>(json['currentStock']),
      minimumStock: serializer.fromJson<double>(json['minimumStock']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'unitCost': serializer.toJson<double>(unitCost),
      'unit': serializer.toJson<String>(unit),
      'currentStock': serializer.toJson<double>(currentStock),
      'minimumStock': serializer.toJson<double>(minimumStock),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Supply copyWith(
          {int? id,
          String? name,
          double? unitCost,
          String? unit,
          double? currentStock,
          double? minimumStock,
          DateTime? createdAt}) =>
      Supply(
        id: id ?? this.id,
        name: name ?? this.name,
        unitCost: unitCost ?? this.unitCost,
        unit: unit ?? this.unit,
        currentStock: currentStock ?? this.currentStock,
        minimumStock: minimumStock ?? this.minimumStock,
        createdAt: createdAt ?? this.createdAt,
      );
  Supply copyWithCompanion(SuppliesCompanion data) {
    return Supply(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      unit: data.unit.present ? data.unit.value : this.unit,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
      minimumStock: data.minimumStock.present
          ? data.minimumStock.value
          : this.minimumStock,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supply(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unitCost: $unitCost, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, unitCost, unit, currentStock, minimumStock, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supply &&
          other.id == this.id &&
          other.name == this.name &&
          other.unitCost == this.unitCost &&
          other.unit == this.unit &&
          other.currentStock == this.currentStock &&
          other.minimumStock == this.minimumStock &&
          other.createdAt == this.createdAt);
}

class SuppliesCompanion extends UpdateCompanion<Supply> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> unitCost;
  final Value<String> unit;
  final Value<double> currentStock;
  final Value<double> minimumStock;
  final Value<DateTime> createdAt;
  const SuppliesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.unit = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.minimumStock = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SuppliesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double unitCost,
    required String unit,
    required double currentStock,
    required double minimumStock,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        unitCost = Value(unitCost),
        unit = Value(unit),
        currentStock = Value(currentStock),
        minimumStock = Value(minimumStock);
  static Insertable<Supply> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? unitCost,
    Expression<String>? unit,
    Expression<double>? currentStock,
    Expression<double>? minimumStock,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unitCost != null) 'unit_cost': unitCost,
      if (unit != null) 'unit': unit,
      if (currentStock != null) 'current_stock': currentStock,
      if (minimumStock != null) 'minimum_stock': minimumStock,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SuppliesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? unitCost,
      Value<String>? unit,
      Value<double>? currentStock,
      Value<double>? minimumStock,
      Value<DateTime>? createdAt}) {
    return SuppliesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unitCost: unitCost ?? this.unitCost,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<double>(currentStock.value);
    }
    if (minimumStock.present) {
      map['minimum_stock'] = Variable<double>(minimumStock.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unitCost: $unitCost, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('minimumStock: $minimumStock, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ServiceSuppliesTable extends ServiceSupplies
    with TableInfo<$ServiceSuppliesTable, ServiceSupply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceSuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<int> serviceId = GeneratedColumn<int>(
      'service_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES services (id)'));
  static const VerificationMeta _supplyIdMeta =
      const VerificationMeta('supplyId');
  @override
  late final GeneratedColumn<int> supplyId = GeneratedColumn<int>(
      'supply_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES supplies (id)'));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [serviceId, supplyId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_supplies';
  @override
  VerificationContext validateIntegrity(Insertable<ServiceSupply> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('supply_id')) {
      context.handle(_supplyIdMeta,
          supplyId.isAcceptableOrUnknown(data['supply_id']!, _supplyIdMeta));
    } else if (isInserting) {
      context.missing(_supplyIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serviceId, supplyId};
  @override
  ServiceSupply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceSupply(
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_id'])!,
      supplyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supply_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
    );
  }

  @override
  $ServiceSuppliesTable createAlias(String alias) {
    return $ServiceSuppliesTable(attachedDatabase, alias);
  }
}

class ServiceSupply extends DataClass implements Insertable<ServiceSupply> {
  final int serviceId;
  final int supplyId;
  final double quantity;
  const ServiceSupply(
      {required this.serviceId,
      required this.supplyId,
      required this.quantity});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['service_id'] = Variable<int>(serviceId);
    map['supply_id'] = Variable<int>(supplyId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  ServiceSuppliesCompanion toCompanion(bool nullToAbsent) {
    return ServiceSuppliesCompanion(
      serviceId: Value(serviceId),
      supplyId: Value(supplyId),
      quantity: Value(quantity),
    );
  }

  factory ServiceSupply.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceSupply(
      serviceId: serializer.fromJson<int>(json['serviceId']),
      supplyId: serializer.fromJson<int>(json['supplyId']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serviceId': serializer.toJson<int>(serviceId),
      'supplyId': serializer.toJson<int>(supplyId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  ServiceSupply copyWith({int? serviceId, int? supplyId, double? quantity}) =>
      ServiceSupply(
        serviceId: serviceId ?? this.serviceId,
        supplyId: supplyId ?? this.supplyId,
        quantity: quantity ?? this.quantity,
      );
  ServiceSupply copyWithCompanion(ServiceSuppliesCompanion data) {
    return ServiceSupply(
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      supplyId: data.supplyId.present ? data.supplyId.value : this.supplyId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceSupply(')
          ..write('serviceId: $serviceId, ')
          ..write('supplyId: $supplyId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serviceId, supplyId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceSupply &&
          other.serviceId == this.serviceId &&
          other.supplyId == this.supplyId &&
          other.quantity == this.quantity);
}

class ServiceSuppliesCompanion extends UpdateCompanion<ServiceSupply> {
  final Value<int> serviceId;
  final Value<int> supplyId;
  final Value<double> quantity;
  final Value<int> rowid;
  const ServiceSuppliesCompanion({
    this.serviceId = const Value.absent(),
    this.supplyId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceSuppliesCompanion.insert({
    required int serviceId,
    required int supplyId,
    required double quantity,
    this.rowid = const Value.absent(),
  })  : serviceId = Value(serviceId),
        supplyId = Value(supplyId),
        quantity = Value(quantity);
  static Insertable<ServiceSupply> custom({
    Expression<int>? serviceId,
    Expression<int>? supplyId,
    Expression<double>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serviceId != null) 'service_id': serviceId,
      if (supplyId != null) 'supply_id': supplyId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceSuppliesCompanion copyWith(
      {Value<int>? serviceId,
      Value<int>? supplyId,
      Value<double>? quantity,
      Value<int>? rowid}) {
    return ServiceSuppliesCompanion(
      serviceId: serviceId ?? this.serviceId,
      supplyId: supplyId ?? this.supplyId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serviceId.present) {
      map['service_id'] = Variable<int>(serviceId.value);
    }
    if (supplyId.present) {
      map['supply_id'] = Variable<int>(supplyId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceSuppliesCompanion(')
          ..write('serviceId: $serviceId, ')
          ..write('supplyId: $supplyId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final $SuppliesTable supplies = $SuppliesTable(this);
  late final $ServiceSuppliesTable serviceSupplies =
      $ServiceSuppliesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [clients, services, supplies, serviceSupplies];
}

typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<DateTime> createdAt,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<DateTime> createdAt,
});

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ClientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, BaseReferences<_$AppDatabase, $ClientsTable, Client>),
    Client,
    PrefetchHooks Function()> {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientsCompanion(
            id: id,
            name: name,
            phone: phone,
            email: email,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientsCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            email: email,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, BaseReferences<_$AppDatabase, $ClientsTable, Client>),
    Client,
    PrefetchHooks Function()>;
typedef $$ServicesTableCreateCompanionBuilder = ServicesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  required double price,
  required int duration,
  required String category,
  Value<DateTime> createdAt,
});
typedef $$ServicesTableUpdateCompanionBuilder = ServicesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<double> price,
  Value<int> duration,
  Value<String> category,
  Value<DateTime> createdAt,
});

final class $$ServicesTableReferences
    extends BaseReferences<_$AppDatabase, $ServicesTable, Service> {
  $$ServicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ServiceSuppliesTable, List<ServiceSupply>>
      _serviceSuppliesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.serviceSupplies,
              aliasName: $_aliasNameGenerator(
                  db.services.id, db.serviceSupplies.serviceId));

  $$ServiceSuppliesTableProcessedTableManager get serviceSuppliesRefs {
    final manager =
        $$ServiceSuppliesTableTableManager($_db, $_db.serviceSupplies)
            .filter((f) => f.serviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_serviceSuppliesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ServicesTableFilterComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> serviceSuppliesRefs(
      Expression<bool> Function($$ServiceSuppliesTableFilterComposer f) f) {
    final $$ServiceSuppliesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.serviceSupplies,
        getReferencedColumn: (t) => t.serviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceSuppliesTableFilterComposer(
              $db: $db,
              $table: $db.serviceSupplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> serviceSuppliesRefs<T extends Object>(
      Expression<T> Function($$ServiceSuppliesTableAnnotationComposer a) f) {
    final $$ServiceSuppliesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.serviceSupplies,
        getReferencedColumn: (t) => t.serviceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceSuppliesTableAnnotationComposer(
              $db: $db,
              $table: $db.serviceSupplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ServicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, $$ServicesTableReferences),
    Service,
    PrefetchHooks Function({bool serviceSuppliesRefs})> {
  $$ServicesTableTableManager(_$AppDatabase db, $ServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ServicesCompanion(
            id: id,
            name: name,
            description: description,
            price: price,
            duration: duration,
            category: category,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            required double price,
            required int duration,
            required String category,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ServicesCompanion.insert(
            id: id,
            name: name,
            description: description,
            price: price,
            duration: duration,
            category: category,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ServicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({serviceSuppliesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (serviceSuppliesRefs) db.serviceSupplies
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (serviceSuppliesRefs)
                    await $_getPrefetchedData<Service, $ServicesTable,
                            ServiceSupply>(
                        currentTable: table,
                        referencedTable: $$ServicesTableReferences
                            ._serviceSuppliesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ServicesTableReferences(db, table, p0)
                                .serviceSuppliesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.serviceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ServicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServicesTable,
    Service,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (Service, $$ServicesTableReferences),
    Service,
    PrefetchHooks Function({bool serviceSuppliesRefs})>;
typedef $$SuppliesTableCreateCompanionBuilder = SuppliesCompanion Function({
  Value<int> id,
  required String name,
  required double unitCost,
  required String unit,
  required double currentStock,
  required double minimumStock,
  Value<DateTime> createdAt,
});
typedef $$SuppliesTableUpdateCompanionBuilder = SuppliesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> unitCost,
  Value<String> unit,
  Value<double> currentStock,
  Value<double> minimumStock,
  Value<DateTime> createdAt,
});

final class $$SuppliesTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliesTable, Supply> {
  $$SuppliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ServiceSuppliesTable, List<ServiceSupply>>
      _serviceSuppliesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.serviceSupplies,
              aliasName: $_aliasNameGenerator(
                  db.supplies.id, db.serviceSupplies.supplyId));

  $$ServiceSuppliesTableProcessedTableManager get serviceSuppliesRefs {
    final manager =
        $$ServiceSuppliesTableTableManager($_db, $_db.serviceSupplies)
            .filter((f) => f.supplyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_serviceSuppliesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minimumStock => $composableBuilder(
      column: $table.minimumStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> serviceSuppliesRefs(
      Expression<bool> Function($$ServiceSuppliesTableFilterComposer f) f) {
    final $$ServiceSuppliesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.serviceSupplies,
        getReferencedColumn: (t) => t.supplyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceSuppliesTableFilterComposer(
              $db: $db,
              $table: $db.serviceSupplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentStock => $composableBuilder(
      column: $table.currentStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minimumStock => $composableBuilder(
      column: $table.minimumStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => column);

  GeneratedColumn<double> get minimumStock => $composableBuilder(
      column: $table.minimumStock, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> serviceSuppliesRefs<T extends Object>(
      Expression<T> Function($$ServiceSuppliesTableAnnotationComposer a) f) {
    final $$ServiceSuppliesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.serviceSupplies,
        getReferencedColumn: (t) => t.supplyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServiceSuppliesTableAnnotationComposer(
              $db: $db,
              $table: $db.serviceSupplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SuppliesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliesTable,
    Supply,
    $$SuppliesTableFilterComposer,
    $$SuppliesTableOrderingComposer,
    $$SuppliesTableAnnotationComposer,
    $$SuppliesTableCreateCompanionBuilder,
    $$SuppliesTableUpdateCompanionBuilder,
    (Supply, $$SuppliesTableReferences),
    Supply,
    PrefetchHooks Function({bool serviceSuppliesRefs})> {
  $$SuppliesTableTableManager(_$AppDatabase db, $SuppliesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> currentStock = const Value.absent(),
            Value<double> minimumStock = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SuppliesCompanion(
            id: id,
            name: name,
            unitCost: unitCost,
            unit: unit,
            currentStock: currentStock,
            minimumStock: minimumStock,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double unitCost,
            required String unit,
            required double currentStock,
            required double minimumStock,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SuppliesCompanion.insert(
            id: id,
            name: name,
            unitCost: unitCost,
            unit: unit,
            currentStock: currentStock,
            minimumStock: minimumStock,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SuppliesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({serviceSuppliesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (serviceSuppliesRefs) db.serviceSupplies
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (serviceSuppliesRefs)
                    await $_getPrefetchedData<Supply, $SuppliesTable,
                            ServiceSupply>(
                        currentTable: table,
                        referencedTable: $$SuppliesTableReferences
                            ._serviceSuppliesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SuppliesTableReferences(db, table, p0)
                                .serviceSuppliesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.supplyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SuppliesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliesTable,
    Supply,
    $$SuppliesTableFilterComposer,
    $$SuppliesTableOrderingComposer,
    $$SuppliesTableAnnotationComposer,
    $$SuppliesTableCreateCompanionBuilder,
    $$SuppliesTableUpdateCompanionBuilder,
    (Supply, $$SuppliesTableReferences),
    Supply,
    PrefetchHooks Function({bool serviceSuppliesRefs})>;
typedef $$ServiceSuppliesTableCreateCompanionBuilder = ServiceSuppliesCompanion
    Function({
  required int serviceId,
  required int supplyId,
  required double quantity,
  Value<int> rowid,
});
typedef $$ServiceSuppliesTableUpdateCompanionBuilder = ServiceSuppliesCompanion
    Function({
  Value<int> serviceId,
  Value<int> supplyId,
  Value<double> quantity,
  Value<int> rowid,
});

final class $$ServiceSuppliesTableReferences extends BaseReferences<
    _$AppDatabase, $ServiceSuppliesTable, ServiceSupply> {
  $$ServiceSuppliesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ServicesTable _serviceIdTable(_$AppDatabase db) =>
      db.services.createAlias(
          $_aliasNameGenerator(db.serviceSupplies.serviceId, db.services.id));

  $$ServicesTableProcessedTableManager get serviceId {
    final $_column = $_itemColumn<int>('service_id')!;

    final manager = $$ServicesTableTableManager($_db, $_db.services)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SuppliesTable _supplyIdTable(_$AppDatabase db) =>
      db.supplies.createAlias(
          $_aliasNameGenerator(db.serviceSupplies.supplyId, db.supplies.id));

  $$SuppliesTableProcessedTableManager get supplyId {
    final $_column = $_itemColumn<int>('supply_id')!;

    final manager = $$SuppliesTableTableManager($_db, $_db.supplies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ServiceSuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceSuppliesTable> {
  $$ServiceSuppliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  $$ServicesTableFilterComposer get serviceId {
    final $$ServicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableFilterComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliesTableFilterComposer get supplyId {
    final $$SuppliesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplyId,
        referencedTable: $db.supplies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliesTableFilterComposer(
              $db: $db,
              $table: $db.supplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ServiceSuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceSuppliesTable> {
  $$ServiceSuppliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  $$ServicesTableOrderingComposer get serviceId {
    final $$ServicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableOrderingComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliesTableOrderingComposer get supplyId {
    final $$SuppliesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplyId,
        referencedTable: $db.supplies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliesTableOrderingComposer(
              $db: $db,
              $table: $db.supplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ServiceSuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceSuppliesTable> {
  $$ServiceSuppliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$ServicesTableAnnotationComposer get serviceId {
    final $$ServicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serviceId,
        referencedTable: $db.services,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ServicesTableAnnotationComposer(
              $db: $db,
              $table: $db.services,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SuppliesTableAnnotationComposer get supplyId {
    final $$SuppliesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.supplyId,
        referencedTable: $db.supplies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SuppliesTableAnnotationComposer(
              $db: $db,
              $table: $db.supplies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ServiceSuppliesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceSuppliesTable,
    ServiceSupply,
    $$ServiceSuppliesTableFilterComposer,
    $$ServiceSuppliesTableOrderingComposer,
    $$ServiceSuppliesTableAnnotationComposer,
    $$ServiceSuppliesTableCreateCompanionBuilder,
    $$ServiceSuppliesTableUpdateCompanionBuilder,
    (ServiceSupply, $$ServiceSuppliesTableReferences),
    ServiceSupply,
    PrefetchHooks Function({bool serviceId, bool supplyId})> {
  $$ServiceSuppliesTableTableManager(
      _$AppDatabase db, $ServiceSuppliesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceSuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceSuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceSuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> serviceId = const Value.absent(),
            Value<int> supplyId = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceSuppliesCompanion(
            serviceId: serviceId,
            supplyId: supplyId,
            quantity: quantity,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int serviceId,
            required int supplyId,
            required double quantity,
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceSuppliesCompanion.insert(
            serviceId: serviceId,
            supplyId: supplyId,
            quantity: quantity,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ServiceSuppliesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({serviceId = false, supplyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (serviceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.serviceId,
                    referencedTable:
                        $$ServiceSuppliesTableReferences._serviceIdTable(db),
                    referencedColumn:
                        $$ServiceSuppliesTableReferences._serviceIdTable(db).id,
                  ) as T;
                }
                if (supplyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.supplyId,
                    referencedTable:
                        $$ServiceSuppliesTableReferences._supplyIdTable(db),
                    referencedColumn:
                        $$ServiceSuppliesTableReferences._supplyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ServiceSuppliesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceSuppliesTable,
    ServiceSupply,
    $$ServiceSuppliesTableFilterComposer,
    $$ServiceSuppliesTableOrderingComposer,
    $$ServiceSuppliesTableAnnotationComposer,
    $$ServiceSuppliesTableCreateCompanionBuilder,
    $$ServiceSuppliesTableUpdateCompanionBuilder,
    (ServiceSupply, $$ServiceSuppliesTableReferences),
    ServiceSupply,
    PrefetchHooks Function({bool serviceId, bool supplyId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
  $$SuppliesTableTableManager get supplies =>
      $$SuppliesTableTableManager(_db, _db.supplies);
  $$ServiceSuppliesTableTableManager get serviceSupplies =>
      $$ServiceSuppliesTableTableManager(_db, _db.serviceSupplies);
}
