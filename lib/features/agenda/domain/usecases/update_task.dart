import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';
import 'package:task_orbit/core/services/notification_service.dart';

class UpdateTask implements UseCase<Task, Task> {
  final ITaskRepository repository;
  final NotificationService notificationService;

  const UpdateTask(this.repository, this.notificationService);

  @override
  Future<Either<Failure, Task>> call(Task task) async {
    final result = await repository.updateTask(task: task);

    return result.map((updatedTask) {
      // Always cancel existing notification to reset it cleanly
      notificationService.cancelNotification(updatedTask.id.hashCode);

      if (!updatedTask.isCompleted &&
          !updatedTask.isDeleted &&
          updatedTask.notificationMinutesBefore != null) {
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
          notificationService.scheduleNotification(
            id: updatedTask.id.hashCode,
            title: 'Reminder: ${updatedTask.title}',
            body: updatedTask.description ?? 'You have an upcoming task.',
            scheduledTime: scheduledTime,
          );
        }
      }
      return updatedTask;
    });
  }
}
