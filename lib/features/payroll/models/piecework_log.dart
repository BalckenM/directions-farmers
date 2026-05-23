class PieceworkLog {
  const PieceworkLog({
    required this.id,
    required this.employeeId,
    required this.date,
    this.shiftId,
    required this.payrollCode,
    required this.unit,
    required this.quantity,
    required this.ratePerUnit,
    required this.recordedByUserId,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final String? shiftId;
  final String payrollCode;  // e.g. 'GRAPE_PICK'
  final String unit;         // e.g. 'kg', 'crates'
  final double quantity;
  final double ratePerUnit;
  final String recordedByUserId;
  final String? notes;
  final DateTime createdAt;

  double get totalEarnings => quantity * ratePerUnit;

  PieceworkLog copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    String? shiftId,
    String? payrollCode,
    String? unit,
    double? quantity,
    double? ratePerUnit,
    String? recordedByUserId,
    String? notes,
    DateTime? createdAt,
  }) {
    return PieceworkLog(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      shiftId: shiftId ?? this.shiftId,
      payrollCode: payrollCode ?? this.payrollCode,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      recordedByUserId: recordedByUserId ?? this.recordedByUserId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
