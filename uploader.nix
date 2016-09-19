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
  ( with import <nixpkgs> {};
    let dependencies = rec {
        _djangorestframework = pkgs.python35Packages.djangorestframework.override rec {
            name = "djangorestframework-3.3.2";
            src = fetchurl {
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
    };

    in with dependencies;
    stdenv.mkDerivation rec {
        name = "env";

        env = buildEnv { name = name; paths = buildInputs; };
        builder = builtins.toFile "builder.sh" ''
            source $stdenv/setup; ln -s $env $out
        '';

        buildInputs = [
            (python35.buildEnv.override {
                ignoreCollisions = true;
                extraLibs = with python35Packages; [ _djangorestframework ];
            })
        ];
    }
  )
];

systemd.services.uploader = {
   after = [ "network.target" ];
   serviceConfig = {
       WorkingDirectory = "/app/uploader";
       PIDFile = "/tmp/uploader.pid";
       Type = "forking";
       User = "uploader";
       KillMode = "process";
       ExecStartPre = [
           '' ${config.system.path}/bin/chown -R uploader /app/uploader ''
           '' ${config.system.path}/bin/python3 /app/uploader/manage.py migrate --noinput ''
           '' ${config.system.path}/bin/python3 /app/uploader/manage.py collectstatic --noinput ''
           '' ${config.system.path}/bin/python3 /app/uploader/manage.py test --noinput ''
       ];
       ExecStart = '' ${config.system.path}/bin/gunicorn  --workers 1 --bind=127.0.0.1:8000 --pid=/tmp/uploader.pid --pythonpath=/app/uploader --error-logfile=/home/uploader/uploader.error.log --daemon uploader.wsgi:application '';
   };
};
systemd.services.uploader.enable = true;
}
