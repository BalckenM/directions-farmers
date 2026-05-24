// Unit tests for AuthUser model — fromJson, toJson, copyWith, computed getters.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/models/auth_user.dart';

void main() {
  final base = AuthUser(
    id: 'u1',
    email: 'farmer@example.com',
    firstName: 'John',
    lastName: 'Doe',
    farmName: 'Sunrise Farm',
    country: 'ZA',
    province: 'Western Cape',
    subscriptionPlan: 'growth',
    subscriptionStatus: 'active',
    activatedModules: ['cattle', 'poultry', 'crop'],
    mfaEnabled: false,
    trialEndsAt: null,
    phone: '+27821234567',
  );

  group('AuthUser.fromJson', () {
    test('parses all required fields', () {
      final json = {
        'id': 'u1',
        'email': 'farmer@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
        'farm_name': 'Sunrise Farm',
        'country': 'ZA',
        'province': 'Western Cape',
        'subscription_plan': 'growth',
        'subscription_status': 'active',
        'activated_modules': ['cattle', 'poultry'],
        'mfa_enabled': false,
      };
      final user = AuthUser.fromJson(json);
      expect(user.id, 'u1');
      expect(user.email, 'farmer@example.com');
      expect(user.firstName, 'John');
      expect(user.farmName, 'Sunrise Farm');
      expect(user.subscriptionPlan, 'growth');
      expect(user.activatedModules, ['cattle', 'poultry']);
    });

    test('uses defaults for missing optional fields', () {
      final user = AuthUser.fromJson({
        'id': 'u2',
        'email': 'new@example.com',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'farm_name': 'Green Acres',
        'country': 'ZA',
        'province': 'Limpopo',
      });
      expect(user.subscriptionPlan, 'starter');
      expect(user.subscriptionStatus, 'trial');
      expect(user.activatedModules, isEmpty);
      expect(user.mfaEnabled, isFalse);
      expect(user.trialEndsAt, isNull);
      expect(user.phone, isNull);
    });

    test('parses trialEndsAt ISO string to DateTime', () {
      final user = AuthUser.fromJson({
        'id': 'u3',
        'email': 'trial@example.com',
        'first_name': 'Bob',
        'last_name': 'Trial',
        'farm_name': 'Trial Farm',
        'country': 'ZA',
        'province': 'Gauteng',
        'trial_ends_at': '2025-06-30T00:00:00.000Z',
      });
      expect(user.trialEndsAt, isNotNull);
      expect(user.trialEndsAt!.year, 2025);
      expect(user.trialEndsAt!.month, 6);
    });
  });

  group('AuthUser computed getters', () {
    test('fullName concatenates first and last name', () {
      expect(base.fullName, 'John Doe');
    });

    test('isOnTrial is false for active subscription', () {
      expect(base.isOnTrial, isFalse);
    });

    test('isOnTrial is true for trial subscription', () {
      final trialUser = base.copyWith(subscriptionStatus: 'trial');
      expect(trialUser.isOnTrial, isTrue);
    });

    test('hasModule returns true for activated module', () {
      expect(base.hasModule('cattle'), isTrue);
      expect(base.hasModule('poultry'), isTrue);
    });

    test('hasModule returns false for missing module', () {
      expect(base.hasModule('payroll'), isFalse);
    });
  });

  group('AuthUser.toJson', () {
    test('round-trip serialisation preserves fields', () {
      final json = base.toJson();
      expect(json['id'], base.id);
      expect(json['email'], base.email);
      expect(json['first_name'], base.firstName);
      expect(json['farm_name'], base.farmName);
      expect(json['subscription_plan'], base.subscriptionPlan);
      expect(json['activated_modules'], base.activatedModules);
      expect(json['phone'], base.phone);
    });

    test('toJsonString produces valid JSON string', () {
      final str = base.toJsonString();
      expect(str, isA<String>());
      expect(str, contains(base.email));
    });
  });

  group('AuthUser.copyWith', () {
    test('returns same values when no override', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.email, base.email);
      expect(copy.subscriptionPlan, base.subscriptionPlan);
      expect(copy.activatedModules, base.activatedModules);
    });

    test('overrides specific fields only', () {
      final copy = base.copyWith(
        subscriptionPlan: 'enterprise',
        mfaEnabled: true,
        phone: '+27829876543',
      );
      expect(copy.subscriptionPlan, 'enterprise');
      expect(copy.mfaEnabled, isTrue);
      expect(copy.phone, '+27829876543');
      // Unchanged
      expect(copy.id, base.id);
      expect(copy.email, base.email);
      expect(copy.farmName, base.farmName);
    });

    test('overrides activatedModules', () {
      final copy = base.copyWith(activatedModules: ['cattle', 'payroll']);
      expect(copy.activatedModules, ['cattle', 'payroll']);
      expect(copy.activatedModules.length, 2);
    });
  });
}
