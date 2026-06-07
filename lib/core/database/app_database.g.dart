// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PendingSyncsTable extends PendingSyncs
    with TableInfo<$PendingSyncsTable, PendingSync> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    method,
    path,
    body,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_syncs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSync> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSync map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSync(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $PendingSyncsTable createAlias(String alias) {
    return $PendingSyncsTable(attachedDatabase, alias);
  }
}

class PendingSync extends DataClass implements Insertable<PendingSync> {
  /// Auto-increment primary key.
  final int id;

  /// The HTTP method to use when replaying this operation.
  /// One of: POST, PUT, PATCH, DELETE.
  final String method;

  /// The relative API path, e.g. `/cattle/123/events`.
  final String path;

  /// JSON-encoded request body (null for DELETE requests).
  final String? body;

  /// Timestamp when the operation was enqueued.
  final DateTime createdAt;

  /// Number of failed upload attempts for this row.
  final int retryCount;
  const PendingSync({
    required this.id,
    required this.method,
    required this.path,
    this.body,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PendingSyncsCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncsCompanion(
      id: Value(id),
      method: Value(method),
      path: Value(path),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory PendingSync.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSync(
      id: serializer.fromJson<int>(json['id']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      body: serializer.fromJson<String?>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'body': serializer.toJson<String?>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PendingSync copyWith({
    int? id,
    String? method,
    String? path,
    Value<String?> body = const Value.absent(),
    DateTime? createdAt,
    int? retryCount,
  }) => PendingSync(
    id: id ?? this.id,
    method: method ?? this.method,
    path: path ?? this.path,
    body: body.present ? body.value : this.body,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  PendingSync copyWithCompanion(PendingSyncsCompanion data) {
    return PendingSync(
      id: data.id.present ? data.id.value : this.id,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSync(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, method, path, body, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSync &&
          other.id == this.id &&
          other.method == this.method &&
          other.path == this.path &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PendingSyncsCompanion extends UpdateCompanion<PendingSync> {
  final Value<int> id;
  final Value<String> method;
  final Value<String> path;
  final Value<String?> body;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const PendingSyncsCompanion({
    this.id = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  PendingSyncsCompanion.insert({
    this.id = const Value.absent(),
    required String method,
    required String path,
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  }) : method = Value(method),
       path = Value(path);
  static Insertable<PendingSync> custom({
    Expression<int>? id,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  PendingSyncsCompanion copyWith({
    Value<int>? id,
    Value<String>? method,
    Value<String>? path,
    Value<String?>? body,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
  }) {
    return PendingSyncsCompanion(
      id: id ?? this.id,
      method: method ?? this.method,
      path: path ?? this.path,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncsCompanion(')
          ..write('id: $id, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $CachedPayrollEmployeesTable extends CachedPayrollEmployees
    with TableInfo<$CachedPayrollEmployeesTable, CachedPayrollEmployee> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPayrollEmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_payroll_employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPayrollEmployee> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPayrollEmployee map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPayrollEmployee(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedPayrollEmployeesTable createAlias(String alias) {
    return $CachedPayrollEmployeesTable(attachedDatabase, alias);
  }
}

class CachedPayrollEmployee extends DataClass
    implements Insertable<CachedPayrollEmployee> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedPayrollEmployee({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedPayrollEmployeesCompanion toCompanion(bool nullToAbsent) {
    return CachedPayrollEmployeesCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPayrollEmployee.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPayrollEmployee(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedPayrollEmployee copyWith({
    String? id,
    String? json,
    DateTime? cachedAt,
  }) => CachedPayrollEmployee(
    id: id ?? this.id,
    json: json ?? this.json,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedPayrollEmployee copyWithCompanion(
    CachedPayrollEmployeesCompanion data,
  ) {
    return CachedPayrollEmployee(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayrollEmployee(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPayrollEmployee &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedPayrollEmployeesCompanion
    extends UpdateCompanion<CachedPayrollEmployee> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedPayrollEmployeesCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPayrollEmployeesCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedPayrollEmployee> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPayrollEmployeesCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedPayrollEmployeesCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayrollEmployeesCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPayRunsTable extends CachedPayRuns
    with TableInfo<$CachedPayRunsTable, CachedPayRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPayRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_pay_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPayRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPayRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPayRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedPayRunsTable createAlias(String alias) {
    return $CachedPayRunsTable(attachedDatabase, alias);
  }
}

class CachedPayRun extends DataClass implements Insertable<CachedPayRun> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedPayRun({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedPayRunsCompanion toCompanion(bool nullToAbsent) {
    return CachedPayRunsCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPayRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPayRun(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedPayRun copyWith({String? id, String? json, DateTime? cachedAt}) =>
      CachedPayRun(
        id: id ?? this.id,
        json: json ?? this.json,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedPayRun copyWithCompanion(CachedPayRunsCompanion data) {
    return CachedPayRun(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayRun(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPayRun &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedPayRunsCompanion extends UpdateCompanion<CachedPayRun> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedPayRunsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPayRunsCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedPayRun> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPayRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedPayRunsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayRunsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPayslipsTable extends CachedPayslips
    with TableInfo<$CachedPayslipsTable, CachedPayslip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPayslipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_payslips';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPayslip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPayslip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPayslip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedPayslipsTable createAlias(String alias) {
    return $CachedPayslipsTable(attachedDatabase, alias);
  }
}

class CachedPayslip extends DataClass implements Insertable<CachedPayslip> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedPayslip({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedPayslipsCompanion toCompanion(bool nullToAbsent) {
    return CachedPayslipsCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPayslip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPayslip(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedPayslip copyWith({String? id, String? json, DateTime? cachedAt}) =>
      CachedPayslip(
        id: id ?? this.id,
        json: json ?? this.json,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedPayslip copyWithCompanion(CachedPayslipsCompanion data) {
    return CachedPayslip(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayslip(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPayslip &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedPayslipsCompanion extends UpdateCompanion<CachedPayslip> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedPayslipsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPayslipsCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedPayslip> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPayslipsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedPayslipsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayslipsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedLeaveRequestsTable extends CachedLeaveRequests
    with TableInfo<$CachedLeaveRequestsTable, CachedLeaveRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedLeaveRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_leave_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedLeaveRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedLeaveRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedLeaveRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedLeaveRequestsTable createAlias(String alias) {
    return $CachedLeaveRequestsTable(attachedDatabase, alias);
  }
}

class CachedLeaveRequest extends DataClass
    implements Insertable<CachedLeaveRequest> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedLeaveRequest({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedLeaveRequestsCompanion toCompanion(bool nullToAbsent) {
    return CachedLeaveRequestsCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedLeaveRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedLeaveRequest(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedLeaveRequest copyWith({String? id, String? json, DateTime? cachedAt}) =>
      CachedLeaveRequest(
        id: id ?? this.id,
        json: json ?? this.json,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedLeaveRequest copyWithCompanion(CachedLeaveRequestsCompanion data) {
    return CachedLeaveRequest(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedLeaveRequest(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedLeaveRequest &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedLeaveRequestsCompanion extends UpdateCompanion<CachedLeaveRequest> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedLeaveRequestsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedLeaveRequestsCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedLeaveRequest> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedLeaveRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedLeaveRequestsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedLeaveRequestsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedLeaveBalancesTable extends CachedLeaveBalances
    with TableInfo<$CachedLeaveBalancesTable, CachedLeaveBalance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedLeaveBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_leave_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedLeaveBalance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedLeaveBalance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedLeaveBalance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedLeaveBalancesTable createAlias(String alias) {
    return $CachedLeaveBalancesTable(attachedDatabase, alias);
  }
}

class CachedLeaveBalance extends DataClass
    implements Insertable<CachedLeaveBalance> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedLeaveBalance({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedLeaveBalancesCompanion toCompanion(bool nullToAbsent) {
    return CachedLeaveBalancesCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedLeaveBalance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedLeaveBalance(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedLeaveBalance copyWith({String? id, String? json, DateTime? cachedAt}) =>
      CachedLeaveBalance(
        id: id ?? this.id,
        json: json ?? this.json,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedLeaveBalance copyWithCompanion(CachedLeaveBalancesCompanion data) {
    return CachedLeaveBalance(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedLeaveBalance(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedLeaveBalance &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedLeaveBalancesCompanion extends UpdateCompanion<CachedLeaveBalance> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedLeaveBalancesCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedLeaveBalancesCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedLeaveBalance> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedLeaveBalancesCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedLeaveBalancesCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedLeaveBalancesCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAttendanceRecordsTable extends CachedAttendanceRecords
    with TableInfo<$CachedAttendanceRecordsTable, CachedAttendanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAttendanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_attendance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAttendanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAttendanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAttendanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedAttendanceRecordsTable createAlias(String alias) {
    return $CachedAttendanceRecordsTable(attachedDatabase, alias);
  }
}

class CachedAttendanceRecord extends DataClass
    implements Insertable<CachedAttendanceRecord> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedAttendanceRecord({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedAttendanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return CachedAttendanceRecordsCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedAttendanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAttendanceRecord(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedAttendanceRecord copyWith({
    String? id,
    String? json,
    DateTime? cachedAt,
  }) => CachedAttendanceRecord(
    id: id ?? this.id,
    json: json ?? this.json,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedAttendanceRecord copyWithCompanion(
    CachedAttendanceRecordsCompanion data,
  ) {
    return CachedAttendanceRecord(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttendanceRecord(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAttendanceRecord &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedAttendanceRecordsCompanion
    extends UpdateCompanion<CachedAttendanceRecord> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedAttendanceRecordsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAttendanceRecordsCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedAttendanceRecord> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAttendanceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedAttendanceRecordsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttendanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedComplianceAlertsTable extends CachedComplianceAlerts
    with TableInfo<$CachedComplianceAlertsTable, CachedComplianceAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedComplianceAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_compliance_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedComplianceAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedComplianceAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedComplianceAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedComplianceAlertsTable createAlias(String alias) {
    return $CachedComplianceAlertsTable(attachedDatabase, alias);
  }
}

class CachedComplianceAlert extends DataClass
    implements Insertable<CachedComplianceAlert> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedComplianceAlert({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedComplianceAlertsCompanion toCompanion(bool nullToAbsent) {
    return CachedComplianceAlertsCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedComplianceAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedComplianceAlert(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedComplianceAlert copyWith({
    String? id,
    String? json,
    DateTime? cachedAt,
  }) => CachedComplianceAlert(
    id: id ?? this.id,
    json: json ?? this.json,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedComplianceAlert copyWithCompanion(
    CachedComplianceAlertsCompanion data,
  ) {
    return CachedComplianceAlert(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedComplianceAlert(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedComplianceAlert &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedComplianceAlertsCompanion
    extends UpdateCompanion<CachedComplianceAlert> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedComplianceAlertsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedComplianceAlertsCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedComplianceAlert> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedComplianceAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedComplianceAlertsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedComplianceAlertsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPayGroupsTable extends CachedPayGroups
    with TableInfo<$CachedPayGroupsTable, CachedPayGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPayGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_pay_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPayGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedPayGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPayGroup(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedPayGroupsTable createAlias(String alias) {
    return $CachedPayGroupsTable(attachedDatabase, alias);
  }
}

class CachedPayGroup extends DataClass implements Insertable<CachedPayGroup> {
  final String id;
  final String json;
  final DateTime cachedAt;
  const CachedPayGroup({
    required this.id,
    required this.json,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedPayGroupsCompanion toCompanion(bool nullToAbsent) {
    return CachedPayGroupsCompanion(
      id: Value(id),
      json: Value(json),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedPayGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPayGroup(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedPayGroup copyWith({String? id, String? json, DateTime? cachedAt}) =>
      CachedPayGroup(
        id: id ?? this.id,
        json: json ?? this.json,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedPayGroup copyWithCompanion(CachedPayGroupsCompanion data) {
    return CachedPayGroup(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayGroup(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPayGroup &&
          other.id == this.id &&
          other.json == this.json &&
          other.cachedAt == this.cachedAt);
}

class CachedPayGroupsCompanion extends UpdateCompanion<CachedPayGroup> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedPayGroupsCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPayGroupsCompanion.insert({
    required String id,
    required String json,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<CachedPayGroup> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPayGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedPayGroupsCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPayGroupsCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PendingSyncsTable pendingSyncs = $PendingSyncsTable(this);
  late final $CachedPayrollEmployeesTable cachedPayrollEmployees =
      $CachedPayrollEmployeesTable(this);
  late final $CachedPayRunsTable cachedPayRuns = $CachedPayRunsTable(this);
  late final $CachedPayslipsTable cachedPayslips = $CachedPayslipsTable(this);
  late final $CachedLeaveRequestsTable cachedLeaveRequests =
      $CachedLeaveRequestsTable(this);
  late final $CachedLeaveBalancesTable cachedLeaveBalances =
      $CachedLeaveBalancesTable(this);
  late final $CachedAttendanceRecordsTable cachedAttendanceRecords =
      $CachedAttendanceRecordsTable(this);
  late final $CachedComplianceAlertsTable cachedComplianceAlerts =
      $CachedComplianceAlertsTable(this);
  late final $CachedPayGroupsTable cachedPayGroups = $CachedPayGroupsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pendingSyncs,
    cachedPayrollEmployees,
    cachedPayRuns,
    cachedPayslips,
    cachedLeaveRequests,
    cachedLeaveBalances,
    cachedAttendanceRecords,
    cachedComplianceAlerts,
    cachedPayGroups,
  ];
}

typedef $$PendingSyncsTableCreateCompanionBuilder =
    PendingSyncsCompanion Function({
      Value<int> id,
      required String method,
      required String path,
      Value<String?> body,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });
typedef $$PendingSyncsTableUpdateCompanionBuilder =
    PendingSyncsCompanion Function({
      Value<int> id,
      Value<String> method,
      Value<String> path,
      Value<String?> body,
      Value<DateTime> createdAt,
      Value<int> retryCount,
    });

class $$PendingSyncsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncsTable> {
  $$PendingSyncsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingSyncsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncsTable> {
  $$PendingSyncsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingSyncsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncsTable> {
  $$PendingSyncsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$PendingSyncsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSyncsTable,
          PendingSync,
          $$PendingSyncsTableFilterComposer,
          $$PendingSyncsTableOrderingComposer,
          $$PendingSyncsTableAnnotationComposer,
          $$PendingSyncsTableCreateCompanionBuilder,
          $$PendingSyncsTableUpdateCompanionBuilder,
          (
            PendingSync,
            BaseReferences<_$AppDatabase, $PendingSyncsTable, PendingSync>,
          ),
          PendingSync,
          PrefetchHooks Function()
        > {
  $$PendingSyncsTableTableManager(_$AppDatabase db, $PendingSyncsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSyncsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSyncsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => PendingSyncsCompanion(
                id: id,
                method: method,
                path: path,
                body: body,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String method,
                required String path,
                Value<String?> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
              }) => PendingSyncsCompanion.insert(
                id: id,
                method: method,
                path: path,
                body: body,
                createdAt: createdAt,
                retryCount: retryCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingSyncsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSyncsTable,
      PendingSync,
      $$PendingSyncsTableFilterComposer,
      $$PendingSyncsTableOrderingComposer,
      $$PendingSyncsTableAnnotationComposer,
      $$PendingSyncsTableCreateCompanionBuilder,
      $$PendingSyncsTableUpdateCompanionBuilder,
      (
        PendingSync,
        BaseReferences<_$AppDatabase, $PendingSyncsTable, PendingSync>,
      ),
      PendingSync,
      PrefetchHooks Function()
    >;
typedef $$CachedPayrollEmployeesTableCreateCompanionBuilder =
    CachedPayrollEmployeesCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedPayrollEmployeesTableUpdateCompanionBuilder =
    CachedPayrollEmployeesCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedPayrollEmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPayrollEmployeesTable> {
  $$CachedPayrollEmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPayrollEmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPayrollEmployeesTable> {
  $$CachedPayrollEmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPayrollEmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPayrollEmployeesTable> {
  $$CachedPayrollEmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPayrollEmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPayrollEmployeesTable,
          CachedPayrollEmployee,
          $$CachedPayrollEmployeesTableFilterComposer,
          $$CachedPayrollEmployeesTableOrderingComposer,
          $$CachedPayrollEmployeesTableAnnotationComposer,
          $$CachedPayrollEmployeesTableCreateCompanionBuilder,
          $$CachedPayrollEmployeesTableUpdateCompanionBuilder,
          (
            CachedPayrollEmployee,
            BaseReferences<
              _$AppDatabase,
              $CachedPayrollEmployeesTable,
              CachedPayrollEmployee
            >,
          ),
          CachedPayrollEmployee,
          PrefetchHooks Function()
        > {
  $$CachedPayrollEmployeesTableTableManager(
    _$AppDatabase db,
    $CachedPayrollEmployeesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPayrollEmployeesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedPayrollEmployeesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedPayrollEmployeesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayrollEmployeesCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayrollEmployeesCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPayrollEmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPayrollEmployeesTable,
      CachedPayrollEmployee,
      $$CachedPayrollEmployeesTableFilterComposer,
      $$CachedPayrollEmployeesTableOrderingComposer,
      $$CachedPayrollEmployeesTableAnnotationComposer,
      $$CachedPayrollEmployeesTableCreateCompanionBuilder,
      $$CachedPayrollEmployeesTableUpdateCompanionBuilder,
      (
        CachedPayrollEmployee,
        BaseReferences<
          _$AppDatabase,
          $CachedPayrollEmployeesTable,
          CachedPayrollEmployee
        >,
      ),
      CachedPayrollEmployee,
      PrefetchHooks Function()
    >;
typedef $$CachedPayRunsTableCreateCompanionBuilder =
    CachedPayRunsCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedPayRunsTableUpdateCompanionBuilder =
    CachedPayRunsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedPayRunsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPayRunsTable> {
  $$CachedPayRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPayRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPayRunsTable> {
  $$CachedPayRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPayRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPayRunsTable> {
  $$CachedPayRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPayRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPayRunsTable,
          CachedPayRun,
          $$CachedPayRunsTableFilterComposer,
          $$CachedPayRunsTableOrderingComposer,
          $$CachedPayRunsTableAnnotationComposer,
          $$CachedPayRunsTableCreateCompanionBuilder,
          $$CachedPayRunsTableUpdateCompanionBuilder,
          (
            CachedPayRun,
            BaseReferences<_$AppDatabase, $CachedPayRunsTable, CachedPayRun>,
          ),
          CachedPayRun,
          PrefetchHooks Function()
        > {
  $$CachedPayRunsTableTableManager(_$AppDatabase db, $CachedPayRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPayRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPayRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPayRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayRunsCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayRunsCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPayRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPayRunsTable,
      CachedPayRun,
      $$CachedPayRunsTableFilterComposer,
      $$CachedPayRunsTableOrderingComposer,
      $$CachedPayRunsTableAnnotationComposer,
      $$CachedPayRunsTableCreateCompanionBuilder,
      $$CachedPayRunsTableUpdateCompanionBuilder,
      (
        CachedPayRun,
        BaseReferences<_$AppDatabase, $CachedPayRunsTable, CachedPayRun>,
      ),
      CachedPayRun,
      PrefetchHooks Function()
    >;
typedef $$CachedPayslipsTableCreateCompanionBuilder =
    CachedPayslipsCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedPayslipsTableUpdateCompanionBuilder =
    CachedPayslipsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedPayslipsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPayslipsTable> {
  $$CachedPayslipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPayslipsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPayslipsTable> {
  $$CachedPayslipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPayslipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPayslipsTable> {
  $$CachedPayslipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPayslipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPayslipsTable,
          CachedPayslip,
          $$CachedPayslipsTableFilterComposer,
          $$CachedPayslipsTableOrderingComposer,
          $$CachedPayslipsTableAnnotationComposer,
          $$CachedPayslipsTableCreateCompanionBuilder,
          $$CachedPayslipsTableUpdateCompanionBuilder,
          (
            CachedPayslip,
            BaseReferences<_$AppDatabase, $CachedPayslipsTable, CachedPayslip>,
          ),
          CachedPayslip,
          PrefetchHooks Function()
        > {
  $$CachedPayslipsTableTableManager(
    _$AppDatabase db,
    $CachedPayslipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPayslipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPayslipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPayslipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayslipsCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayslipsCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPayslipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPayslipsTable,
      CachedPayslip,
      $$CachedPayslipsTableFilterComposer,
      $$CachedPayslipsTableOrderingComposer,
      $$CachedPayslipsTableAnnotationComposer,
      $$CachedPayslipsTableCreateCompanionBuilder,
      $$CachedPayslipsTableUpdateCompanionBuilder,
      (
        CachedPayslip,
        BaseReferences<_$AppDatabase, $CachedPayslipsTable, CachedPayslip>,
      ),
      CachedPayslip,
      PrefetchHooks Function()
    >;
typedef $$CachedLeaveRequestsTableCreateCompanionBuilder =
    CachedLeaveRequestsCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedLeaveRequestsTableUpdateCompanionBuilder =
    CachedLeaveRequestsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedLeaveRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedLeaveRequestsTable> {
  $$CachedLeaveRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedLeaveRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedLeaveRequestsTable> {
  $$CachedLeaveRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedLeaveRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedLeaveRequestsTable> {
  $$CachedLeaveRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedLeaveRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedLeaveRequestsTable,
          CachedLeaveRequest,
          $$CachedLeaveRequestsTableFilterComposer,
          $$CachedLeaveRequestsTableOrderingComposer,
          $$CachedLeaveRequestsTableAnnotationComposer,
          $$CachedLeaveRequestsTableCreateCompanionBuilder,
          $$CachedLeaveRequestsTableUpdateCompanionBuilder,
          (
            CachedLeaveRequest,
            BaseReferences<
              _$AppDatabase,
              $CachedLeaveRequestsTable,
              CachedLeaveRequest
            >,
          ),
          CachedLeaveRequest,
          PrefetchHooks Function()
        > {
  $$CachedLeaveRequestsTableTableManager(
    _$AppDatabase db,
    $CachedLeaveRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedLeaveRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedLeaveRequestsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedLeaveRequestsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLeaveRequestsCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLeaveRequestsCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedLeaveRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedLeaveRequestsTable,
      CachedLeaveRequest,
      $$CachedLeaveRequestsTableFilterComposer,
      $$CachedLeaveRequestsTableOrderingComposer,
      $$CachedLeaveRequestsTableAnnotationComposer,
      $$CachedLeaveRequestsTableCreateCompanionBuilder,
      $$CachedLeaveRequestsTableUpdateCompanionBuilder,
      (
        CachedLeaveRequest,
        BaseReferences<
          _$AppDatabase,
          $CachedLeaveRequestsTable,
          CachedLeaveRequest
        >,
      ),
      CachedLeaveRequest,
      PrefetchHooks Function()
    >;
typedef $$CachedLeaveBalancesTableCreateCompanionBuilder =
    CachedLeaveBalancesCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedLeaveBalancesTableUpdateCompanionBuilder =
    CachedLeaveBalancesCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedLeaveBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedLeaveBalancesTable> {
  $$CachedLeaveBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedLeaveBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedLeaveBalancesTable> {
  $$CachedLeaveBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedLeaveBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedLeaveBalancesTable> {
  $$CachedLeaveBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedLeaveBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedLeaveBalancesTable,
          CachedLeaveBalance,
          $$CachedLeaveBalancesTableFilterComposer,
          $$CachedLeaveBalancesTableOrderingComposer,
          $$CachedLeaveBalancesTableAnnotationComposer,
          $$CachedLeaveBalancesTableCreateCompanionBuilder,
          $$CachedLeaveBalancesTableUpdateCompanionBuilder,
          (
            CachedLeaveBalance,
            BaseReferences<
              _$AppDatabase,
              $CachedLeaveBalancesTable,
              CachedLeaveBalance
            >,
          ),
          CachedLeaveBalance,
          PrefetchHooks Function()
        > {
  $$CachedLeaveBalancesTableTableManager(
    _$AppDatabase db,
    $CachedLeaveBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedLeaveBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedLeaveBalancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedLeaveBalancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLeaveBalancesCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedLeaveBalancesCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedLeaveBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedLeaveBalancesTable,
      CachedLeaveBalance,
      $$CachedLeaveBalancesTableFilterComposer,
      $$CachedLeaveBalancesTableOrderingComposer,
      $$CachedLeaveBalancesTableAnnotationComposer,
      $$CachedLeaveBalancesTableCreateCompanionBuilder,
      $$CachedLeaveBalancesTableUpdateCompanionBuilder,
      (
        CachedLeaveBalance,
        BaseReferences<
          _$AppDatabase,
          $CachedLeaveBalancesTable,
          CachedLeaveBalance
        >,
      ),
      CachedLeaveBalance,
      PrefetchHooks Function()
    >;
typedef $$CachedAttendanceRecordsTableCreateCompanionBuilder =
    CachedAttendanceRecordsCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedAttendanceRecordsTableUpdateCompanionBuilder =
    CachedAttendanceRecordsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedAttendanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAttendanceRecordsTable> {
  $$CachedAttendanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAttendanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAttendanceRecordsTable> {
  $$CachedAttendanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAttendanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAttendanceRecordsTable> {
  $$CachedAttendanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedAttendanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAttendanceRecordsTable,
          CachedAttendanceRecord,
          $$CachedAttendanceRecordsTableFilterComposer,
          $$CachedAttendanceRecordsTableOrderingComposer,
          $$CachedAttendanceRecordsTableAnnotationComposer,
          $$CachedAttendanceRecordsTableCreateCompanionBuilder,
          $$CachedAttendanceRecordsTableUpdateCompanionBuilder,
          (
            CachedAttendanceRecord,
            BaseReferences<
              _$AppDatabase,
              $CachedAttendanceRecordsTable,
              CachedAttendanceRecord
            >,
          ),
          CachedAttendanceRecord,
          PrefetchHooks Function()
        > {
  $$CachedAttendanceRecordsTableTableManager(
    _$AppDatabase db,
    $CachedAttendanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAttendanceRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedAttendanceRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedAttendanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAttendanceRecordsCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAttendanceRecordsCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAttendanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAttendanceRecordsTable,
      CachedAttendanceRecord,
      $$CachedAttendanceRecordsTableFilterComposer,
      $$CachedAttendanceRecordsTableOrderingComposer,
      $$CachedAttendanceRecordsTableAnnotationComposer,
      $$CachedAttendanceRecordsTableCreateCompanionBuilder,
      $$CachedAttendanceRecordsTableUpdateCompanionBuilder,
      (
        CachedAttendanceRecord,
        BaseReferences<
          _$AppDatabase,
          $CachedAttendanceRecordsTable,
          CachedAttendanceRecord
        >,
      ),
      CachedAttendanceRecord,
      PrefetchHooks Function()
    >;
typedef $$CachedComplianceAlertsTableCreateCompanionBuilder =
    CachedComplianceAlertsCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedComplianceAlertsTableUpdateCompanionBuilder =
    CachedComplianceAlertsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedComplianceAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedComplianceAlertsTable> {
  $$CachedComplianceAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedComplianceAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedComplianceAlertsTable> {
  $$CachedComplianceAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedComplianceAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedComplianceAlertsTable> {
  $$CachedComplianceAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedComplianceAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedComplianceAlertsTable,
          CachedComplianceAlert,
          $$CachedComplianceAlertsTableFilterComposer,
          $$CachedComplianceAlertsTableOrderingComposer,
          $$CachedComplianceAlertsTableAnnotationComposer,
          $$CachedComplianceAlertsTableCreateCompanionBuilder,
          $$CachedComplianceAlertsTableUpdateCompanionBuilder,
          (
            CachedComplianceAlert,
            BaseReferences<
              _$AppDatabase,
              $CachedComplianceAlertsTable,
              CachedComplianceAlert
            >,
          ),
          CachedComplianceAlert,
          PrefetchHooks Function()
        > {
  $$CachedComplianceAlertsTableTableManager(
    _$AppDatabase db,
    $CachedComplianceAlertsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedComplianceAlertsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedComplianceAlertsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedComplianceAlertsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedComplianceAlertsCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedComplianceAlertsCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedComplianceAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedComplianceAlertsTable,
      CachedComplianceAlert,
      $$CachedComplianceAlertsTableFilterComposer,
      $$CachedComplianceAlertsTableOrderingComposer,
      $$CachedComplianceAlertsTableAnnotationComposer,
      $$CachedComplianceAlertsTableCreateCompanionBuilder,
      $$CachedComplianceAlertsTableUpdateCompanionBuilder,
      (
        CachedComplianceAlert,
        BaseReferences<
          _$AppDatabase,
          $CachedComplianceAlertsTable,
          CachedComplianceAlert
        >,
      ),
      CachedComplianceAlert,
      PrefetchHooks Function()
    >;
typedef $$CachedPayGroupsTableCreateCompanionBuilder =
    CachedPayGroupsCompanion Function({
      required String id,
      required String json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedPayGroupsTableUpdateCompanionBuilder =
    CachedPayGroupsCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedPayGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPayGroupsTable> {
  $$CachedPayGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPayGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPayGroupsTable> {
  $$CachedPayGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPayGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPayGroupsTable> {
  $$CachedPayGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedPayGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPayGroupsTable,
          CachedPayGroup,
          $$CachedPayGroupsTableFilterComposer,
          $$CachedPayGroupsTableOrderingComposer,
          $$CachedPayGroupsTableAnnotationComposer,
          $$CachedPayGroupsTableCreateCompanionBuilder,
          $$CachedPayGroupsTableUpdateCompanionBuilder,
          (
            CachedPayGroup,
            BaseReferences<
              _$AppDatabase,
              $CachedPayGroupsTable,
              CachedPayGroup
            >,
          ),
          CachedPayGroup,
          PrefetchHooks Function()
        > {
  $$CachedPayGroupsTableTableManager(
    _$AppDatabase db,
    $CachedPayGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPayGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPayGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPayGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayGroupsCompanion(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPayGroupsCompanion.insert(
                id: id,
                json: json,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPayGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPayGroupsTable,
      CachedPayGroup,
      $$CachedPayGroupsTableFilterComposer,
      $$CachedPayGroupsTableOrderingComposer,
      $$CachedPayGroupsTableAnnotationComposer,
      $$CachedPayGroupsTableCreateCompanionBuilder,
      $$CachedPayGroupsTableUpdateCompanionBuilder,
      (
        CachedPayGroup,
        BaseReferences<_$AppDatabase, $CachedPayGroupsTable, CachedPayGroup>,
      ),
      CachedPayGroup,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PendingSyncsTableTableManager get pendingSyncs =>
      $$PendingSyncsTableTableManager(_db, _db.pendingSyncs);
  $$CachedPayrollEmployeesTableTableManager get cachedPayrollEmployees =>
      $$CachedPayrollEmployeesTableTableManager(
        _db,
        _db.cachedPayrollEmployees,
      );
  $$CachedPayRunsTableTableManager get cachedPayRuns =>
      $$CachedPayRunsTableTableManager(_db, _db.cachedPayRuns);
  $$CachedPayslipsTableTableManager get cachedPayslips =>
      $$CachedPayslipsTableTableManager(_db, _db.cachedPayslips);
  $$CachedLeaveRequestsTableTableManager get cachedLeaveRequests =>
      $$CachedLeaveRequestsTableTableManager(_db, _db.cachedLeaveRequests);
  $$CachedLeaveBalancesTableTableManager get cachedLeaveBalances =>
      $$CachedLeaveBalancesTableTableManager(_db, _db.cachedLeaveBalances);
  $$CachedAttendanceRecordsTableTableManager get cachedAttendanceRecords =>
      $$CachedAttendanceRecordsTableTableManager(
        _db,
        _db.cachedAttendanceRecords,
      );
  $$CachedComplianceAlertsTableTableManager get cachedComplianceAlerts =>
      $$CachedComplianceAlertsTableTableManager(
        _db,
        _db.cachedComplianceAlerts,
      );
  $$CachedPayGroupsTableTableManager get cachedPayGroups =>
      $$CachedPayGroupsTableTableManager(_db, _db.cachedPayGroups);
}
