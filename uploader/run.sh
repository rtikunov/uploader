#!/usr/bin/env bash

cd /app/uploader/
./manage.py migrate --noinput
./manage.py collectstatic --noinput
./manage.py test --noinput
./manage.py runserver 127.0.0.1:8000
