# [App provides api for upload, download and delete files][docs]


# Requirements

* Python (3.5)
* Django (1.8)

# Installation

Install using `docker` ...

    docker build .
    docker tag <img_id> uploader
    docker run -d --name uploader uploader
    docker exec -ti uploader /app/uploader/test.sh

You can also interact with the API using command line tools such as [`curl`](http://curl.haxx.se/). For example, to list the users endpoint:

    Upload file:
    $ curl -s -X POST -F "datafile=@/app/uploader/testfile" http://127.0.0.1:8000/api/

    Get list of files:
    $ curl -s -X GET http://127.0.0.1:8000/api/
    
    Download file:
    $ curl -s http://127.0.0.1:8000/storage/testfile

    Delete file:
    $ curl -s -L -X DELETE http://127.0.0.1:8000/api/testfile
