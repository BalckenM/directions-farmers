import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/crop_task.dart';
import '../../providers/crop_providers.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key, this.taskId});

  /// When non-null, the screen is in edit mode for the given task ID.
  final String? taskId;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _notesController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  bool _isSaving = false;

  bool get _isEditing => widget.taskId != null;

  static const _priorities = [
    (TaskPriority.urgent, 'Urgent'),
    (TaskPriority.high, 'High'),
    (TaskPriority.medium, 'Medium'),
    (TaskPriority.low, 'Low'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(cropRepositoryProvider);
    final now = DateTime.now();
    final id = widget.taskId ?? 'task-${now.millisecondsSinceEpoch}';

    final farmId = ref.read(currentFarmIdProvider);
    final task = CropTask(
      id: id,
      farmId: farmId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _dueDate!,
      priority: _priority,
      status: TaskStatus.pending,
      assignedTo: _assignedToController.text.trim().isEmpty
          ? null
          : _assignedToController.text.trim(),
      createdAt: now,
    );

    try {
      if (_isEditing) {
        await repo.updateTask(task);
      } else {
        await repo.addTask(task);
      }
      ref.invalidate(cropTasksProvider);
      ref.invalidate(openCropTasksProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Task updated' : 'Task saved')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: FarmAppBar(
        title: _isEditing ? 'Edit Task' : 'Add Task',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.task_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe what needs to be done…',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_outlined),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Due date
            DatePickerField(
              label: 'Due Date',
              value: _dueDate,
              onChanged: (d) => setState(() => _dueDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            // Priority
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _priorities
                  .map((p) => DropdownMenuItem(
                        value: p.$1,
                        child: Row(
                          children: [
                            _PriorityDot(priority: p.$1),
                            const SizedBox(width: AppSpacing.sm),
                            Text(p.$2),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _priority = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Assigned to
            TextFormField(
              controller: _assignedToController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Assigned To (optional)',
                hintText: 'Person responsible',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any additional notes…',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save button
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : Text(
                      _isEditing ? 'Update Task' : 'Save Task',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.onPrimary),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.urgent => AppColors.error,
      TaskPriority.high => AppColors.secondary,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.low => AppColors.disabledForeground,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
