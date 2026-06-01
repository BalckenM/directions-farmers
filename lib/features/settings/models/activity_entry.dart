class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.action,
    required this.resource,
    required this.createdAt,
    this.actorId,
    this.resourceId,
  });

  final String id;
  final String action;
  final String resource;
  final DateTime createdAt;
  final String? actorId;
  final String? resourceId;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
        id: json['id'] as String? ?? '',
        action: json['action'] as String? ?? '',
        resource: json['resource'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        actorId: json['actorId'] as String?,
        resourceId: json['resourceId'] as String?,
      );
}
