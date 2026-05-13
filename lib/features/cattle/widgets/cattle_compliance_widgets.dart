import 'package:flutter/material.dart';

import '../models/cattle_records.dart';

// ── FMD zone indicator ────────────────────────────────────────────────────────

/// Shows a colored chip indicating the FMD zone status of an animal.
class FmdZoneIndicator extends StatelessWidget {
  const FmdZoneIndicator({super.key, this.zone});

  final String? zone;

  @override
  Widget build(BuildContext context) {
    if (zone == null) {
      return const Chip(
        label: Text('Zone Unknown', style: TextStyle(fontSize: 12)),
        backgroundColor: Colors.grey,
        labelStyle: TextStyle(color: Colors.white),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      );
    }

    final lower = zone!.toLowerCase();
    Color bgColor;
    IconData icon;
    String label;

    if (lower.contains('free')) {
      bgColor = Colors.green.shade600;
      icon = Icons.check_circle_rounded;
      label = 'FMD Free Zone';
    } else if (lower.contains('protection')) {
      bgColor = Colors.orange.shade700;
      icon = Icons.warning_rounded;
      label = 'FMD Protection Zone';
    } else if (lower.contains('infected')) {
      bgColor = Colors.red.shade700;
      icon = Icons.dangerous_rounded;
      label = 'FMD Infected Zone';
    } else {
      bgColor = Colors.grey.shade600;
      icon = Icons.help_outline_rounded;
      label = zone!;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: bgColor,
      labelStyle: const TextStyle(color: Colors.white),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Withdrawal countdown ──────────────────────────────────────────────────────

/// Shows the withdrawal period countdown for a medication log entry.
/// Displays meat and milk withdrawal days remaining using the
/// `withdrawalExpiryDateMeat` and `withdrawalExpiryDateMilk` computed getters.
class WithdrawalCountdown extends StatelessWidget {
  const WithdrawalCountdown({super.key, required this.log});

  final CattleMedicationLog log;

  int? _daysRemaining(String? expiryDateStr) {
    if (expiryDateStr == null) return null;
    try {
      final expiry = DateTime.parse(expiryDateStr);
      final days = expiry.difference(DateTime.now()).inDays;
      return days > 0 ? days : 0;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meatDays = _daysRemaining(log.withdrawalExpiryDateMeat);
    final milkDays = _daysRemaining(log.withdrawalExpiryDateMilk);

    final hasActiveMeat = meatDays != null && meatDays > 0;
    final hasActiveMilk = milkDays != null && milkDays > 0;
    final isActive = hasActiveMeat || hasActiveMilk;

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isActive
          ? Theme.of(context).colorScheme.errorContainer
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(
                isActive
                    ? Icons.hourglass_bottom_rounded
                    : Icons.check_circle_rounded,
                color: isActive
                    ? Theme.of(context).colorScheme.error
                    : Colors.green.shade700,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  log.medicationName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isActive
                            ? Theme.of(context).colorScheme.error
                            : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.error
                      : Colors.green.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'IN WITHDRAWAL' : 'CLEAR',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            if (meatDays != null) ...[
              const SizedBox(height: 6),
              _WithdrawalRow(
                icon: Icons.set_meal_rounded,
                label: 'Meat',
                days: meatDays,
              ),
            ],
            if (milkDays != null) ...[
              const SizedBox(height: 4),
              _WithdrawalRow(
                icon: Icons.water_drop_outlined,
                label: 'Milk',
                days: milkDays,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WithdrawalRow extends StatelessWidget {
  const _WithdrawalRow({
    required this.icon,
    required this.label,
    required this.days,
  });

  final IconData icon;
  final String label;
  final int days;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(
        '$label: ',
        style:
            TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      Text(
        days == 0 ? 'Cleared today' : '$days day${days == 1 ? '' : 's'} remaining',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: days > 0
              ? Theme.of(context).colorScheme.error
              : Colors.green.shade700,
        ),
      ),
    ]);
  }
}

// ── Notifiable disease prompt ─────────────────────────────────────────────────

/// Displays a prominent warning banner if any health events are notifiable
/// diseases that must be reported to the State Veterinarian.
class NotifiableDiseasePrompt extends StatelessWidget {
  const NotifiableDiseasePrompt({super.key, required this.events});

  final List<CattleHealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final notifiable =
        events.where((e) => e.isNotifiable).toList();

    if (notifiable.isEmpty) return const SizedBox.shrink();

    final diagnoses = notifiable.map((e) => e.diagnosis).toSet().join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade400, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.crisis_alert_rounded,
              color: Colors.red.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTIFIABLE DISEASE DETECTED',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  diagnoses,
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Report to State Vet immediately as required by law.',
                  style: TextStyle(
                      color: Colors.red.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
