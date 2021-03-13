# with (import <nixpkgs> {});
# pkgs:
# with pkgs;
{ pkgs, stdenv, fetchFromGitHub, systemd, libinput, pugixml, cairo, xorg, gtk3-x11, pcre, pkg-config, cmake }:

stdenv.mkDerivation rec {
  name = "touchegg";
  pname = "${name}";
  version = "2.0.8.1";
  src = fetchFromGitHub {
    owner = "JoseExposito";
    repo = "${name}";
    rev = "f6c64bbd6d00564a980bf4379dcc1178de294c85";
    sha256 = "1v1sskyxmvbc6j4l31zbabiklfmy2pm77bn0z0baj1dl3wy7xcj2";
  };

  PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";

  buildInputs = with pkgs; [
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
  ];

  nativeBuildInputs = [ pkg-config cmake ];
 }
