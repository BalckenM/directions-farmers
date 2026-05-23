import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_dropdown.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_text_field.dart';
import '../../models/attendance_record.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../widgets/payroll_widgets.dart';


final _dfClock = DateFormat('d MMMM y');

class ClockInScreen extends ConsumerStatefulWidget {
  const ClockInScreen({super.key});

  @override
  ConsumerState<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends ConsumerState<ClockInScreen> {
  String? _employeeId;
  AttendanceMethod _method = AttendanceMethod.manual;
  final _timeCtrl  = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _otCtrl    = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date   = DateTime.now();
  bool _isClockIn  = true;

  @override
  void dispose() {
    _timeCtrl.dispose();
    _hoursCtrl.dispose();
    _otCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final isLoading = ref.watch(attendanceNotifierProvider) is AsyncLoading;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Clock In / Out'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // -- Mode toggle ----------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _ModeTab(
                  label: 'Clock In',
                  icon: Icons.login_rounded,
                  selected: _isClockIn,
                  color: PayrollTokens.green,
                  onTap: () => setState(() => _isClockIn = true),
                ),
                _ModeTab(
                  label: 'Clock Out',
                  icon: Icons.logout_rounded,
                  selected: !_isClockIn,
                  color: PayrollTokens.rose,
                  onTap: () => setState(() => _isClockIn = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // -- Employee & Date section ----------------------------------------
          PrSectionCard(
            title: 'Who & When',
            icon: Icons.person_pin_outlined,
            iconColor: PayrollTokens.navy,
            children: [
              FarmDropdown<String?>(
                label: 'Employee',
                value: _employeeId,
                hint: 'Select employee',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('Select employee')),
                  ...employees.map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.id,
                      child: Text('${e.firstName} ${e.lastName}'),
                    ),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _employeeId = v);
                  _autoDetectMode();
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Date picker
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) {
                    setState(() => _date = d);
                    _autoDetectMode();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(_dfClock.format(_date),
                            style: tt.bodyMedium),
                      ),
                      Icon(Icons.edit_calendar_outlined,
                          color: cs.onSurfaceVariant, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // -- Time & Details section -----------------------------------------
          PrSectionCard(
            title: _isClockIn ? 'Clock In Details' : 'Clock Out Details',
            icon: _isClockIn
                ? Icons.timelapse_rounded
                : Icons.timer_off_outlined,
            iconColor: _isClockIn ? PayrollTokens.green : PayrollTokens.rose,
            children: [
              FarmTextField(
                controller: _timeCtrl,
                label:
                    _isClockIn ? 'Clock In Time (HH:mm)' : 'Clock Out Time (HH:mm)',
                hint: '07:30',
                prefixIcon: const Icon(Icons.access_time_rounded),
              ),

              if (_isClockIn) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('Method', style: tt.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: AttendanceMethod.values.map((m) {
                    final selected = _method == m;
                    return ChoiceChip(
                      label: Text(_methodLabel(m)),
                      selected: selected,
                      selectedColor: PayrollTokens.navy.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: selected ? PayrollTokens.navy : cs.outlineVariant,
                      ),
                      labelStyle: TextStyle(
                        color: selected ? PayrollTokens.navy : cs.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _method = m),
                    );
                  }).toList(),
                ),
              ],

              if (!_isClockIn) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FarmTextField(
                        controller: _hoursCtrl,
                        label: 'Hours Worked',
                        hint: '8.0',
                        prefixIcon: const Icon(Icons.schedule_rounded),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FarmTextField(
                        controller: _otCtrl,
                        label: 'OT Hours',
                        hint: '0',
                        prefixIcon: const Icon(Icons.more_time_rounded),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.]')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.sm),
              FarmTextField(
                controller: _notesCtrl,
                label: 'Notes (optional)',
                hint: 'Add any relevant notes',
                prefixIcon: const Icon(Icons.notes_outlined),
                maxLines: 2,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // -- Submit button -------------------------------------------------
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _isClockIn ? PayrollTokens.green : PayrollTokens.rose,
              ),
              onPressed: (_employeeId == null || isLoading) ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isClockIn ? 'Clock In' : 'Clock Out'),
            ),
          ),
        ],
      ),
    );
  }

  /// Auto-switch to Clock-Out mode when the selected employee already has an
  /// open attendance record (clocked in but not yet clocked out) for [_date].
  void _autoDetectMode() {
    if (_employeeId == null) return;
    final records = ref.read(
        attendanceProvider(AttendanceFilter(employeeId: _employeeId)));
    final hasOpen = records.any((r) =>
        r.date.year == _date.year &&
        r.date.month == _date.month &&
        r.date.day == _date.day &&
        r.clockOutTime == null &&
        r.clockInTime != null);
    if (hasOpen != !_isClockIn) {
      setState(() => _isClockIn = !hasOpen);
    }
  }

  Future<void> _submit() async {
    final timeStr = _timeCtrl.text.isEmpty
        ? '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'
        : _timeCtrl.text.trim();

    if (_isClockIn) {
      final result =
          await ref.read(attendanceNotifierProvider.notifier).clockIn(
                employeeId: _employeeId!,
                date: _date,
                clockInTime: timeStr,
                method: _method,
                notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
              );
      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clocked in successfully.'),
            backgroundColor: PayrollTokens.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      final records = ref.read(
          attendanceProvider(AttendanceFilter(employeeId: _employeeId)));
      final today = records.where((r) =>
          r.employeeId == _employeeId &&
          r.date.year == _date.year &&
          r.date.month == _date.month &&
          r.date.day == _date.day);
      final existing = today.isNotEmpty ? today.first : null;
      if (existing == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No clock-in record found for today.')),
        );
        return;
      }
      final hours = double.tryParse(_hoursCtrl.text) ?? 0;
      final ot = double.tryParse(_otCtrl.text) ?? 0;
      final result =
          await ref.read(attendanceNotifierProvider.notifier).clockOut(
                attendanceId: existing.id,
                clockOutTime: timeStr,
                hoursWorked: hours,
                overtimeHours: ot > 0 ? ot : null,
                notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
              );
      if (!mounted) return;
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clocked out successfully.'),
            backgroundColor: PayrollTokens.green,
          ),
        );
        if (mounted) Navigator.of(context).pop();
      }
    }
  }
}

// --- Mode tab ----------------------------------------------------------------

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helpers -----------------------------------------------------------------

String _methodLabel(AttendanceMethod m) => switch (m) {
      AttendanceMethod.manual    => 'Manual',
      AttendanceMethod.gps       => 'GPS',
      AttendanceMethod.qrCode    => 'QR Code',
      AttendanceMethod.biometric => 'Biometric',
    };