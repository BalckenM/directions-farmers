import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/payroll/models/leave_type.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/services/payroll_engine.dart';

void main() {
  final annual = LeaveType(
    id: 'lt1',
    code: 'ANNUAL',
    name: 'Annual Leave',
    annualEntitlementDays: 15,
    isPaid: true,
    requiresApproval: true,
  );

  final employee = PayrollEmployee(
    id: 'emp1',
    firstName: 'Test',
    lastName: 'Worker',
    idOrPassportNumber: '9001015009087',
    address: '1 Farm Rd',
    nextOfKinName: 'Next Kin',
    nextOfKinPhone: '0821234567',
    status: EmploymentStatus.active,
    engagementType: EngagementType.permanent,
    occupationTitle: 'Worker',
    startDate: DateTime(2024, 1, 1),
    disbursementMethod: DisbursementMethod.bank,
    preferredLanguage: 'en',
    hasHousingBenefit: false,
    hasFoodBenefit: false,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('PayrollEngine.accrueLeave', () {
    test('full year (12 months) accrues full entitlement', () {
      final balance = PayrollEngine.accrueLeave(
        employee: employee,
        leaveType: annual,
        completedMonths: 12,
      );
      expect(balance, closeTo(15.0, 0.0001));
    });

    test('one month accrues 1/12 of annual entitlement', () {
      final balance = PayrollEngine.accrueLeave(
        employee: employee,
        leaveType: annual,
        completedMonths: 1,
      );
      expect(balance, closeTo(15 / 12, 0.0001));
    });

    test('six months accrues half entitlement', () {
      final balance = PayrollEngine.accrueLeave(
        employee: employee,
        leaveType: annual,
        completedMonths: 6,
      );
      expect(balance, closeTo(7.5, 0.0001));
    });

    test('balance is capped at maxCarryOver when specified', () {
      final balance = PayrollEngine.accrueLeave(
        employee: employee,
        leaveType: annual,
        completedMonths: 24, // 2 years without taking leave
        maxCarryOver: 20.0,
      );
      expect(balance, closeTo(20.0, 0.0001));
    });

    test('no cap when maxCarryOver is null', () {
      final balance = PayrollEngine.accrueLeave(
        employee: employee,
        leaveType: annual,
        completedMonths: 24,
      );
      expect(balance, closeTo(30.0, 0.0001));
    });
  });

  group('PayrollEngine.bcea20DaysWorkedAccrual', () {
    test('17 days worked accrues 1 day', () {
      expect(PayrollEngine.bcea20DaysWorkedAccrual(17), closeTo(1.0, 0.0001));
    });

    test('34 days worked accrues 2 days', () {
      expect(PayrollEngine.bcea20DaysWorkedAccrual(34), closeTo(2.0, 0.0001));
    });

    test('0 days worked accrues 0', () {
      expect(PayrollEngine.bcea20DaysWorkedAccrual(0), equals(0.0));
    });
  });
}
