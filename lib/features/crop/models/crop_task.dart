enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, inProgress, completed, delayed, overdue }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
        TaskPriority.urgent => 'Urgent',
      };

  static TaskPriority fromString(String v) => switch (v) {
        'urgent' => TaskPriority.urgent,
        'high' => TaskPriority.high,
        'medium' => TaskPriority.medium,
        _ => TaskPriority.low,
      };
}

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.completed => 'Completed',
        TaskStatus.delayed => 'Delayed',
        TaskStatus.overdue => 'Overdue',
      };

  static TaskStatus fromString(String v) => switch (v) {
        'in_progress' => TaskStatus.inProgress,
        'completed' => TaskStatus.completed,
        'delayed' => TaskStatus.delayed,
        'overdue' => TaskStatus.overdue,
        _ => TaskStatus.pending,
      };
}

class CropTask {
  const CropTask({
    required this.id,
    required this.farmId,
    this.fieldId,
    this.planId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String farmId;
  final String? fieldId;
  final String? planId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? completedAt;

  factory CropTask.fromJson(Map<String, dynamic> json) => CropTask(
        id: json['id'] as String,
        farmId: json['farm_id'] as String,
        fieldId: json['field_id'] as String?,
        planId: json['plan_id'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: DateTime.parse(json['due_date'] as String),
        priority: TaskPriorityX.fromString(json['priority'] as String),
        status: TaskStatusX.fromString(json['status'] as String),
        assignedTo: json['assigned_to'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  bool get isOverdue =>
      status == TaskStatus.overdue ||
      (status == TaskStatus.pending &&
          dueDate.isBefore(DateTime.now()));

  bool get isCompleted => status == TaskStatus.completed;
}
