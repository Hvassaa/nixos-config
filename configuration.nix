# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

# script to offload to nvidia card
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # enable non-free software
  nixpkgs.config.allowUnfree = true;

  # Configure keymap in X11
  services.xserver.layout = "dk";
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.blacklistedKernelModules =  [ "nouveau" ];  

  # hostname
  networking.hostName = "nixps"; # Define your hostname.
  
  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

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
    font = ""; #"Lat2-Terminus16";
    keyMap = "dk";
  };

  # Enable the GNOME 3 Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.libinput.middleEmulation = false;

  boot.initrd.kernelModules = [ "intel_agp" "i915" ];
  hardware = {
    bluetooth.enable = false;
    # cpu stuff    
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    opengl.extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  # enable nvidia
  # https://github.com/NixOS/nixpkgs/issues/90152
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    nvidiaPersistenced = true;
    prime = {
      offload.enable = true;
      # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
      intelBusId = "PCI:0:2:0";
      # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
      nvidiaBusId = "PCI:1:0:0";
    };
    #powerManagement.enable = true;
  };

boot.extraModprobeConfig = "options nvidia \"NVreg_DynamicPowerManagement=0x02\"\n";
  services.udev.extraRules = ''
  # Remove NVIDIA USB xHCI Host Controller devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"
  
  # Remove NVIDIA USB Type-C UCSI devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"
  
  # Remove NVIDIA Audio devices, if present
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
  
  # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
  ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
  ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
  
  # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
  ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
  ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';  

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rasmus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ]; 
  };

  environment = {
    variables = {
      VISUAL = "nvim";
      EDITOR = "nvim";
    };
    etc."inputrc".text = ''
      set editing-mode vi
      set show-mode-in-prompt on
      $if term=linux
      set vi-ins-mode-string \1\e[?0c\2
      set vi-cmd-mode-string \1\e[?8c\2
      $else
      set vi-ins-mode-string \1\e[6 q\2
      set vi-cmd-mode-string \1\e[2 q\2
      $endif
      
      set keymap vi-command
      Control-l: clear-screen
      set keymap vi-insert
      Control-l: clear-screen
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # basics and utils
    neovim
    nodejs
    git
    firefox-bin

    # utils
    wget
    curl
    powertop
    ntfs3g
    
    # productive stuff
    texlive.combined.scheme-full
    zoom-us

    # gaming stuff
    discord
    gzdoom

    # nvida, graphic utils
    nvidia-offload
    pciutils
    glxinfo
    mesa-demos
  ];

  # enable steam
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  # List services that you want to enable:
  services = {
    printing.enable = true;
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        RUNTIME_PM_DRIVER_BLACKLIST = "nouveau mei_me";
      };
    };
    fstrim.enable = true;
  };
  
  system.stateVersion = "20.09";
}

