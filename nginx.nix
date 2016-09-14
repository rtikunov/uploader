{ config, pkgs, ... }: 
{
services.nginx.enable = true;
services.nginx.httpConfig = ''
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location /storage/ { root /app/uploader; }

        location /api/ {
                proxy_pass http://127.0.0.1:8000;
        }

        location / {
                try_files $uri $uri/ =404;
        }
    }
'';
}
