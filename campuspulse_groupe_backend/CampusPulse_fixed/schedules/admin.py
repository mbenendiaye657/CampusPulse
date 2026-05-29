from django.contrib import admin
from .models import Schedule

@admin.register(Schedule)
class ScheduleAdmin(admin.ModelAdmin):
    list_display  = ['course', 'teacher', 'room', 'day', 'start_time', 'end_time', 'level', 'department', 'week_number']
    list_filter   = ['level', 'department', 'day', 'week_number', 'course_type']
    search_fields = ['course', 'teacher', 'room']
    ordering      = ['week_number', 'day', 'start_time']
