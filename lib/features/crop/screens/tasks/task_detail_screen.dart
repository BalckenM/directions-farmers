import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../models/crop_task.dart';
import '../../providers/crop_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(cropTasksProvider(null));

    return tasksAsync.when(
      loading: () => FarmScaffold(
        appBar: FarmAppBar(title: 'Task Detail'),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 5, itemHeight: 80),
        ),
      ),
      error: (e, _) => FarmScaffold(
        appBar: FarmAppBar(title: 'Task Detail'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Failed to load tasks: $e',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (tasks) {
        CropTask? task;
        try {
          task = tasks.firstWhere((t) => t.id == taskId);
        } catch (_) {
          task = null;
        }

        if (task == null) {
          return FarmScaffold(
            appBar: FarmAppBar(title: 'Task Detail'),
            body: const Center(child: Text('Task not found.')),
          );
        }

        return _TaskDetailView(task: task);
      },
    );
  }
}

// ── Detail View ───────────────────────────────────────────────────────────────

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView({required this.task});

  final CropTask task;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── Sliver app bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: cs.primaryContainer,
            foregroundColor: cs.onPrimaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                task.title,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                color: cs.primaryContainer,
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Status card
                _StatusCard(task: task),
                const SizedBox(height: AppSpacing.md),

                // 2. Details card
                _DetailsCard(task: task),
                const SizedBox(height: AppSpacing.md),

                // 3. Dates card
                _DatesCard(task: task),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Edit Task',
        onPressed: () => context.push(AppRoutes.addCropTask),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.task});

  final CropTask task;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final statuses = [
      TaskStatus.pending,
      TaskStatus.inProgress,
      TaskStatus.completed,
      TaskStatus.delayed,
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Status',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatusChip(status: task.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: statuses.map((s) {
                final isActive = task.status == s;
                final color = _statusColor(s);
                final bgColor = _statusContainerColor(s);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isActive ? bgColor : null,
                        foregroundColor: isActive ? color : null,
                        side: BorderSide(
                          color: isActive ? color : AppColors.outlineVariant,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Status updated to ${s.label}'),
                          ),
                        );
                      },
                      child: Text(
                        s.label,
                        style: tt.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Details Card ──────────────────────────────────────────────────────────────

class _DetailsCard extends ConsumerWidget {
  const _DetailsCard({required this.task});

  final CropTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('d MMM yyyy');

    final fieldName = task.fieldId != null
        ? ref.watch(cropFieldByIdProvider(task.fieldId!)).value?.name ??
            task.fieldId!
        : null;

    String? planLabel;
    if (task.planId != null) {
      final plans = ref.watch(plantingPlansProvider(null)).value ?? [];
      final crops = ref.watch(cropsProvider(null)).value ?? [];
      final planMatches = plans.where((p) => p.id == task.planId);
      if (planMatches.isNotEmpty) {
        final plan = planMatches.first;
        final cropMatches = crops.where((c) => c.id == plan.cropId);
        final cropName =
            cropMatches.isNotEmpty ? cropMatches.first.name : plan.cropId;
        final status = plan.status;
        final statusLabel =
            status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);
        planLabel = '$cropName ($statusLabel)';
      } else {
        planLabel = task.planId!;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style:
                  tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            _DetailRow(
              icon: Icons.task_outlined,
              label: 'Title',
              value: task.title,
            ),

            // Description
            if (task.description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Description',
                value: task.description!,
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // Due date
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Due Date',
              value: dateFmt.format(task.dueDate),
              valueColor: task.isOverdue ? AppColors.error : null,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Priority badge
            Row(
              children: [
                Icon(Icons.flag_outlined,
                    size: AppSpacing.iconSm,
                    color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Text('Priority: ',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                _PriorityBadge(priority: task.priority),
              ],
            ),

            // Field name
            if (fieldName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.grid_on_rounded,
                label: 'Field',
                value: fieldName,
              ),
            ],

            // Plan label
            if (planLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.assignment_outlined,
                label: 'Plan',
                value: planLabel,
              ),
            ],

            // Assigned to
            if (task.assignedTo != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Assigned To',
                value: task.assignedTo!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Dates Card ────────────────────────────────────────────────────────────────

class _DatesCard extends StatelessWidget {
  const _DatesCard({required this.task});

  final CropTask task;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('d MMM yyyy, HH:mm');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style:
                  tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              icon: Icons.add_circle_outline_rounded,
              label: 'Created',
              value: dateFmt.format(task.createdAt),
            ),
            if (task.completedAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.check_circle_outline_rounded,
                label: 'Completed',
                value: dateFmt.format(task.completedAt!),
                valueColor: AppColors.success,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: AppSpacing.iconSm, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                value,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _statusContainerColor(status),
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        status.label,
        style: tt.labelSmall?.copyWith(
          color: _statusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _priorityContainerColor(priority),
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        priority.label,
        style: tt.labelSmall?.copyWith(
          color: _priorityColor(priority),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Color helpers ─────────────────────────────────────────────────────────────

Color _statusColor(TaskStatus status) => switch (status) {
      TaskStatus.pending => AppColors.warning,
      TaskStatus.inProgress => AppColors.tertiary,
      TaskStatus.completed => AppColors.success,
      TaskStatus.delayed => AppColors.secondary,
      TaskStatus.overdue => AppColors.error,
    };

Color _statusContainerColor(TaskStatus status) => switch (status) {
      TaskStatus.pending => AppColors.warningContainer,
      TaskStatus.inProgress => AppColors.tertiaryContainer,
      TaskStatus.completed => AppColors.successContainer,
      TaskStatus.delayed => AppColors.secondaryContainer,
      TaskStatus.overdue => AppColors.errorContainer,
    };

Color _priorityColor(TaskPriority priority) => switch (priority) {
      TaskPriority.low => AppColors.success,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.high => AppColors.secondary,
      TaskPriority.urgent => AppColors.error,
    };

Color _priorityContainerColor(TaskPriority priority) => switch (priority) {
      TaskPriority.low => AppColors.successContainer,
      TaskPriority.medium => AppColors.warningContainer,
      TaskPriority.high => AppColors.secondaryContainer,
      TaskPriority.urgent => AppColors.errorContainer,
    };
