FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
		curl \
		python3-django \
		python3-djangorestframework \
		nginx && \
	rm -rf /var/lib/apt/lists/* && mkdir /app

COPY nginx/default /etc/nginx/sites-available/default
COPY . /app/
RUN useradd -c 'Django user' -m -s /bin/bash django && \
    mkdir -p /var/log/django && \
    chown -R django:django /var/log/django && \
    chown -R django:django /app/uploader

WORKDIR /app/uploader

CMD service nginx start && su - django -c /app/uploader/run.sh
