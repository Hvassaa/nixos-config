{ config, pkgs, ... }:

let 
  nvstat = pkgs.writeShellScriptBin "nvstat" ''
      state="$(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status)"
      echo "GPU state: $state"
      cat /proc/driver/nvidia/gpus/*/power
    '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "dk";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  users.users.rasmus = {
    isNormalUser = true;
    description = "Rasmus Tomtava Bjerg";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      neovim
      discord

      nvstat

      ntfs3g
    ];
  };
  
  programs = {
    git.enable = true;
    steam.enable = true;
  };

  environment.etc."inputrc".text = ''
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

  environment.systemPackages = with pkgs; [];

  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;	
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.nvidia = {
    prime = {
      offload = {
        enable = true;
	enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    nvidiaPersistenced = true;
    # modesetting.enable = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;        
  };

  system.stateVersion = "23.05"; # Did you read the comment?

}
