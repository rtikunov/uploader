import os

from urllib.parse import urlparse
from django.test import TestCase
from django.core.urlresolvers import reverse
from rest_framework.test import APIClient, APITestCase
from rest_framework import status
from api.models import FileUpload
from uploader.settings import MEDIA_URL, MEDIA_ROOT


class FileUploadTests(APITestCase):

    def setUp(self):
        self.tearDown()

    def tearDown(self):
        FileUpload.objects.all().delete()

    def _create_test_file(self, path):
        f = open(path, 'w')
        f.write('test123\n')
        f.close()
        f = open(path, 'rb')
        return {'datafile': f}

    def test_upload_file(self):
        url = reverse('fileupload-list')
        filename = 'testfile'
        data = self._create_test_file('/tmp/' + filename)
        md5sum = '4a251a2ef9bbf4ccc35f97aba2c9cbda'

        # assert can upload file
        client = APIClient()
        response = client.post(url, data, format='multipart')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('created', response.data)
        self.assertTrue(urlparse(
            response.data['datafile']).path.startswith(MEDIA_URL))
        self.assertIn('created', response.data)
        self.assertEqual(FileUpload.objects.count(), 1)

        # assert if file has the same name and md5sum
        self.assertEqual(FileUpload.objects.get().name, filename)
        self.assertEqual(FileUpload.objects.get().md5sum, md5sum)

        # assert if file exists in storage
        self.assertTrue(os.path.isfile(MEDIA_ROOT + filename))

        # assert can get file's atributes
        url = '/api/{0}/'.format(filename)
        response = client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # assert can delete uploaded file
        response = client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(FileUpload.objects.count(), 0)
