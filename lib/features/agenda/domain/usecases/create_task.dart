import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';
import 'package:task_orbit/core/services/notification_service.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';
import 'package:task_orbit/l10n/app_localizations.dart';

class CreateTask implements UseCase<Task, Task> {
  final ITaskRepository repository;
  final NotificationService notificationService;
  final LocaleNotifier localeNotifier;

  const CreateTask(this.repository, this.notificationService, this.localeNotifier);

  @override
  Future<Either<Failure, Task>> call(Task task) async {
    final result = await repository.createTask(task: task);

    return result.map((createdTask) {
      if (createdTask.notificationMinutesBefore != null) {
        DateTime baseTime;
        if (createdTask.isAllDay) {
          baseTime = DateTime(
            createdTask.date.year,
            createdTask.date.month,
            createdTask.date.day,
          );
        } else {
          baseTime =
              createdTask.startTime ??
              DateTime(
                createdTask.date.year,
                createdTask.date.month,
                createdTask.date.day,
              );
        }

        final scheduledTime = baseTime.subtract(
          Duration(minutes: createdTask.notificationMinutesBefore!),
        );

        if (scheduledTime.isAfter(DateTime.now())) {
          final l10n = lookupAppLocalizations(localeNotifier.value);
          notificationService.scheduleNotification(
            id: createdTask.id.hashCode,
            title: l10n.notifTaskReminderTitle(createdTask.title),
            body: createdTask.description ?? l10n.notifTaskReminderBody,
            scheduledTime: scheduledTime,
          );
        }
      }
      return createdTask;
    });
  }
}
