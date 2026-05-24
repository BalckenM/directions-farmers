enum CalendarActivityType {
  landPrep,
  inputPurchase,
  planting,
  germinationCheck,
  fertilizerApplication,
  weeding,
  irrigation,
  scouting,
  spraying,
  harvest,
  postHarvest,
}

extension CalendarActivityTypeX on CalendarActivityType {
  String get label => switch (this) {
        CalendarActivityType.landPrep => 'Land Prep',
        CalendarActivityType.inputPurchase => 'Input Purchase',
        CalendarActivityType.planting => 'Planting',
        CalendarActivityType.germinationCheck => 'Germination Check',
        CalendarActivityType.fertilizerApplication => 'Fertilizer',
        CalendarActivityType.weeding => 'Weeding',
        CalendarActivityType.irrigation => 'Irrigation',
        CalendarActivityType.scouting => 'Scouting',
        CalendarActivityType.spraying => 'Spraying',
        CalendarActivityType.harvest => 'Harvest',
        CalendarActivityType.postHarvest => 'Post-Harvest',
      };

  static CalendarActivityType fromString(String v) => switch (v) {
        'land_prep' => CalendarActivityType.landPrep,
        'input_purchase' => CalendarActivityType.inputPurchase,
        'planting' => CalendarActivityType.planting,
        'germination_check' => CalendarActivityType.germinationCheck,
        'fertilizer_application' => CalendarActivityType.fertilizerApplication,
        'weeding' => CalendarActivityType.weeding,
        'irrigation' => CalendarActivityType.irrigation,
        'scouting' => CalendarActivityType.scouting,
        'spraying' => CalendarActivityType.spraying,
        'harvest' => CalendarActivityType.harvest,
        'post_harvest' => CalendarActivityType.postHarvest,
        _ => CalendarActivityType.scouting,
      };
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.planId,
    required this.fieldId,
    required this.activityType,
    required this.title,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    this.notes,
    required this.reminderDaysBefore,
  });

  final String id;
  final String planId;
  final String fieldId;
  final CalendarActivityType activityType;
  final String title;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status;
  final String? notes;
  final int reminderDaysBefore;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String,
        planId: json['plan_id'] as String,
        fieldId: json['field_id'] as String,
        activityType: CalendarActivityTypeX.fromString(
            json['activity_type'] as String),
        title: json['title'] as String,
        scheduledDate: DateTime.parse(json['scheduled_date'] as String),
        completedDate: json['completed_date'] != null
            ? DateTime.parse(json['completed_date'] as String)
            : null,
        status: json['status'] as String,
        notes: json['notes'] as String?,
        reminderDaysBefore:
            (json['reminder_days_before'] as num).toInt(),
      );

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  CalendarEvent copyWith({
    String? id,
    String? planId,
    String? fieldId,
    CalendarActivityType? activityType,
    String? title,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? status,
    String? notes,
    int? reminderDaysBefore,
  }) =>
      CalendarEvent(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        fieldId: fieldId ?? this.fieldId,
        activityType: activityType ?? this.activityType,
        title: title ?? this.title,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        completedDate: completedDate ?? this.completedDate,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      );
}
