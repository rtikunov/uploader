with import <nixpkgs> {};

let dependencies = rec {
  _djangorestframework = with python35Packages; djangorestframework.override rec {
    name = "djangorestframework-3.3.2";
    src = fetchurl {
      url = "https://pypi.python.org/packages/source/d/djangorestframework/${name}.tar.gz";
      md5 = "f45b14a65e95b85216018bd009341683";
    };

    propagatedBuildInputs = [ python35 django_1_8 ];
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
      extraLibs = with python35Packages; [
        _djangorestframework
      ];
    })
  ];
  shellHook = ''
    cd /app/uploader/
  '';
}
