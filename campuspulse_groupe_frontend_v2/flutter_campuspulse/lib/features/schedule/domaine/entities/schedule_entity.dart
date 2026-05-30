class ScheduleEntity {
  final int    id;
  final String courseName;   // ← 'course' dans Django
  final String teacher;
  final String room;
  final DateTime startTime;  // ✅ FIX : DateTime complet (pas TimeField seul)
  final DateTime endTime;
  final String day;
  final String courseType;   // CM, TD, TP, EXAM
  final int    typeIndex;    // 0,1,2,3 pour Flutter
  final int    weekNumber;

  const ScheduleEntity({
    required this.id,
    required this.courseName,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.courseType,
    required this.typeIndex,
    required this.weekNumber,
  });
}
