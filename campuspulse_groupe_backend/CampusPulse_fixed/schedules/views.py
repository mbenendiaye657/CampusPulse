from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from datetime import date

from .models import Schedule
from .serializers import ScheduleSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_schedules(request):
    """
    GET /api/schedules/?week_number=21
    Retourne les cours de l'étudiant connecté (filtré par level + department)
    """
    student     = request.user
    week_number = request.query_params.get('week_number')

    # Si pas de semaine précisée → semaine courante
    if not week_number:
        today = date.today()
        week_number = today.isocalendar()[1]

    schedules = Schedule.objects.filter(
        level=student.level,
        department=student.department,
        week_number=int(week_number),
    )

    serializer = ScheduleSerializer(schedules, many=True)

    return Response({
        'week_number': int(week_number),
        'student':     student.username,
        'level':       student.level,
        'department':  student.department,
        'courses':     serializer.data,
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_today(request):
    """GET /api/schedules/today/ — cours du jour"""
    days_map = {0:'Monday',1:'Tuesday',2:'Wednesday',3:'Thursday',4:'Friday',5:'Saturday',6:'Sunday'}
    today_name  = days_map[date.today().weekday()]
    week_number = date.today().isocalendar()[1]
    student     = request.user

    schedules = Schedule.objects.filter(
        level=student.level,
        department=student.department,
        day=today_name,
        week_number=week_number,
    )
    serializer = ScheduleSerializer(schedules, many=True)
    return Response({'courses': serializer.data, 'day': today_name})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_schedule(request):
    """POST /api/schedules/create/ — créer un cours (admin)"""
    serializer = ScheduleSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_schedule(request, pk):
    """PUT /api/schedules/update/<pk>/ — modifier (déclenche notif si salle change)"""
    try:
        schedule = Schedule.objects.get(pk=pk)
    except Schedule.DoesNotExist:
        return Response({'error': 'Cours introuvable'}, status=status.HTTP_404_NOT_FOUND)

    serializer = ScheduleSerializer(schedule, data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_schedule(request, pk):
    """DELETE /api/schedules/delete/<pk>/"""
    try:
        Schedule.objects.get(pk=pk).delete()
        return Response({'message': 'Cours supprimé'}, status=status.HTTP_204_NO_CONTENT)
    except Schedule.DoesNotExist:
        return Response({'error': 'Cours introuvable'}, status=status.HTTP_404_NOT_FOUND)
