import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';
import 'package:task_orbit/core/services/notification_service.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class UpdateTask implements UseCase<Task, Task> {
  final ITaskRepository repository;
  final NotificationService notificationService;
  final LocaleNotifier localeNotifier;

  const UpdateTask(this.repository, this.notificationService, this.localeNotifier);

  @override
  Future<Either<Failure, Task>> call(Task task) async {
    final result = await repository.updateTask(task: task);

    return result.map((updatedTask) {
      notificationService.cancelNotification(updatedTask.id.hashCode);

      if (!updatedTask.isCompleted && !updatedTask.isDeleted && updatedTask.notificationMinutesBefore != null) {
        DateTime baseTime;
        if (updatedTask.isAllDay) {
          baseTime = DateTime(
            updatedTask.date.year,
            updatedTask.date.month,
            updatedTask.date.day,
          );
        } else {
          baseTime =
              updatedTask.startTime ??
              DateTime(
                updatedTask.date.year,
                updatedTask.date.month,
                updatedTask.date.day,
              );
        }

        final scheduledTime = baseTime.subtract(
          Duration(minutes: updatedTask.notificationMinutesBefore!),
        );

        if (scheduledTime.isAfter(DateTime.now())) {
          final l10n = lookupAppLocalizations(localeNotifier.value);
          notificationService.scheduleNotification(
            id: updatedTask.id.hashCode,
            title: l10n.notifTaskReminderTitle(updatedTask.title),
            body: updatedTask.description ?? l10n.notifTaskReminderBody,
            scheduledTime: scheduledTime,
          );
        }
      }
      return updatedTask;
    });
  }
}
