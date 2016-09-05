# App provides api for upload, download and delete files


# Requirements

* Python (3.5)
* Django (1.8)
* Django Rest Framework

# Installation

Install using `docker` ...

    Install Docker daemon ...
    for Ubuntu: sudo apt-get install docker.io
    for other distributions installation doc here: https://docs.docker.com/engine/installation/
    Ensure that docker daemon is started or start it: sudo service docker start

    Install app:
    git clone https://github.com/rtikunov/uploader.git
    cd uploader
    sudo docker build -t uploader .
    sudo docker run -d --name uploader uploader

# Test API:
    Using test script:
    sudo docker exec -ti uploader /app/uploader/test.sh

    Or by attaching to container and run tests manually:
    sudo docker exec -ti uploader /bin/bash
    /app/uploader/test.sh
    
You can also interact with the API using command line tools such as [`curl`](http://curl.haxx.se/). For example, to list the users endpoint:

    Upload file:
    $ curl -s -X POST -F "datafile=@/app/uploader/testfile" http://127.0.0.1/api/

    Get list of files:
    $ curl -s -X GET http://127.0.0.1/api/
    
    Download file:
    $ curl -s http://127.0.0.1/storage/testfile

    Delete file:
    $ curl -s -L -X DELETE http://127.0.0.1/api/testfile
