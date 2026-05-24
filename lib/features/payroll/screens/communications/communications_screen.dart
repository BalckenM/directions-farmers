import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../models/communication_log.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _dateFmt = DateFormat('d MMM y');
final _dtFmt   = DateFormat('d MMM y, HH:mm');

class CommunicationsScreen extends ConsumerStatefulWidget {
  const CommunicationsScreen({super.key});

  @override
  ConsumerState<CommunicationsScreen> createState() =>
      _CommunicationsScreenState();
}

class _CommunicationsScreenState extends ConsumerState<CommunicationsScreen> {
  CommunicationChannel? _channelFilter;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final all = ref.watch(communicationsProvider);
    final sorted = List<CommunicationLog>.from(all)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

    final filtered = _channelFilter == null
        ? sorted
        : sorted.where((c) => c.channel == _channelFilter).toList();

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Communications'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeSheet(context),
        icon: const Icon(Icons.send_outlined),
        label: const Text('Compose'),
        backgroundColor: PayrollTokens.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Summary row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
            child: Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${all.length} message${all.length == 1 ? '' : 's'} sent',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                Text(
                  'Avg delivery: ${_avgDelivery(all)}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // ── Channel filter chips ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text('All (${all.length})'),
                      selected: _channelFilter == null,
                      onSelected: (_) =>
                          setState(() => _channelFilter = null),
                    ),
                  ),
                  ...CommunicationChannel.values.map((ch) {
                    final count =
                        all.where((c) => c.channel == ch).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        avatar: Icon(_channelIcon(ch),
                            size: 14,
                            color: _channelFilter == ch
                                ? Colors.white
                                : _channelColor(ch)),
                        label: Text('${_channelLabel(ch)} ($count)'),
                        selected: _channelFilter == ch,
                        onSelected: (_) =>
                            setState(() => _channelFilter = ch),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icon(Icons.mail_outline_rounded,
                        size: 56, color: PayrollTokens.sky),
                    title: 'No communications',
                    subtitle: 'No messages match the selected channel.',
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(communicationsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.xs,
                          AppSpacing.md, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (ctx, i) => _CommCard(
                        log: filtered[i],
                        onTap: () => _showDetail(ctx, filtered[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _avgDelivery(List<CommunicationLog> logs) {
    if (logs.isEmpty) return '—';
    final avg =
        logs.fold(0.0, (sum, l) => sum + l.deliveryRate) / logs.length;
    return '${(avg * 100).toStringAsFixed(0)}%';
  }

  void _showDetail(BuildContext context, CommunicationLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommDetailSheet(log: log),
    );
  }

  void _showComposeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ComposeSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Communication Card
// ─────────────────────────────────────────────────────────────────────────────

class _CommCard extends StatelessWidget {
  const _CommCard({required this.log, required this.onTap});
  final CommunicationLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final deliveryPct  = (log.deliveryRate * 100).toInt();
    final deliveryColor = deliveryPct >= 90
        ? PayrollTokens.green
        : deliveryPct >= 70
            ? PayrollTokens.amber
            : PayrollTokens.rose;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      color: cs.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _channelColor(log.channel).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_channelIcon(log.channel),
                        size: 18, color: _channelColor(log.channel)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.subject,
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(_channelLabel(log.channel),
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$deliveryPct%',
                          style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: deliveryColor)),
                      Text('delivery',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(log.body,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                      '${log.totalRecipients} recipient${log.totalRecipients == 1 ? '' : 's'}',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.check_circle_outline_rounded,
                      size: 14, color: PayrollTokens.green),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${log.deliveredCount} delivered',
                      style: tt.labelSmall
                          ?.copyWith(color: PayrollTokens.green)),
                  if (log.failedCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.cancel_outlined,
                        size: 14, color: PayrollTokens.rose),
                    const SizedBox(width: AppSpacing.xs),
                    Text('${log.failedCount} failed',
                        style: tt.labelSmall
                            ?.copyWith(color: PayrollTokens.rose)),
                  ],
                  const Spacer(),
                  Text(_dateFmt.format(log.sentAt),
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Communication Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CommDetailSheet extends ConsumerWidget {
  const _CommDetailSheet({required this.log});
  final CommunicationLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees   = ref.watch(employeesProvider);
    final empMap      = {for (final e in employees) e.id: e.fullName};
    final cs          = Theme.of(context).colorScheme;
    final tt          = Theme.of(context).textTheme;
    final deliveryPct = (log.deliveryRate * 100).toInt();
    final mq          = MediaQuery.of(context);
    final deliveryColor = deliveryPct >= 90
        ? PayrollTokens.green
        : deliveryPct >= 70
            ? PayrollTokens.amber
            : PayrollTokens.rose;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(
                    top: AppSpacing.sm, bottom: AppSpacing.xs),
                decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _channelColor(log.channel).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_channelIcon(log.channel),
                        size: 22, color: _channelColor(log.channel)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.subject,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(_channelLabel(log.channel),
                            style: tt.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Body
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(log.body, style: tt.bodyMedium),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Delivery rate
                  Text('Delivery Rate',
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: log.deliveryRate,
                            minHeight: 10,
                            backgroundColor:
                                cs.surfaceContainerHighest,
                            valueColor:
                                AlwaysStoppedAnimation(deliveryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$deliveryPct%',
                          style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: deliveryColor)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _statBadge(context, log.totalRecipients.toString(),
                          'Total', PayrollTokens.sky),
                      const SizedBox(width: AppSpacing.sm),
                      _statBadge(context, log.deliveredCount.toString(),
                          'Delivered', PayrollTokens.green),
                      const SizedBox(width: AppSpacing.sm),
                      _statBadge(context, log.failedCount.toString(),
                          'Failed', PayrollTokens.rose),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Recipients
                  Text('Recipients (${log.recipientEmployeeIds.length})',
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  ...log.recipientEmployeeIds.map((id) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 16, color: cs.onSurfaceVariant),
                            const SizedBox(width: AppSpacing.sm),
                            Text(empMap[id] ?? id,
                                style: tt.bodyMedium),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppSpacing.md),

                  // Meta
                  Text('Details',
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  _metaRow(context, 'Sent', _dtFmt.format(log.sentAt)),
                  _metaRow(context, 'Sent by', log.sentByUserId),
                  _metaRow(context, 'Template', log.templateCode),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(
      BuildContext context, String val, String label, Color color) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(val,
                style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: tt.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compose Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ComposeSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  CommunicationChannel _channel = CommunicationChannel.sms;
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl    = TextEditingController();
  final Set<String> _selectedEmployees = {};
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final mq        = MediaQuery.of(context);
    final tt        = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg,
          AppSpacing.lg, mq.viewInsets.bottom + AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Compose Message',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),

            // Channel
            DropdownButtonFormField<CommunicationChannel>(
              initialValue: _channel,
              decoration: const InputDecoration(
                labelText: 'Channel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.send_outlined),
              ),
              items: CommunicationChannel.values
                  .map((ch) => DropdownMenuItem(
                        value: ch,
                        child: Row(children: [
                          Icon(_channelIcon(ch),
                              size: 16, color: _channelColor(ch)),
                          const SizedBox(width: AppSpacing.sm),
                          Text(_channelLabel(ch)),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _channel = v!),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Subject
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Body
            TextField(
              controller: _bodyCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message body',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Recipients
            Text('Recipients', style: tt.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: employees
                  .map((e) => FilterChip(
                        label: Text(e.fullName),
                        selected: _selectedEmployees.contains(e.id),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _selectedEmployees.add(e.id);
                            } else {
                              _selectedEmployees.remove(e.id);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            PrimaryButton(
              label: 'Send Message',
              icon: const Icon(Icons.send_outlined),
              isLoading: _sending,
              isExpanded: true,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (_subjectCtrl.text.trim().isEmpty ||
        _bodyCtrl.text.trim().isEmpty ||
        _selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill in all fields and select at least one recipient.'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _sending = true);
    ref.read(payrollRepositoryProvider).sendCommunication(
          channel: _channel,
          templateCode: 'CUSTOM',
          subject: _subjectCtrl.text.trim(),
          body: _bodyCtrl.text.trim(),
          recipientEmployeeIds: _selectedEmployees.toList(),
          sentByUserId: 'usr_manager',
        );
    ref.invalidate(communicationsProvider);
    setState(() => _sending = false);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Message sent successfully.'),
            backgroundColor: PayrollTokens.green,
            behavior: SnackBarBehavior.floating),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — channel icon / color / label
// ─────────────────────────────────────────────────────────────────────────────

IconData _channelIcon(CommunicationChannel ch) => switch (ch) {
      CommunicationChannel.sms      => Icons.sms_outlined,
      CommunicationChannel.whatsapp => Icons.chat_outlined,
      CommunicationChannel.email    => Icons.email_outlined,
      CommunicationChannel.inApp    => Icons.notifications_outlined,
      CommunicationChannel.push     => Icons.send_outlined,
    };

Color _channelColor(CommunicationChannel ch) => switch (ch) {
      CommunicationChannel.sms      => PayrollTokens.teal,
      CommunicationChannel.whatsapp => PayrollTokens.green,
      CommunicationChannel.email    => PayrollTokens.sky,
      CommunicationChannel.inApp    => PayrollTokens.purple,
      CommunicationChannel.push     => PayrollTokens.amber,
    };

String _channelLabel(CommunicationChannel ch) => switch (ch) {
      CommunicationChannel.sms      => 'SMS',
      CommunicationChannel.whatsapp => 'WhatsApp',
      CommunicationChannel.email    => 'Email',
      CommunicationChannel.inApp    => 'In-App',
      CommunicationChannel.push     => 'Push',
    };

