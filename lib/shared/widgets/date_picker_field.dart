import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// A read-only text field that opens a [DatePickerDialog] on tap.
///
/// The selected date is surfaced via [onChanged]. Use [firstDate] / [lastDate]
/// to constrain valid range (e.g. birthdate must be in the past).
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select date',
    this.firstDate,
    this.lastDate,
    this.validator,
    this.enabled = true,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? validator;
  final bool enabled;

  String _format(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        return GestureDetector(
          onTap: enabled
              ? () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.value ?? DateTime.now(),
                    firstDate: firstDate ?? DateTime(1900),
                    lastDate: lastDate ?? DateTime.now(),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    onChanged(picked);
                  }
                }
              : null,
          child: AbsorbPointer(
            child: TextFormField(
              enabled: enabled,
              readOnly: true,
              controller: TextEditingController(
                text: state.value != null ? _format(state.value!) : '',
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                suffixIcon: const Icon(Icons.calendar_today_rounded),
                border:
                    OutlineInputBorder(borderRadius: AppRadius.button),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                errorText: state.errorText,
              ),
            ),
          ),
        );
      },
    );
  }
}
