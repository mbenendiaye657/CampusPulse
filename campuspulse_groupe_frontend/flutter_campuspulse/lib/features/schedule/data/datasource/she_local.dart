import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/hive.dart';
import '../models/sche_models.dart';

abstract class ScheduleLocalDataSource {
  Future<void> cacheSchedules(List<ScheduleModel> schedules, int weekNumber);
  Future<List<ScheduleModel>> getCachedSchedules(int weekNumber);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final box = Hive.box(HiveService.scheduleBox);

  @override
  Future<void> cacheSchedules(List<ScheduleModel> schedules, int weekNumber) async {
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await box.put('schedules_week_$weekNumber', jsonList);
  }

  @override
  Future<List<ScheduleModel>> getCachedSchedules(int weekNumber) async {
    final data = box.get('schedules_week_$weekNumber');
    if (data == null) return [];
    return (data as List)
        .map((json) => ScheduleModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
