{
  config,
  pkgs,
  ...
}: let
  jofPackages = import ../jof-packages.nix {inherit pkgs;};
in {
  networking.hostName = "johann-p1"; # Define your hostname.
  networking.extraHosts = ''
    192.168.199.33 isavia-tern
    192.168.1.26 isds-a
  '';

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "bip" = "172.27.0.1/16";
      "default-address-pools" = [
        {
          "base" = "172.27.0.0/16";
          "size" = 24;
        }
      ];
    };
  };

  # Create the writable paths for Cortex
  systemd.tmpfiles.rules = [
    "d /var/lib/cortex-agent/traps 0700 root root -"
    "d /var/lib/cortex-agent/etc 0755 root root -"
    "d /var/log/cortex-agent 0755 root root -"
  ];

  # Wireguard
  networking.firewall = {
    enable = true;
  };

  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  users.users.johann = {
    isNormalUser = true;
    description = "Johann Fridriksson";
    extraGroups = ["networkmanager" "wheel" "video" "render" "libvirtd" "docker" "input" "dialout"];
    shell = pkgs.zsh;
    packages = jofPackages;
  };

  users.users.testuser = {
    isNormalUser = true;
    description = "Test User";
    shell = pkgs.zsh;
  };

  # environment.sessionVariables = rec {
  #   HYPRLAND_CONFIG = "$HOME/.config/hypr/johann-p1.conf";
  # };

  programs._1password-gui.polkitPolicyOwners = ["johann"];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
