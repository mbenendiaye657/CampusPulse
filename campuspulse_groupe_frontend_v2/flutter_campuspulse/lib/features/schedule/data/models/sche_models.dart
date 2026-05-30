import '../../domaine/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.courseName,
    required super.teacher,
    required super.room,
    required super.startTime,
    required super.endTime,
    required super.day,
    required super.courseType,
    required super.typeIndex,
    required super.weekNumber,
  });

  /// ✅ FIX : champs alignés avec la réponse Django corrigée
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id:         json['id']          as int,
      courseName: json['course']      as String,      // ✅ 'course' pas 'courseName'
      teacher:    json['teacher']     as String,
      room:       json['room']        as String,
      day:        json['day']         as String,
      courseType: json['course_type'] as String? ?? 'CM',
      typeIndex:  json['type_index']  as int? ?? 0,
      weekNumber: json['week_number'] as int? ?? 1,
      // ✅ FIX : utilise start_time_full (DateTime ISO) pas start_time (TimeField HH:MM)
      startTime: DateTime.parse(json['start_time_full'] as String),
      endTime:   DateTime.parse(json['end_time_full']   as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':              id,
    'course':          courseName,
    'teacher':         teacher,
    'room':            room,
    'day':             day,
    'start_time_full': startTime.toIso8601String(),
    'end_time_full':   endTime.toIso8601String(),
    'course_type':     courseType,
    'type_index':      typeIndex,
    'week_number':     weekNumber,
  };
}
