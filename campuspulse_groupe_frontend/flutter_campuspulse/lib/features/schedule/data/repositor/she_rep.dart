import '../../../../core/network/conn.dart';
import '../../domaine/entities/schedule_entity.dart';
import '../../domaine/repositor/she_repositor.dart';
import '../datasource/she_local.dart';
import '../datasource/she_remote.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final ScheduleLocalDataSource  localDataSource;
  final ConnectivityService      connectivityService;

  ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<List<ScheduleEntity>> getSchedules(int weekNumber) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final remoteSchedules = await remoteDataSource.getSchedules(weekNumber);
        await localDataSource.cacheSchedules(remoteSchedules, weekNumber);
        return remoteSchedules;
      } catch (_) {
        return localDataSource.getCachedSchedules(weekNumber);
      }
    }
    return localDataSource.getCachedSchedules(weekNumber);
  }
}
