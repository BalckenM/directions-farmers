import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class HealthEventsScreen extends ConsumerStatefulWidget {
  const HealthEventsScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<HealthEventsScreen> createState() =>
      _HealthEventsScreenState();
}

class _HealthEventsScreenState extends ConsumerState<HealthEventsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _vetController = TextEditingController();
  final _withdrawalController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _severity = 'mild';

  @override
  void dispose() {
    _dateController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _vetController.dispose();
    _withdrawalController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final combinedNotes = [
      if (_treatmentController.text.trim().isNotEmpty)
        'Treatment: ${_treatmentController.text.trim()}',
      if (_withdrawalController.text.trim().isNotEmpty)
        'Withdrawal ends: ${_withdrawalController.text.trim()}',
    ].join('\n');
    final event = CattleHealthEvent(
      id: 'he_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      date: _dateController.text.trim(),
      eventType: 'illness',
      diagnosis: _diagnosisController.text.trim(),
      severity: _severity,
      treatedBy: _vetController.text.trim().isEmpty
          ? null
          : _vetController.text.trim(),
      notes: combinedNotes.isEmpty ? null : combinedNotes,
    );
    ref
        .read(newCattleHealthEventProvider.notifier)
        .addEvent(widget.cattleId, event);
    _dateController.clear();
    _diagnosisController.clear();
    _treatmentController.clear();
    _vetController.clear();
    _withdrawalController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _severity = 'mild';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final eventsAsync =
        ref.watch(cattleHealthEventsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Health Events',
        subtitle: animalName,
        actions: [
          IconButton(
            icon: Icon(
                _showForm ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () => setState(() => _showForm = !_showForm),
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
                      Text('Add Health Event',
                          style: Theme.of(context).textTheme.titleSmall),
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
                        controller: _diagnosisController,
                        decoration: const InputDecoration(
                            labelText: 'Diagnosis / Condition *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Diagnosis required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _treatmentController,
                        decoration: const InputDecoration(
                            labelText: 'Treatment (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vetController,
                            decoration: const InputDecoration(
                                labelText: 'Vet Name'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _withdrawalController,
                            decoration: const InputDecoration(
                                labelText: 'Withdrawal End',
                                hintText: 'YYYY-MM-DD'),
                          ),
                        ),
                      ]),
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
                              : const Text('Save'),
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
                          Icon(Icons.healing_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No health events'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final e = events[i];
                        Color severityColor = Colors.green;
                        if (e.severity == 'moderate')
                          severityColor = Colors.orange;
                        if (e.severity == 'severe')
                          severityColor =
                              Theme.of(context).colorScheme.error;
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.healing_rounded,
                                        size: 18,
                                        color: severityColor),
                                    const SizedBox(width: 6),
                                    Text(e.date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    Chip(
                                      label: Text(e.severity),
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      backgroundColor:
                                          severityColor.withOpacity(0.15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(e.diagnosis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.w500)),
                                if (e.treatedBy != null)
                                  Text('Vet: ${e.treatedBy}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                if (e.notes != null)
                                  Text('Notes: ${e.notes}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
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
