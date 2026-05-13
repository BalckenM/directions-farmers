class PestObservation {
  const PestObservation({
    required this.id,
    this.planId,
    required this.fieldId,
    required this.observedDate,
    required this.pestName,
    required this.category,
    required this.severity,
    this.description,
    this.imageUrl,
    this.recommendedAction,
    this.followUpDate,
    required this.status,
  });

  final String id;
  final String? planId;
  final String fieldId;
  final DateTime observedDate;
  final String pestName;
  final String category;
  final String severity;
  final String? description;
  final String? imageUrl;
  final String? recommendedAction;
  final DateTime? followUpDate;
  final String status;

  factory PestObservation.fromJson(Map<String, dynamic> json) =>
      PestObservation(
        id: json['id'] as String,
        planId: json['plan_id'] as String?,
        fieldId: json['field_id'] as String,
        observedDate:
            DateTime.parse(json['observed_date'] as String),
        pestName: json['pest_name'] as String,
        category: json['category'] as String,
        severity: json['severity'] as String,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        recommendedAction: json['recommended_action'] as String?,
        followUpDate: json['follow_up_date'] != null
            ? DateTime.parse(json['follow_up_date'] as String)
            : null,
        status: json['status'] as String,
      );

  bool get isOpen => status == 'open';
  bool get isTreated => status == 'treated';
  bool get isResolved => status == 'resolved';
}
