import 'package:dio/dio.dart';
import '../../../../core/services/auth_services.dart';
import '../models/sche_models.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedules(int weekNumber);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final Dio dio = Dio(BaseOptions(
    baseUrl:        'http://127.0.0.1:8000/api',
    connectTimeout: const Duration(seconds: 10),
  ));

  @override
  Future<List<ScheduleModel>> getSchedules(int weekNumber) async {
    final token = await AuthService.getToken();

    final response = await dio.get(
      '/schedules/',
      queryParameters: {'week_number': weekNumber},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    // ✅ Django retourne { week_number, student, courses: [...] }
    final List courses = response.data['courses'] as List;
    return courses
        .map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
