import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class CalvingScreen extends ConsumerStatefulWidget {
  const CalvingScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<CalvingScreen> createState() => _CalvingScreenState();
}

class _CalvingScreenState extends ConsumerState<CalvingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _totalBornController = TextEditingController();
  final _aliveController = TextEditingController();
  final _complicationsController = TextEditingController();

  bool _assisted = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _totalBornController.dispose();
    _aliveController.dispose();
    _complicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync =
        ref.watch(cattleCalvingEventsProvider(widget.cattleId));
    final animal = ref.watch(cattleDetailProvider(widget.cattleId));
    final animalName =
        animal.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Calving Records', subtitle: animalName),
      body: Column(
        children: [
          Expanded(
            child: eventsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (events) => events.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.child_care_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No calving events recorded'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _CalvingCard(event: events[i]),
                    ),
            ),
          ),
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
                    Text('Record Calving Event',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Calving Date *',
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Date required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _totalBornController,
                      decoration: const InputDecoration(
                          labelText: 'Calf Weight (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      value: _assisted,
                      title: const Text('Assisted birth'),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _assisted = v),
                    ),
                    TextFormField(
                      controller: _complicationsController,
                      decoration: const InputDecoration(
                        labelText: 'Complications (optional)',
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
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
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final event = CalvingEvent(
      id: 'calv-${DateTime.now().millisecondsSinceEpoch}',
      damId: widget.cattleId,
      calvingDate: _dateController.text.trim(),
      calvingEase: _assisted ? 'assisted' : 'easy',
      calfAlive: true,
      calfWeightKg: double.tryParse(_totalBornController.text.trim()),
      complications: _complicationsController.text.trim().isEmpty
          ? null
          : _complicationsController.text.trim(),
    );

    ref.read(newCalvingEventProvider.notifier).addEvent(widget.cattleId, event);

    _dateController.clear();
    _totalBornController.clear();
    _aliveController.clear();
    _complicationsController.clear();
    setState(() {
      _isSaving = false;
      _assisted = false;
    });
  }
}

class _CalvingCard extends StatelessWidget {
  const _CalvingCard({required this.event});
  final CalvingEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.child_care_rounded, size: 18),
                const SizedBox(width: 6),
                Text(event.calvingDate,
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (event.calvingEase != 'easy')
                  Chip(
                    label: Text(event.calvingEase),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _Stat(
                    label: 'Calf Alive',
                    value: event.calfAlive ? 'Yes' : 'No',
                    valueColor: event.calfAlive ? Colors.green : null),
                if (event.calfWeightKg != null) ...[
                  const SizedBox(width: 24),
                  _Stat(
                      label: 'Weight',
                      value:
                          '${event.calfWeightKg!.toStringAsFixed(1)} kg'),
                ],
              ],
            ),
            if (event.complications != null) ...[
              const SizedBox(height: 4),
              Text(
                'Complications: ${event.complications}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                )),
      ],
    );
  }
}
