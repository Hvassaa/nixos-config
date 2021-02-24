pkgs: 
let
  offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec -a "$0" "$@"
    '';
  status = pkgs.writeShellScriptBin "nvidia-offload-status" ''
      state="$(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status)"
      echo "GPU state: $state"
      cat /proc/driver/nvidia/gpus/*/power
    '';
in
  { inherit offload status; }
