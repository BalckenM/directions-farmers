/// Employer registration details used on payslips, IRP5s and EMP201 returns.
/// Update these values to match the actual business registration.
class EmployerConfig {
  const EmployerConfig({
    required this.name,
    required this.registrationNumber,
    required this.uifReferenceNumber,
    required this.payeNumber,
  });

  final String name;
  final String registrationNumber;
  final String uifReferenceNumber;
  final String payeNumber;

  String get statutoryLine =>
      'Reg: $registrationNumber  ·  UIF: $uifReferenceNumber  ·  PAYE: $payeNumber';

  factory EmployerConfig.fromJson(Map<String, dynamic> json) => EmployerConfig(
    name: (json['name'] ?? json['companyName'] ?? '') as String,
    registrationNumber: (json['registrationNumber'] ?? '') as String,
    uifReferenceNumber:
        (json['uifReferenceNumber'] ?? json['uifNumber'] ?? '') as String,
    payeNumber: (json['payeNumber'] ?? '') as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'registrationNumber': registrationNumber,
    'uifReferenceNumber': uifReferenceNumber,
    'payeNumber': payeNumber,
  };

  // Default config — override via a provider in production.
  static const defaultConfig = EmployerConfig(
    name: '4Directions Farm',
    registrationNumber: '123/456',
    uifReferenceNumber: 'U123456',
    payeNumber: '7890123456',
  );
}
