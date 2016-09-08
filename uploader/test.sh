#!/bin/bash

#set -x

date > /app/uploader/testfile

echo 'Upload file to storage'
curl -s -X POST \
  -F "datafile=@/app/uploader/testfile" \
  http://127.0.0.1/api/
echo -e "\n\n"

echo "Is file exists in storage"
echo "ls -l storage/"
ls -l storage/
echo -e "\n"

echo "Get list of uploaded files"
curl -s -X GET http://127.0.0.1/api/
echo -e "\n\n"

echo "Download the file"
curl -s http://127.0.0.1/storage/testfile
echo -e "\n"

echo "Delete file from storage"
curl -s -L -X DELETE http://127.0.0.1/api/testfile
echo -e "\n"

echo "Check if file deleted"
echo "ls -l storage/"
ls -l storage/
