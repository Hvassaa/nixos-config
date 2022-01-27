pkgs:
  with pkgs;
  let
    custom-python-packages = python-packages: with python-packages; [
    ];
    myPython = python3.withPackages custom-python-packages;
  in
    myPython
