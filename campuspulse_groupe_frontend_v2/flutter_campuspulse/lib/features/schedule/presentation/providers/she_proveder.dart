import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/network/conn.dart';
import '../../data/datasource/she_local.dart';
import '../../data/datasource/she_remote.dart';
import '../../data/repositor/she_rep.dart';
import '../../domaine/entities/schedule_entity.dart';
import '../../domaine/usecases/she_use.dart';

// Semaine sélectionnée (modifiable par l'UI)
final selectedWeekProvider = StateProvider<int>((ref) {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  return ((now.difference(startOfYear).inDays) / 7).ceil();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});

final remoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((ref) {
  return ScheduleRemoteDataSourceImpl();
});

final localDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  return ScheduleLocalDataSourceImpl();
});

final scheduleRepositoryProvider = Provider<ScheduleRepositoryImpl>((ref) {
  return ScheduleRepositoryImpl(
    remoteDataSource:   ref.read(remoteDataSourceProvider),
    localDataSource:    ref.read(localDataSourceProvider),
    connectivityService: ref.read(connectivityServiceProvider),
  );
});

final getScheduleUseCaseProvider = Provider<GetScheduleUseCase>((ref) {
  return GetScheduleUseCase(ref.read(scheduleRepositoryProvider));
});

// Provider principal — se recharge quand la semaine change
final scheduleProvider = FutureProvider<List<ScheduleEntity>>((ref) async {
  final weekNumber = ref.watch(selectedWeekProvider);
  final useCase    = ref.read(getScheduleUseCaseProvider);
  return await useCase(weekNumber);
});
