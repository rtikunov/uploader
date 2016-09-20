{ config, pkgs, ... }: 
{
users.extraUsers.uploader = {
    isNormalUser = true;
    home = "/home/uploader";
    description = "App uploader user";
};

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

environment.systemPackages = [
  ( let _djangorestframework = pkgs.python35Packages.buildPythonPackage rec {
        name = "djangorestframework-${version}";
        version = "3.3.2";
        src = pkgs.fetchurl {
            url = "https://pypi.python.org/packages/source/d/djangorestframework/${name}.tar.gz";
            md5 = "f45b14a65e95b85216018bd009341683";
        };

        propagatedBuildInputs = [
            pkgs.python35
            pkgs.python35Packages.django_1_8
            pkgs.python35Packages.gunicorn
        ];
        doCheck = false;
    };

    in pkgs.python35.buildEnv.override rec {
        extraLibs = [ _djangorestframework ];
    }
  )
];

systemd.services.uploader = {
   after = [ "network.target" ];
   serviceConfig = {
       WorkingDirectory = "/app/uploader";
       PIDFile = "/tmp/uploader.pid";
       Type = "forking";
       KillMode = "process";
       ExecStartPre = [
           '' ${config.system.path}/bin/python3 /app/uploader/manage.py migrate --noinput ''
           '' ${config.system.path}/bin/python3 /app/uploader/manage.py collectstatic --noinput ''
           '' ${config.system.path}/bin/python3 /app/uploader/manage.py test --noinput ''
           '' ${config.system.path}/bin/chown -R uploader /app/uploader ''
       ];
       ExecStart = '' ${config.system.path}/bin/gunicorn --user uploader --workers 1 --bind=127.0.0.1:8000 --pid=/tmp/uploader.pid --pythonpath=/app/uploader --error-logfile=/home/uploader/uploader.error.log --daemon uploader.wsgi:application '';
   };
};
systemd.services.uploader.enable = true;
}
