from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import PassNumerique
from .serializers import PassNumeriqueSerializer

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import permission_classes


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_passes(request):

    passes = PassNumerique.objects.all()

    serializer = PassNumeriqueSerializer(
        passes,
        many=True
    )

    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_pass(request):

    serializer = PassNumeriqueSerializer(data=request.data)

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_pass(request, pk):

    pass_numerique = PassNumerique.objects.get(id=pk)

    serializer = PassNumeriqueSerializer(
        pass_numerique,
        data=request.data
    )

    if serializer.is_valid():

        serializer.save()

        return Response(serializer.data)

    return Response(serializer.errors)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_pass(request, pk):

    pass_numerique = PassNumerique.objects.get(id=pk)

    pass_numerique.delete()

    return Response('Deleted')