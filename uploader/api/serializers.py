from rest_framework import serializers

from api.models import FileUpload


class FileUploadSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = FileUpload
        read_only_fields = ('name', 'created', 'datafile', 'md5sum')
