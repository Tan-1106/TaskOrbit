import 'package:fpdart/fpdart.dart' hide Task;
import 'package:task_orbit/core/error/failure.dart';
import 'package:task_orbit/core/usecases/usecase.dart';
import 'package:task_orbit/features/agenda/domain/entities/task.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';
import 'package:task_orbit/core/services/notification_service.dart';

class CreateTask implements UseCase<Task, Task> {
  final ITaskRepository repository;
  final NotificationService notificationService;

  const CreateTask(this.repository, this.notificationService);

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
          notificationService.scheduleNotification(
            id: createdTask.id.hashCode,
            title: 'Reminder: ${createdTask.title}',
            body: createdTask.description ?? 'You have an upcoming task.',
            scheduledTime: scheduledTime,
          );
        }
      }
      return createdTask;
    });
  }
}
