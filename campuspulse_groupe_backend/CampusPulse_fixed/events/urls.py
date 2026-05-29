from django.urls import path
from .views import get_events
from .views import create_event
from .views import update_event
from .views import delete_event
urlpatterns = [

    path('', get_events),

    path('create/', create_event),

    path('update/<int:pk>/', update_event),

    path('delete/<int:pk>/', delete_event),
]