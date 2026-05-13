import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatBodyConditionScreen extends ConsumerStatefulWidget {
  const GoatBodyConditionScreen({super.key});

  @override
  ConsumerState<GoatBodyConditionScreen> createState() =>
      _GoatBodyConditionScreenState();
}

class _GoatBodyConditionScreenState
    extends ConsumerState<GoatBodyConditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  double _score = 3.0;

  static const List<double> _scores = [
    1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0
  ];

  @override
  void dispose() {
    _animalIdController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = BodyConditionRecord(
      id: 'bcs_${DateTime.now().millisecondsSinceEpoch}',
      animalId: _animalIdController.text.trim(),
      date: _dateController.text.trim(),
      score: _score,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newBcsRecordProvider.notifier)
        .addRecord(_animalIdController.text.trim(), record);
    _animalIdController.clear();
    _dateController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _score = 3.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bcsAsync = ref.watch(allGoatBcsRecordsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Body Condition',
        subtitle: 'All animals',
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
                      Text('Record BCS',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _animalIdController,
                            decoration: const InputDecoration(
                                labelText: 'Animal Tag / ID *'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Animal ID required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                      ]),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<double>(
                        value: _score,
                        decoration:
                            const InputDecoration(labelText: 'BCS Score *'),
                        items: _scores
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.toStringAsFixed(1))))
                            .toList(),
                        onChanged: (v) => setState(() => _score = v!),
                      ),
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
                              : const Text('Save BCS Record'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: bcsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) => records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_rounded,
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
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          child: ListTile(
                            leading: _BcsIndicator(score: r.score),
                            title: Text(r.animalId),
                            subtitle: Text(r.date),
                            trailing: r.notes != null
                                ? Tooltip(
                                    message: r.notes!,
                                    child: const Icon(
                                        Icons.info_outline, size: 16),
                                  )
                                : null,
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

class _BcsIndicator extends StatelessWidget {
  const _BcsIndicator({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (score <= 2) {
      bg = Colors.red.shade200;
    } else if (score >= 4) {
      bg = Colors.green.shade200;
    } else {
      bg = Colors.orange.shade200;
    }
    return CircleAvatar(
      backgroundColor: bg,
      radius: 22,
      child: Text(
        score.toStringAsFixed(1),
        style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
