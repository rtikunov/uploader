#!/bin/bash

set -x

curl -s -X POST \
  -F "datafile=@/app/uploader/testfile" \
  http://127.0.0.1/api/
echo -e "\n"

ls -l storage/

curl -s -X GET http://127.0.0.1/api/
echo -e "\n"

curl -s -X GET http://127.0.0.1/api/testfile
echo -e "\n"

curl -s http://127.0.0.1/storage/testfile

curl -s -L -X DELETE http://127.0.0.1/api/testfile
echo -e "\n"
ls -l storage/
