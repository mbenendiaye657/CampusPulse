import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import '../../domaine/entities/schedule_entity.dart';

class ScheduleCalendarDataSource extends CalendarDataSource {
  ScheduleCalendarDataSource(List<ScheduleEntity> schedules) {
    appointments = schedules.map((s) {
      // Couleur selon type de cours
      final colors = {
        'CM':   const Color(0xFF1A3A6B),
        'TD':   const Color(0xFF2DAB6F),
        'TP':   const Color(0xFFF5A623),
        'EXAM': const Color(0xFFE05252),
      };
      return Appointment(
        startTime: s.startTime,
        endTime:   s.endTime,
        subject:   s.courseName,
        notes:     'Prof: ${s.teacher}\nSalle: ${s.room}',
        location:  s.room,
        color:     colors[s.courseType] ?? const Color(0xFF1A3A6B),
      );
    }).toList();
  }
}
