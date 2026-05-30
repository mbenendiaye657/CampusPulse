import '../entities/schedule_entity.dart';
import '../repositor/she_repositor.dart';

class GetScheduleUseCase {
  final ScheduleRepository repository;
  GetScheduleUseCase(this.repository);

  Future<List<ScheduleEntity>> call(int weekNumber) async {
    return await repository.getSchedules(weekNumber);
  }
}
