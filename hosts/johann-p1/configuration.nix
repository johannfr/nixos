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

  users.users.johann = {
    isNormalUser = true;
    description = "Johann Fridriksson";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "libvirtd" "docker" "input" ];
    shell = pkgs.zsh;
    packages = jofPackages;
  };

  programs._1password-gui.polkitPolicyOwners = [ "johann" ];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;



}

