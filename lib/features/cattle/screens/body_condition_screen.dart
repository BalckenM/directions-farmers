import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class BodyConditionScreen extends ConsumerStatefulWidget {
  const BodyConditionScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<BodyConditionScreen> createState() =>
      _BodyConditionScreenState();
}

class _BodyConditionScreenState
    extends ConsumerState<BodyConditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  double _score = 3.0;
  String _scoredBy = '';

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = BodyConditionRecord(
      id: 'bcs_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      date: _dateController.text.trim(),
      score: _score,
      assessedBy: _scoredBy.isEmpty ? null : _scoredBy,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattleBcsRecordProvider.notifier)
        .addRecord(widget.cattleId, record);
    _dateController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _score = 3.0;
      _scoredBy = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final recordsAsync =
        ref.watch(cattleBcsRecordsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Body Condition Scores',
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
                      Text('Add BCS Record',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                            labelText: 'Date *',
                            hintText: 'YYYY-MM-DD',
                            prefixIcon:
                                Icon(Icons.calendar_today_rounded)),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Date required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'BCS Score: ${_score.toStringAsFixed(1)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium),
                      Slider(
                        value: _score,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        label: _score.toStringAsFixed(1),
                        onChanged: (v) =>
                            setState(() => _score = v),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Scored By'),
                        onChanged: (v) => _scoredBy = v,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)'),
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
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: recordsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) => records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monitor_weight_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No BCS records'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final r = records[i];
                        Color scoreColor = Colors.green;
                        if (r.score < 2.5 || r.score > 4.0)
                          scoreColor = Colors.orange;
                        if (r.score < 2.0 || r.score > 4.5)
                          scoreColor =
                              Theme.of(context).colorScheme.error;
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.monitor_weight_rounded,
                                    size: 18, color: scoreColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(r.date,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      if (r.assessedBy != null)
                                        Text(
                                            'By: ${r.assessedBy}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall),
                                    ],
                                  ),
                                ),
                                Text(
                                  r.score.toStringAsFixed(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color: scoreColor,
                                          fontWeight: FontWeight.bold),
                                ),
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
