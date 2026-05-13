import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatHealthEventsScreen extends ConsumerStatefulWidget {
  const GoatHealthEventsScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<GoatHealthEventsScreen> createState() =>
      _GoatHealthEventsScreenState();
}

class _GoatHealthEventsScreenState
    extends ConsumerState<GoatHealthEventsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _conditionController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _vetController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _severity = 'mild';
  String? _outcome;

  @override
  void dispose() {
    _dateController.dispose();
    _conditionController.dispose();
    _treatmentController.dispose();
    _vetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final event = GoatHealthEvent(
      id: 'he_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.goatId,
      date: _dateController.text.trim(),
      condition: _conditionController.text.trim(),
      severity: _severity,
      treatment: _treatmentController.text.trim().isEmpty
          ? null
          : _treatmentController.text.trim(),
      vet: _vetController.text.trim().isEmpty
          ? null
          : _vetController.text.trim(),
      outcome: _outcome,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref.read(newHealthEventProvider.notifier).addEvent(widget.goatId, event);
    final condition = _conditionController.text.trim();
    _dateController.clear();
    _conditionController.clear();
    _treatmentController.clear();
    _vetController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _severity = 'mild';
      _outcome = null;
    });
    _checkNotifiableDisease(condition);
  }

  void _checkNotifiableDisease(String condition) {
    const notifiable = [
      'ppr',
      'peste des petits',
      'sheep pox',
      'goat pox',
      'foot and mouth',
      'fmd',
    ];
    final lower = condition.toLowerCase();
    if (!notifiable.any((k) => lower.contains(k))) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifiable Disease — Mandatory Report Required'),
        content: const Text(
          'This condition may be a notifiable disease under the Animal Diseases Act.\n\n'
          'DAFF Emergency Hotline: 012 319 7000',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mark as Reported'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(animalHealthEventsProvider(widget.goatId));
    final animalAsync = ref.watch(animalDetailProvider(widget.goatId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.goatId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Health Events',
        subtitle: animalName,
        actions: [
          IconButton(
            icon: Icon(
                _showForm ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () =>
                setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm)
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log Health Event',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                                labelText: 'Date *',
                                hintText: 'YYYY-MM-DD'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Date required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _severity,
                            decoration: const InputDecoration(
                                labelText: 'Severity'),
                            items: ['mild', 'moderate', 'severe']
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _severity = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _conditionController,
                        decoration: const InputDecoration(
                            labelText: 'Condition / Diagnosis *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Condition required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _treatmentController,
                        decoration: const InputDecoration(
                            labelText: 'Treatment (optional)'),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vetController,
                            decoration: const InputDecoration(
                                labelText: 'Vet (optional)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            value: _outcome,
                            decoration: const InputDecoration(
                                labelText: 'Outcome'),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('—')),
                              ...['resolved', 'monitoring', 'deceased']
                                  .map((o) => DropdownMenuItem(
                                      value: o, child: Text(o)))
                            ],
                            onChanged: (v) =>
                                setState(() => _outcome = v),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Save Health Event'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (events) => events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No health events recorded'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final ev = events[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.favorite_outlined,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(ev.date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    _SeverityBadge(
                                        severity: ev.severity),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(ev.condition,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.w600)),
                                if (ev.treatment != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                      'Treatment: ${ev.treatment}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                                if (ev.outcome != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Outcome: ${ev.outcome}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                                if (ev.vet != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Vet: ${ev.vet}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});
  final String severity;

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (severity.toLowerCase()) {
      case 'severe':
        bg = Colors.red.shade100;
        break;
      case 'moderate':
        bg = Colors.orange.shade100;
        break;
      default:
        bg = Colors.green.shade100;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(severity,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
