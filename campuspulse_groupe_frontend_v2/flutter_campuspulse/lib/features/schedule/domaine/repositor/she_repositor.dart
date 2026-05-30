import '../entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getSchedules(int weekNumber);
}
