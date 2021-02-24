pkgs:
  with pkgs;
  let
    custom-python-packages = python-packages: with python-packages; [
      scipy
      numpy
    ];
    python-package = python3.withPackages custom-python-packages;
  in
    python-package

