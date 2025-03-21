{ config, pkgs, ... }:

let
  unstable = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
  { config = config.nixpkgs.config; };
in
{
  networking.hostName = "jof-x1"; # Define your hostname.

  programs._1password-gui.polkitPolicyOwners = [ "jof" "arna" ];
}

