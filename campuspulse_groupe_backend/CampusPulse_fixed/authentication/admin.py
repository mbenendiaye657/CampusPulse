from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Student

@admin.register(Student)
class StudentAdmin(UserAdmin):
    list_display  = ['username', 'email', 'first_name', 'last_name', 'level', 'department', 'is_active']
    list_filter   = ['level', 'department', 'is_active']
    search_fields = ['username', 'email', 'first_name', 'last_name', 'codeperm']
    fieldsets     = UserAdmin.fieldsets + (
        ('Informations universitaires', {'fields': ('codeperm', 'level', 'department', 'photo')}),
    )
