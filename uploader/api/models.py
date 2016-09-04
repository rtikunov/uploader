# -*- coding: utf-8 -*-
from django.db import models


class FileUpload(models.Model):
    name = models.CharField(max_length=255, primary_key=True)
    created = models.DateTimeField(auto_now_add=True)
    datafile = models.FileField()
