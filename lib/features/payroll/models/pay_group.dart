// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pay_group.freezed.dart';
part 'pay_group.g.dart';

enum PayFrequency { weekly, biweekly, monthly, daily }

@freezed
abstract class PayGroup with _$PayGroup {
  const PayGroup._();

  const factory PayGroup({
    required String id,
    required String name,
    required PayFrequency frequency,
    required int payDayOffset,
    String? description,
    required bool isActive,
    required DateTime createdAt,
  }) = _PayGroup;

  factory PayGroup.fromJson(Map<String, dynamic> json) =>
      _$PayGroupFromJson(json);

  String get frequencyLabel => switch (frequency) {
        PayFrequency.weekly => 'Weekly',
        PayFrequency.biweekly => 'Bi-weekly',
        PayFrequency.monthly => 'Monthly',
        PayFrequency.daily => 'Daily',
      };
}
