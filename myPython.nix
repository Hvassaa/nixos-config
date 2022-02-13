pkgs:
  with pkgs;
  let
    custom-python-packages = python-packages: with python-packages; [
      numpy
      matplotlib
      scipy
      pandas
      seaborn
      scikit-learn
      # jupyter_core
      # ipykernel
      # ipython      
    ];
    myPython = python3.withPackages custom-python-packages;
  in
    myPython
