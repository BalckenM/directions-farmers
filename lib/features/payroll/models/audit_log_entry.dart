class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.changedByUserId,
    required this.changedByName,
    this.beforeSnapshot,
    this.afterSnapshot,
    this.description,
    required this.occurredAt,
  });

  final String id;

  /// e.g. 'PayRun', 'PayrollEmployee', 'LeaveRequest'.
  final String entityType;
  final String entityId;

  /// e.g. 'CREATE', 'UPDATE', 'APPROVE', 'DISBURSE'.
  final String action;
  final String changedByUserId;
  final String changedByName;

  /// JSON-serialisable snapshot before the change (null for creates).
  final Map<String, dynamic>? beforeSnapshot;

  /// JSON-serialisable snapshot after the change.
  final Map<String, dynamic>? afterSnapshot;
  final String? description;
  final DateTime occurredAt;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
        id: json['id'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        action: json['action'] as String,
        changedByUserId: json['changedByUserId'] as String,
        changedByName: json['changedByName'] as String,
        beforeSnapshot: json['beforeSnapshot'] != null
            ? Map<String, dynamic>.from(json['beforeSnapshot'] as Map)
            : null,
        afterSnapshot: json['afterSnapshot'] != null
            ? Map<String, dynamic>.from(json['afterSnapshot'] as Map)
            : null,
        description: json['description'] as String?,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'entityId': entityId,
        'action': action,
        'changedByUserId': changedByUserId,
        'changedByName': changedByName,
        'beforeSnapshot': beforeSnapshot,
        'afterSnapshot': afterSnapshot,
        'description': description,
        'occurredAt': occurredAt.toIso8601String(),
      };
}
