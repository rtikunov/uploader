import os
import hashlib

from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.viewsets import ModelViewSet
from rest_framework.exceptions import ValidationError
from api.models import FileUpload
from api.serializers import FileUploadSerializer
from uploader.settings import MEDIA_ROOT


class FileUploadViewSet(ModelViewSet):
    queryset = FileUpload.objects.all()
    serializer_class = FileUploadSerializer
    parser_classes = (MultiPartParser, FormParser,)

    def perform_create(self, serializer):
        newfile = self.request.data['datafile']
        # check if file with same name exists
        num_results = FileUpload.objects.filter(name=newfile.name).count()
        if num_results == 0:
            # calculate md5sum for uploaded file
            md5 = hashlib.md5()
            filedata = newfile.read()
            newfile.seek(0, 0)
            md5.update(filedata)
            md5sum = md5.hexdigest()

            # check if storage has the same uploaded file
            md5check = FileUpload.objects.filter(md5sum=md5sum).count()

            # save file
            serializer.save(datafile=self.request.data.get('datafile'),
                            name=self.request.data.get('datafile'),
                            md5sum=md5sum)

            # if storage has the same uploaded file create hardlink
            # instead of save the whole file
            if md5check > 0:
                oldfile = FileUpload.objects.filter(md5sum=md5sum).exclude(name=newfile.name)[0]
                os.remove(MEDIA_ROOT + newfile.name)
                os.link(MEDIA_ROOT + oldfile.name, MEDIA_ROOT + newfile.name)
        else:
            raise ValidationError("not unique file name: {0}".format(newfile.name))

    def perform_destroy(self, instance):
        os.remove(instance.datafile.path)
        instance.delete()
