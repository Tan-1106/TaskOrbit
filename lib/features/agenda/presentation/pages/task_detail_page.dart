import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:task_orbit/features/agenda/presentation/widgets/add_edit_task_sheet.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

enum _TaskDetailAction { edit, delete }

class _TaskDetailPageState extends State<TaskDetailPage> {
  _TaskDetailAction? _activeAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _setShellActions();
    });
  }

  Future<void> _dismissCurrentAction() async {
    if (_activeAction != null && mounted) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _setShellActions() {
    final l10n = AppLocalizations.of(context)!;
    final shellActions = ShellActionsScope.of(context);
    shellActions.setActions([
      IconButton(
        icon: const Icon(Icons.edit_outlined),
        tooltip: l10n.taskDetailEditTooltip,
        onPressed: () async {
          if (_activeAction == _TaskDetailAction.edit) return;
          await _dismissCurrentAction();
          if (!mounted) return;
          setState(() => _activeAction = _TaskDetailAction.edit);
          await _showEditSheet(context, l10n);
          if (mounted) {
            setState(() {
              if (_activeAction == _TaskDetailAction.edit) _activeAction = null;
            });
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.delete_outlined),
        tooltip: l10n.taskDetailDeleteTooltip,
        onPressed: () async {
          if (_activeAction == _TaskDetailAction.delete) return;
          await _dismissCurrentAction();
          if (!mounted) return;
          setState(() => _activeAction = _TaskDetailAction.delete);
          await _showDeleteDialog(context, l10n);
          if (mounted) {
            setState(() {
              if (_activeAction == _TaskDetailAction.delete) {
                _activeAction = null;
              }
            });
          }
        },
      ),
    ]);
    shellActions.setFab(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final task = widget.task;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            task.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 12),

          // Status chip
          Chip(
            label: Text(
              task.isCompleted
                  ? l10n.taskDetailStatusCompleted
                  : l10n.taskDetailStatusPending,
              style: TextStyle(
                color: task.isCompleted
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            backgroundColor: task.isCompleted
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.primaryContainer,
          ),
          const SizedBox(height: 16),

          // Date
          _InfoRow(
            icon: Icons.calendar_today,
            label: l10n.taskDetailLabelDate,
            value: DateFormat('EEEE, d MMMM yyyy').format(task.date),
          ),

          // Time
          if (task.isAllDay)
            _InfoRow(
              icon: Icons.schedule,
              label: l10n.taskDetailLabelTime,
              value: l10n.taskDetailLabelAllDay,
            )
          else if (task.startTime != null && task.endTime != null)
            _InfoRow(
              icon: Icons.schedule,
              label: l10n.taskDetailLabelTime,
              value:
                  '${DateFormat.Hm().format(task.startTime!)} – ${DateFormat.Hm().format(task.endTime!)}',
            ),

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.taskDetailLabelDescription,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: theme.textTheme.bodyLarge,
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showEditSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final state = context.read<AgendaBloc>().state;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditTaskSheet(
        isEditing: true,
        initialTitle: widget.task.title,
        initialDescription: widget.task.description,
        initialDate: widget.task.date,
        initialStartTime: widget.task.startTime,
        initialEndTime: widget.task.endTime,
        initialIsAllDay: widget.task.isAllDay,
        initialCategoryId: widget.task.categoryId,
        categories: state.categories,
      ),
    );

    if (result != null && context.mounted) {
      await _showConfirmDialog(
        context,
        title: l10n.taskDetailConfirmEdit,
        content: l10n.taskDetailConfirmEditContent,
        onConfirm: () {
          context.read<AgendaBloc>().add(
            AgendaUpdateTask(
              taskId: widget.task.id,
              title: result['title'] as String,
              description: result['description'] as String?,
              date: result['date'] as DateTime,
              startTime: result['startTime'] as DateTime?,
              endTime: result['endTime'] as DateTime?,
              isAllDay: result['isAllDay'] as bool,
              categoryId: result['categoryId'] as String?,
              isCompleted: widget.task.isCompleted,
            ),
          );
          context.pop(); // Go back to AgendaPage
        },
      );
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await _showConfirmDialog(
      context,
      title: l10n.taskDetailDeleteTitle,
      content: l10n.taskDetailDeleteContent(widget.task.title),
      onConfirm: () {
        context.read<AgendaBloc>().add(
          AgendaDeleteTask(taskId: widget.task.id),
        );
        context.pop();
      },
    );
  }

  Future<void> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancelButton),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: Text(l10n.dialogConfirmButton),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
