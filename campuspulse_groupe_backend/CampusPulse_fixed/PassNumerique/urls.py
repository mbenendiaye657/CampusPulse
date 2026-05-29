from django.urls import path
from .views import get_passes
from .views import create_pass
from .views import update_pass
from .views import delete_pass

urlpatterns = [

    path('', get_passes),

    path('create/', create_pass),

    path('update/<int:pk>/', update_pass),

    path('delete/<int:pk>/', delete_pass),
]