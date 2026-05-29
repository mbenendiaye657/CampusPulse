from rest_framework import serializers
from .models import PassNumerique


class PassNumeriqueSerializer(serializers.ModelSerializer):

    class Meta:
        model = PassNumerique
        fields = '__all__'