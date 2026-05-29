from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Notification
from .serializers import NotificationSerializer

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import permission_classes


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_notifications(request):

    notifications = Notification.objects.all()

    serializer = NotificationSerializer(
        notifications,
        many=True
    )

    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_notification(request):

    serializer = NotificationSerializer(data=request.data)

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_notification(request, pk):

    notification = Notification.objects.get(id=pk)

    serializer = NotificationSerializer(
        notification,
        data=request.data
    )

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_notification(request, pk):

    notification = Notification.objects.get(id=pk)

    notification.delete()

    return Response('Deleted')