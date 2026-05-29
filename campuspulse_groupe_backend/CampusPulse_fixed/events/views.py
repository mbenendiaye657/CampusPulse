from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Event
from .serializers import EventSerializer

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import permission_classes


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_events(request):

    events = Event.objects.all()

    serializer = EventSerializer(
        events,
        many=True
    )

    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_event(request):

    serializer = EventSerializer(data=request.data)

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_event(request, pk):

    event = Event.objects.get(id=pk)

    serializer = EventSerializer(
        event,
        data=request.data
    )

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_event(request, pk):

    event = Event.objects.get(id=pk)

    event.delete()

    return Response('Deleted')