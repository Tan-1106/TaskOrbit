import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_orbit/l10n/app_localizations.dart';
import 'package:task_orbit/core/common/layout/app_shell_layout.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_event.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_state.dart';
import 'package:task_orbit/features/agenda/presentation/widgets/horizontal_date_picker.dart';
import 'package:task_orbit/features/agenda/presentation/widgets/task_card.dart';
import 'package:task_orbit/features/agenda/presentation/widgets/add_edit_task_sheet.dart';
import 'package:task_orbit/features/agenda/presentation/widgets/filter_dialog.dart';
import 'package:task_orbit/features/agenda/presentation/widgets/category_management_sheet.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

enum _AgendaAction { addTask, filter, categoryManagement }

class _AgendaPageState extends State<AgendaPage> {
  bool _actionsInitialized = false;

  _AgendaAction? _activeAction;

  @override
  void initState() {
    super.initState();
    context.read<AgendaBloc>().add(AgendaLoadTasks(date: DateTime.now()));
    context.read<AgendaBloc>().add(AgendaLoadCategories());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_actionsInitialized) {
      _actionsInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setShellActions();
      });
    }
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
        icon: const Icon(Icons.label),
        tooltip: l10n.agendaManageCategories,
        onPressed: () async {
          if (_activeAction == _AgendaAction.categoryManagement) return;
          await _dismissCurrentAction();
          if (!mounted) return;
          setState(() => _activeAction = _AgendaAction.categoryManagement);
          await _showCategoryManagement(context);
          if (mounted) {
            setState(() {
              if (_activeAction == _AgendaAction.categoryManagement) {
                _activeAction = null;
              }
            });
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.filter_list),
        tooltip: l10n.agendaFilter,
        onPressed: () async {
          if (_activeAction == _AgendaAction.filter) return;
          await _dismissCurrentAction();
          if (!mounted) return;
          setState(() => _activeAction = _AgendaAction.filter);
          await _showFilterDialog(context);
          if (mounted) {
            setState(() {
              if (_activeAction == _AgendaAction.filter) _activeAction = null;
            });
          }
        },
      ),
    ]);
    shellActions.setFab(
      FloatingActionButton(
        onPressed: () async {
          if (_activeAction == _AgendaAction.addTask) return;
          await _dismissCurrentAction();
          if (!mounted) return;
          setState(() => _activeAction = _AgendaAction.addTask);
          await _showAddTaskSheet(context);
          if (mounted) {
            setState(() {
              if (_activeAction == _AgendaAction.addTask) _activeAction = null;
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up actions when leaving this page
    ShellActionsScope.of(context).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AgendaBloc, AgendaState>(
      listener: (context, state) {
        if (state is AgendaFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AgendaTaskActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Column(
          spacing: 8,
          children: [
            // ── Horizontal Date Picker ────────────────
            HorizontalDatePicker(
              selectedDate: state.selectedDate,
              currentMonth: state.currentMonth,
              onDateSelected: (date) {
                context.read<AgendaBloc>().add(AgendaDateChanged(date: date));
              },
              onMonthChanged: (month) {
                context.read<AgendaBloc>().add(
                  AgendaMonthChanged(month: month),
                );
              },
            ),
            const Divider(height: 1),

            // ── Task List ─────────────────────────────
            Expanded(
              child: state is AgendaLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.agendaNoTasks,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        final category = task.categoryId != null
                            ? state.categories
                                  .where((c) => c.id == task.categoryId)
                                  .firstOrNull
                            : null;

                        return TaskCard(
                          task: task,
                          category: category,
                          onTap: () => _openTaskDetail(context, task),
                          onToggleComplete: (_) {
                            _showToggleConfirm(context, task);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    final state = context.read<AgendaBloc>().state;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditTaskSheet(
        initialDate: state.selectedDate,
        categories: state.categories,
      ),
    );

    if (result != null && context.mounted) {
      context.read<AgendaBloc>().add(
        AgendaCreateTask(
          title: result['title'] as String,
          description: result['description'] as String?,
          date: result['date'] as DateTime,
          startTime: result['startTime'] as DateTime?,
          endTime: result['endTime'] as DateTime?,
          isAllDay: result['isAllDay'] as bool,
          categoryId: result['categoryId'] as String?,
        ),
      );
    }
  }

  Future<void> _openTaskDetail(BuildContext context, task) async {
    await context.push('/agenda/task-detail', extra: task);
    // Restore AgendaPage's actions after returning from TaskDetailPage
    if (mounted) _setShellActions();
  }

  void _showToggleConfirm(BuildContext context, task) {
    final l10n = AppLocalizations.of(context)!;
    final action = task.isCompleted
        ? l10n.taskDetailToggleMarkPending
        : l10n.taskDetailToggleMarkCompleted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.taskDetailToggleConfirmTitle),
        content: Text(l10n.taskDetailToggleContent(action, task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancelButton),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AgendaBloc>().add(
                AgendaToggleTaskComplete(taskId: task.id),
              );
            },
            child: Text(l10n.dialogConfirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final state = context.read<AgendaBloc>().state;
    final result = await showDialog<TaskFilter>(
      context: context,
      builder: (_) => FilterDialog(categories: state.categories),
    );

    if (result != null && context.mounted) {
      context.read<AgendaBloc>().add(AgendaSearchTasks(filter: result));
    }
  }

  Future<void> _showCategoryManagement(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AgendaBloc>(),
        child: const CategoryManagementSheet(),
      ),
    );
  }
}
