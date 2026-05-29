from django.urls import path
from .views import get_grades
from .views import create_grade
from .views import update_grade
from .views import delete_grade

urlpatterns = [

    path('', get_grades),

    path('create/', create_grade),

    path('update/<int:pk>/', update_grade),

    path('delete/<int:pk>/', delete_grade),
]