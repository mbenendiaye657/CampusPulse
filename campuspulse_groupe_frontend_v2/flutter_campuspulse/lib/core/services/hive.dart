import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String scheduleBox = 'schedules_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(scheduleBox);
  }
}
