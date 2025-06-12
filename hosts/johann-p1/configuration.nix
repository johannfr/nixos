{ config, pkgs, ... }:
let
  jofPackages = import ../jof-packages.nix { inherit pkgs; };
in
{
  networking.hostName = "johann-p1"; # Define your hostname.
  networking.extraHosts =
  ''
  192.168.199.33 isavia-tern
  192.168.1.26 isds-a
  '';

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      "bip" = "172.27.0.1/16";
      "default-address-pools" = [
      { "base" = "172.27.0.0/16"; "size" = 24; }
      ];
    };
  };

  # Wireguard
  networking.firewall = {
    allowedUDPPorts = [ 51820 10000 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "172.30.0.13/24" ];
      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/private";
      peers = [
        {
          publicKey = "4wPxWrFDu2q+okeMiVGbkwZfI6gbCUCrq/8XRNq5Ngk=";
	        allowedIPs = [ "172.30.0.0/24" "172.31.0.0/24" ];
	        endpoint = "vpn.jof.guru:51820";
	        persistentKeepalive = 5;
	      }
      ];
    };
  };

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  users.users.johann = {
    isNormalUser = true;
    description = "Johann Fridriksson";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "libvirtd" "docker" "input" "dialout" ];
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

  programs._1password-gui.polkitPolicyOwners = [ "johann" ];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;



}

