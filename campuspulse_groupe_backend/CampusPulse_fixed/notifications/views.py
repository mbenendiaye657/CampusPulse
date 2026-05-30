from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Notification
from .serializers import NotificationSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_notifications(request):
    notifications = Notification.objects.filter(
        student__isnull=True
    ) | Notification.objects.filter(student=request.user)

    # Toujours retourner toutes les notifs (lues et non lues) classées par date
    notifications = notifications.order_by('-created_at')
    serializer = NotificationSerializer(notifications, many=True)

    return Response({
        'notifications': serializer.data,
        'unread_count':  notifications.filter(is_read=False).count(),
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_notification(request):
    serializer = NotificationSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)

@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_notification(request, pk):
    try:
        notification = Notification.objects.get(id=pk)
        serializer = NotificationSerializer(notification, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)
    except Notification.DoesNotExist:
        return Response({'error': 'Not found'}, status=404)

@api_view(['POST']) # Reçoit le clic de Flutter
@permission_classes([IsAuthenticated])
def mark_as_read(request, pk):
    try:
        notification = Notification.objects.get(id=pk)
        notification.is_read = True
        notification.save()
        return Response({'message': 'Marquée comme lue'}, status=200)
    except Notification.DoesNotExist:
        return Response({'error': 'Notification non trouvée'}, status=404)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_notification(request, pk):
    try:
        notification = Notification.objects.get(id=pk)
        notification.delete()
        return Response('Deleted', status=204)
    except Notification.DoesNotExist:
        return Response({'error': 'Not found'}, status=404)