from rest_framework import serializers
from .models import Student

class RegisterSerializer(serializers.ModelSerializer):
    """Serializer pour l'inscription — inclut le mot de passe"""
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model  = Student
        fields = ['username', 'email', 'first_name', 'last_name',
                  'password', 'codeperm', 'level', 'department']

    def create(self, validated_data):
        # create_user hash automatiquement le mot de passe
        return Student.objects.create_user(**validated_data)


class StudentSerializer(serializers.ModelSerializer):
    """Serializer public — sans mot de passe"""
    class Meta:
        model  = Student
        fields = ['id', 'username', 'email', 'first_name', 'last_name',
                  'codeperm', 'level', 'department', 'photo']
