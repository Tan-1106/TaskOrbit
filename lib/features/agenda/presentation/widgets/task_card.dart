import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/entities/category.dart';

enum TaskStatus { pending, inProgress, overdue, completed }

class TaskCard extends StatelessWidget {
  final Task task;
  final Category? category;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onTap,
    required this.onToggleComplete,
  });

  TaskStatus _getStatus() {
    if (task.isCompleted) return TaskStatus.completed;

    final now = DateTime.now();

    if (task.isAllDay) {
      final endOfDay = DateTime(task.date.year, task.date.month, task.date.day, 23, 59, 59);
      if (now.isAfter(endOfDay)) return TaskStatus.overdue;
      return TaskStatus.inProgress;
    }

    if (task.startTime != null && task.endTime != null) {
      if (now.isBefore(task.startTime!)) return TaskStatus.pending;
      if (now.isAfter(task.endTime!)) return TaskStatus.overdue;
      return TaskStatus.inProgress;
    }

    return TaskStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _getStatus();

    final (Color cardColor, Color textColor) = switch (status) {
      TaskStatus.pending => (
        theme.colorScheme.primaryContainer,
        theme.colorScheme.onPrimaryContainer,
      ),
      TaskStatus.inProgress => (
        theme.colorScheme.tertiaryContainer,
        theme.colorScheme.onTertiaryContainer,
      ),
      TaskStatus.overdue => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.onErrorContainer,
      ),
      TaskStatus.completed => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    String timeText;
    if (task.isAllDay) {
      timeText = 'All day';
    } else if (task.startTime != null && task.endTime != null) {
      timeText = '${DateFormat.Hm().format(task.startTime!)} â€“ ${DateFormat.Hm().format(task.endTime!)}';
    } else {
      timeText = '';
    }

    return Card(
      color: cardColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: onToggleComplete,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: category!.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            task.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (timeText.isNotEmpty || category != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (timeText.isNotEmpty) ...[
                            Icon(Icons.schedule, size: 14, color: textColor.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text(
                              timeText,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                          if (timeText.isNotEmpty && category != null) const SizedBox(width: 12),
                          if (category != null)
                            Text(
                              category!.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: textColor.withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
