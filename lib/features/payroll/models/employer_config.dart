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

  // Default config — override via a provider in production.
  static const defaultConfig = EmployerConfig(
    name:                 '4Directions Farm',
    registrationNumber:   '123/456',
    uifReferenceNumber:   'U123456',
    payeNumber:           '7890123456',
  );
}
