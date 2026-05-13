import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../models/crop_task.dart';
import '../../providers/crop_providers.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['All', 'Pending', 'Overdue', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CropTask> _filter(List<CropTask> tasks, int tabIndex) {
    return switch (tabIndex) {
      1 => tasks
          .where((t) =>
              t.status == TaskStatus.pending && !t.isOverdue)
          .toList(),
      2 => tasks.where((t) => t.isOverdue).toList(),
      3 => tasks.where((t) => t.isCompleted).toList(),
      _ => tasks,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(cropTasksProvider(null));

    return tasksAsync.when(
      loading: () => FarmScaffold(
        appBar: AppBar(title: const Text('Farm Tasks')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 5),
        ),
      ),
      error: (err, _) => FarmScaffold(
        appBar: AppBar(title: const Text('Farm Tasks')),
        body: Center(
          child: Text('Failed to load tasks',
              style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
      data: (tasks) {
        final overdueCount =
            tasks.where((t) => t.isOverdue).length;

        return FarmScaffold(
          appBar: AppBar(
            title: const Text('Farm Tasks'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs.asMap().entries.map((e) {
                final idx = e.key;
                final label = e.value;
                if (idx == 2 && overdueCount > 0) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        const SizedBox(width: AppSpacing.xs),
                        _Badge(count: overdueCount),
                      ],
                    ),
                  );
                }
                return Tab(text: label);
              }).toList(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_task_list',
            onPressed: () => context.push(AppRoutes.addCropTask),
            child: const Icon(Icons.add),
          ),
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
              _tabs.length,
              (idx) {
                final filtered = _filter(tasks, idx);
                if (filtered.isEmpty) {
                  return _EmptyTasks(label: _tabs[idx]);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _TaskCard(task: filtered[i]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final CropTask task;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM yyyy');
    final isOverdue = task.isOverdue;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        border: isOverdue
            ? const Border(
                left: BorderSide(color: AppColors.error, width: 4))
            : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: isOverdue
              ? const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                )
              : AppRadius.card,
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.cropTaskDetailPath(task.id)),
          borderRadius: isOverdue
              ? const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                )
              : AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + priority chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _PriorityChip(priority: task.priority),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Due date + status
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: AppSpacing.iconSm,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      fmt.format(task.dueDate),
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusChip(status: task.status),
                  ],
                ),

                // Assigned to
                if (task.assignedTo != null &&
                    task.assignedTo!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: AppSpacing.iconSm,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        task.assignedTo!,
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      TaskPriority.urgent => (AppColors.errorContainer, AppColors.onErrorContainer),
      TaskPriority.high => (
          const Color(0xFFFFE0B2),
          const Color(0xFF2D1600)
        ),
      TaskPriority.medium => (
          const Color(0xFFFFF8E1),
          const Color(0xFF4A3800)
        ),
      TaskPriority.low => (
          AppColors.surfaceContainerHighest,
          AppColors.onSurfaceVariant
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        priority.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TaskStatus.completed => (
          AppColors.successContainer,
          AppColors.onSuccessContainer
        ),
      TaskStatus.overdue => (
          AppColors.errorContainer,
          AppColors.onErrorContainer
        ),
      TaskStatus.inProgress => (
          AppColors.tertiaryContainer,
          AppColors.onTertiaryContainer
        ),
      TaskStatus.delayed => (
          AppColors.warningContainer,
          AppColors.onWarningContainer
        ),
      _ => (AppColors.surfaceContainerHighest, AppColors.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.error,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onError,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.task_alt_outlined,
              size: AppSpacing.iconXl, color: AppColors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No $label tasks',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
