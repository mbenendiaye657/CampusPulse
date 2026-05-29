from rest_framework import serializers
from .models import Schedule

class ScheduleSerializer(serializers.ModelSerializer):

    # Champs calculés pour Flutter
    type_index = serializers.SerializerMethodField()
    start_time_full = serializers.SerializerMethodField()
    end_time_full   = serializers.SerializerMethodField()

    class Meta:
        model  = Schedule
        fields = [
            'id', 'level', 'department', 'course', 'teacher',
            'room', 'day', 'start_time', 'end_time',
            'start_time_full', 'end_time_full',
            'week_number', 'year', 'course_type', 'type_index',
        ]

    def get_type_index(self, obj):
        """Convertit le type en index pour Flutter (CM=0, TD=1, TP=2, EXAM=3)"""
        return {'CM': 0, 'TD': 1, 'TP': 2, 'EXAM': 3}.get(obj.course_type, 0)

    def get_start_time_full(self, obj):
        """Retourne une DateTime ISO complète (Flutter a besoin d'une date+heure)"""
        from datetime import date, datetime
        import calendar
        # Calcule la date réelle du jour dans la semaine
        day_map = {
            'Monday': 0, 'Tuesday': 1, 'Wednesday': 2,
            'Thursday': 3, 'Friday': 4, 'Saturday': 5,
        }
        today      = date.today()
        iso_year, week, _ = today.isocalendar()
        day_offset = day_map.get(obj.day, 0)
        # Premier jour de la semaine ISO demandée
        from datetime import timedelta
        jan4       = date(obj.year, 1, 4)
        week_start = jan4 - timedelta(days=jan4.weekday()) + timedelta(weeks=obj.week_number - 1)
        target_date = week_start + timedelta(days=day_offset)
        dt = datetime.combine(target_date, obj.start_time)
        return dt.isoformat()

    def get_end_time_full(self, obj):
        from datetime import date, datetime, timedelta
        day_map = {'Monday': 0, 'Tuesday': 1, 'Wednesday': 2,
                   'Thursday': 3, 'Friday': 4, 'Saturday': 5}
        day_offset = day_map.get(obj.day, 0)
        jan4       = date(obj.year, 1, 4)
        week_start = jan4 - timedelta(days=jan4.weekday()) + timedelta(weeks=obj.week_number - 1)
        target_date = week_start + timedelta(days=day_offset)
        dt = datetime.combine(target_date, obj.end_time)
        return dt.isoformat()
