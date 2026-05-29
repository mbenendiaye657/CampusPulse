from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .serializers import RegisterSerializer, StudentSerializer


@api_view(['POST'])
@permission_classes([AllowAny])
def register_student(request):
    """
    POST /api/auth/register/
    Crée un nouveau compte étudiant
    """
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        student = serializer.save()
        return Response(
            StudentSerializer(student).data,
            status=status.HTTP_201_CREATED
        )
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    """
    GET /api/auth/me/
    Retourne le profil de l'étudiant connecté
    """
    serializer = StudentSerializer(request.user)
    return Response(serializer.data)
