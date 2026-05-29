from django.urls import path
from .views import get_notifications
from .views import create_notification
from .views import update_notification
from .views import delete_notification

urlpatterns = [

    path('', get_notifications),

    path('create/', create_notification),

    path('update/<int:pk>/', update_notification),

    path('delete/<int:pk>/', delete_notification),
]