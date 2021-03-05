# with (import <nixpkgs> {});
pkgs:
with pkgs;

stdenv.mkDerivation rec {
  name = "touchegg";
  pname = "${name}";
  version = "2.0.8.1";
  src = fetchurl {
    url = "https://github.com/Hvassaa/touchegg/archive/${version}.tar.gz";
    sha256 = "312a7eacf60e6aa25d900aa95593bcc7981142cebbe12919328f6e0f228702d1";
  };

  nativeBuildInputs = [ 
    gcc 
    pkg-config
    gdb
    cmake
    systemd
    libinput
    pugixml
    cairo
    xorg.libX11
    xorg.libXtst
    xorg.libXrandr
    xorg.libXi
    xorg.libXdmcp
    xorg.libpthreadstubs
    xorg.libxcb
    gtk3-x11
    pcre
    mount
  ];
 }
