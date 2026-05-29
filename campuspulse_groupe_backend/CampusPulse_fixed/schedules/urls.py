from django.urls import path
from .views import get_schedules, get_today, create_schedule, update_schedule, delete_schedule

urlpatterns = [
    path('',              get_schedules),    # GET  /api/schedules/?week_number=21
    path('today/',        get_today),        # GET  /api/schedules/today/
    path('create/',       create_schedule),  # POST /api/schedules/create/
    path('update/<int:pk>/', update_schedule),  # PUT
    path('delete/<int:pk>/', delete_schedule),  # DELETE
]
