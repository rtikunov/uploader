import os
from django.shortcuts import render

from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.viewsets import ModelViewSet
from api.models import FileUpload
from api.serializers import FileUploadSerializer


class FileUploadViewSet(ModelViewSet):
    queryset = FileUpload.objects.all()
    serializer_class = FileUploadSerializer
    parser_classes = (MultiPartParser, FormParser,)

    def perform_create(self, serializer):
        serializer.save(datafile=self.request.data.get('datafile'),
                        name=self.request.data.get('datafile'))

    def perform_destroy(self, instance):
        os.remove(instance.datafile.path)
        instance.delete()
