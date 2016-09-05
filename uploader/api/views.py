import os
from django.shortcuts import render

from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.viewsets import ModelViewSet
from rest_framework.exceptions import ValidationError
from api.models import FileUpload
from api.serializers import FileUploadSerializer


class FileUploadViewSet(ModelViewSet):
    queryset = FileUpload.objects.all()
    serializer_class = FileUploadSerializer
    parser_classes = (MultiPartParser, FormParser,)

    def perform_create(self, serializer):
        num_results = FileUpload.objects.filter(name=self.request.data.get('datafile')).count()
        if num_results == 0:
            serializer.save(datafile=self.request.data.get('datafile'),
                            name=self.request.data.get('datafile'))
        else:
            raise ValidationError("not unique file name: {0}".format(self.request.data.get('datafile')))

    def perform_destroy(self, instance):
        os.remove(instance.datafile.path)
        instance.delete()
