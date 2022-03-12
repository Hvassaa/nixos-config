# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  nvidia-offload = import ./nvidia-offload.nix pkgs;
  myPython = import ./myPython.nix pkgs;
in
{

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  # enable non-free software
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules =  [ "nouveau" ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.initrd.kernelModules = [ "intel_agp" "i915" ];
  hardware = {
    bluetooth.enable = false;
    # cpu stuff    
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };
  };
  # enable nvidia
  # https://github.com/NixOS/nixpkgs/issues/90152
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    nvidiaPersistenced = true;
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
      intelBusId = "PCI:0:2:0";
      # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement.enable = true;
    powerManagement.finegrained = true;    
  };


  networking.hostName = "LaBelle"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.enp0s20f0u2u4.useDHCP = true;
  # networking.interfaces.wlp59s0.useDHCP = true;
  # dont know whats wrong, but this fixes resolving dns for github
  # https://github.com/NixOS/nixpkgs/issues/87221
  # https://github.com/NixOS/nixpkgs/issues/63754
  networking.resolvconf.dnsExtensionMechanism = false;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "da_DK.UTF-8/UTF-8" ];
  };
  console = {
    font = ""; # "2-Terminus16";
    keyMap = "dk";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;
  
  # Configure keymap in X11
  services.xserver.layout = "dk";
  #services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;
  

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rasmus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    myEmacs
    nodejs
    nodePackages.pyright
    rnix-lsp
    rust-analyzer
    rustfmt
    gcc
    go
    gopls

    cachix

    myPython
    cargo
    rustc

    wget
    firefox
    discord
    zoom-us
    (texlive.combine {
      inherit (texlive) scheme-full beamer listings;
    })

    # nvida, graphic utils
    (nvidia-offload.offload)
    (nvidia-offload.status)
  ];

  services = {
    #emacs.defaultEditor = true;
    printing.enable = true;
    thermald.enable = true;
    fstrim.enable = true;
    flatpak.enable = true;
  };
  programs = {
    git.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim-nightly;
      configure = {
        customRC = (builtins.readFile ./init.vim);
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

