from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Grade
from .serializers import GradeSerializer

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import permission_classes


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_grades(request):

    grades = Grade.objects.all()

    serializer = GradeSerializer(
        grades,
        many=True
    )

    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_grade(request):

    serializer = GradeSerializer(data=request.data)

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_grade(request, pk):

    grade = Grade.objects.get(id=pk)

    serializer = GradeSerializer(
        grade,
        data=request.data
    )

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_grade(request, pk):

    grade = Grade.objects.get(id=pk)

    grade.delete()

    return Response('Deleted')