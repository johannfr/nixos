{
  config,
  pkgs,
  ...
}: let
  jofPackages = import ../jof-packages.nix {inherit pkgs;};
in {
  networking.hostName = "jof-t16"; # Define your hostname.

  # Wireguard
  networking.firewall = {
    allowedUDPPorts = [51820 10000];
    allowedTCPPorts = [8000];
  };

  environment.systemPackages = with pkgs; [
    reaper
    reaper-sws-extension
    reaper-reapack-extension
  ];

  system.activationScripts.reaperPlugins = {
    text = ''
      USER_PLUGINS="/home/trommur/.config/REAPER/UserPlugins"
      USER_SCRIPTS="/home/trommur/.config/REAPER/Scripts"
      mkdir -p "$USER_PLUGINS"
      mkdir -p "$USER_SCRIPTS"
      ln -sfn "${pkgs.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so" "$USER_PLUGINS/reaper_sws-x86_64.so"
      ln -sfn "${pkgs.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so" "$USER_PLUGINS/reaper_reapack-x86_64.so"
      if [ -f "${pkgs.reaper-sws-extension}/Scripts/sws_python.py" ]; then
        ln -sfn "${pkgs.reaper-sws-extension}/Scripts/sws_python.py" "$USER_SCRIPTS/sws_python.py"
      fi
      if [ -f "${pkgs.reaper-sws-extension}/Scripts/sws_python64.py" ]; then
        ln -sfn "${pkgs.reaper-sws-extension}/Scripts/sws_python64.py" "$USER_SCRIPTS/sws_python64.py"
      fi
      chown -R trommur:users "$USER_PLUGINS"
    '';
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = ["172.30.0.14/24"];
      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/private";
      peers = [
        {
          publicKey = "4wPxWrFDu2q+okeMiVGbkwZfI6gbCUCrq/8XRNq5Ngk=";
          allowedIPs = ["172.30.0.0/24" "172.31.0.0/24"];
          endpoint = "vpn.jof.guru:51820";
          persistentKeepalive = 5;
        }
      ];
    };
  };
  programs._1password-gui.polkitPolicyOwners = ["jof" "arna" "trommur"];

  users.users.jof = {
    isNormalUser = true;
    description = "Jóhann Friðriksson";
    extraGroups = ["networkmanager" "wheel" "dialout"];
    packages = jofPackages;
    shell = pkgs.zsh;
  };

  users.users.arna = {
    isNormalUser = true;
    description = "Arna Dögg Tómasdóttir";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      google-chrome
      caprine-bin
    ];
    shell = pkgs.zsh;
  };

  users.users.trommur = {
    isNormalUser = true;
    description = "Jóhann Friðriksson";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      ardour
      firefox
      alsa-scarlett-gui
      mixxx
      musescore
    ];
    shell = pkgs.zsh;
  };
  # environment.sessionVariables = rec {
  #   HYPRLAND_CONFIG = "$HOME/.config/hypr/jof-x1.conf";
  # };
}
