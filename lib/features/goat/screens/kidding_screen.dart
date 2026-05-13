import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatKiddingScreen extends ConsumerStatefulWidget {
  const GoatKiddingScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<GoatKiddingScreen> createState() => _GoatKiddingScreenState();
}

class _GoatKiddingScreenState extends ConsumerState<GoatKiddingScreen> {
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
    final eventsAsync = ref.watch(animalKiddingEventsProvider(widget.goatId));
    final animal = ref.watch(animalDetailProvider(widget.goatId));

    final animalName = animal.asData?.value?.displayName ?? widget.goatId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Kidding Records',
        subtitle: animalName,
      ),
      body: Column(
        children: [
          Expanded(
            child: eventsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (events) => events.isEmpty
                  ? const _EmptyKidding()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _KiddingCard(event: events[i]),
                    ),
            ),
          ),
          _AddKiddingForm(
            formKey: _formKey,
            dateController: _dateController,
            totalBornController: _totalBornController,
            aliveController: _aliveController,
            complicationsController: _complicationsController,
            assisted: _assisted,
            isSaving: _isSaving,
            onAssistedChanged: (v) => setState(() => _assisted = v),
            onSave: _save,
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final totalBorn = int.tryParse(_totalBornController.text.trim()) ?? 1;
    final kidsAlive = int.tryParse(_aliveController.text.trim()) ?? totalBorn;

    final event = KiddingEvent(
      id: 'kidd-${DateTime.now().millisecondsSinceEpoch}',
      damId: widget.goatId,
      kiddingDate: _dateController.text.trim(),
      totalKidsBorn: totalBorn,
      kidsAliveBorn: kidsAlive,
      kidsStillborn: totalBorn - kidsAlive,
      birthWeights: [],
      kidIds: [],
      assisted: _assisted,
      complications: _complicationsController.text.trim().isEmpty
          ? null
          : _complicationsController.text.trim(),
    );

    ref.read(newKiddingEventProvider.notifier).addEvent(widget.goatId, event);
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

class _KiddingCard extends StatelessWidget {
  const _KiddingCard({required this.event});
  final KiddingEvent event;

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
                Text(
                  event.kiddingDate,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (event.assisted)
                  Chip(
                    label: const Text('Assisted'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _Stat(label: 'Total Born', value: '${event.totalKidsBorn}'),
                const SizedBox(width: 24),
                _Stat(label: 'Alive', value: '${event.kidsAliveBorn}'),
                if (event.kidsAliveBorn < event.totalKidsBorn)
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: _Stat(
                      label: 'Losses',
                      value:
                          '${event.totalKidsBorn - event.kidsAliveBorn}',
                      valueColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
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

class _EmptyKidding extends StatelessWidget {
  const _EmptyKidding();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('No kidding events recorded'),
        ],
      ),
    );
  }
}

class _AddKiddingForm extends StatelessWidget {
  const _AddKiddingForm({
    required this.formKey,
    required this.dateController,
    required this.totalBornController,
    required this.aliveController,
    required this.complicationsController,
    required this.assisted,
    required this.isSaving,
    required this.onAssistedChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController totalBornController;
  final TextEditingController aliveController;
  final TextEditingController complicationsController;
  final bool assisted;
  final bool isSaving;
  final ValueChanged<bool> onAssistedChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Kidding Event',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Kidding Date *',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Date required' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: totalBornController,
                      decoration: const InputDecoration(
                        labelText: 'Total Born *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: aliveController,
                      decoration: const InputDecoration(
                        labelText: 'Alive Born',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: assisted,
                title: const Text('Assisted birth'),
                contentPadding: EdgeInsets.zero,
                onChanged: onAssistedChanged,
              ),
              TextFormField(
                controller: complicationsController,
                decoration: const InputDecoration(
                  labelText: 'Complications (optional)',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSaving ? null : onSave,
                  child: const Text('Save Kidding Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
