class LeaveType {
  const LeaveType({
    required this.id,
    required this.code,
    required this.name,
    required this.annualEntitlementDays,
    required this.isPaid,
    required this.requiresApproval,
    this.colorHex,
    this.description,
  });

  final String id;

  /// Machine code, e.g. 'ANNUAL', 'SICK', 'MATERNITY'.
  final String code;
  final String name;
  final double annualEntitlementDays;
  final bool isPaid;
  final bool requiresApproval;
  final String? colorHex;
  final String? description;

  factory LeaveType.fromJson(Map<String, dynamic> json) => LeaveType(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        annualEntitlementDays: (json['annualEntitlementDays'] as num).toDouble(),
        isPaid: json['isPaid'] as bool,
        requiresApproval: json['requiresApproval'] as bool,
        colorHex: json['colorHex'] as String?,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'annualEntitlementDays': annualEntitlementDays,
        'isPaid': isPaid,
        'requiresApproval': requiresApproval,
        'colorHex': colorHex,
        'description': description,
      };
}
