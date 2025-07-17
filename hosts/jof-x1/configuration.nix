{ config, pkgs, ... }:

let
  jofPackages = import ../jof-packages.nix { inherit pkgs; };
in
{
  networking.hostName = "jof-x1"; # Define your hostname.

  # Wireguard
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "172.30.0.11/24" ];
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
  programs._1password-gui.polkitPolicyOwners = [ "jof" "arna" "trommur" ];

  users.users.jof = {
    isNormalUser = true;
    description = "Jóhann Friðriksson";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "libvirtd" "docker" "input" "dialout" ];
    packages = jofPackages;
    shell = pkgs.zsh;
  };

  users.users.arna = {
    isNormalUser = true;
    description = "Arna Dögg Tómasdóttir";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "libvirtd" "docker" "input" "dialout" ];
    packages = with pkgs; [
      google-chrome
      caprine-bin
    ];
    shell = pkgs.zsh;
  };

  users.users.trommur = {
    isNormalUser = true;
    description = "Jóhann Friðriksson";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "libvirtd" "docker" "input" "dialout" ];
    packages = with pkgs; [
      reaper
      ardour
      firefox
      alsa-scarlett-gui
      mixxx
      yabridge
      yabridgectl
    ];
    shell = pkgs.zsh;
  };

  # environment.sessionVariables = rec {
  #   HYPRLAND_CONFIG = "$HOME/.config/hypr/jof-x1.conf";
  # };

}

