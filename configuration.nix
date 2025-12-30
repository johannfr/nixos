{
  config,
  pkgs,
  ...
}: let
  myNixVim = builtins.getFlake "github:johannfr/nixvim";
  vim-alias = pkgs.runCommand "vim-alias" {} ''
    mkdir -p $out/bin
    ln -s ${myNixVim.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/nvim $out/bin/vim
  '';
in {
  imports = [
    # Include the results of the hardware scan.
    ./current_host/hardware-configuration.nix
    ./current_host/configuration.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "intremap=on"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    plymouth.enable = true;
    plymouth.font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
    plymouth.logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
  };

  networking.networkmanager.enable = true;

  services.udev.extraRules = ''
    # Ultimate Hacking Keyboard rules
    # These are the udev rules for accessing the USB interfaces of the UHK as non-root users.
    # Copy this file to /etc/udev/rules.d and physically reconnect the UHK afterwards.
    SUBSYSTEM=="input", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", GROUP="input", MODE="0660"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", TAG+="uaccess", GROUP="input", MODE="0660"

    SUBSYSTEM=="input", ATTRS{idVendor}=="37a8", ATTRS{idProduct}=="*", GROUP="input", MODE="0660"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="37a8", ATTRS{idProduct}=="*", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="37a8", ATTRS{idProduct}=="*", TAG+="uaccess", GROUP="input", MODE="0660"
  '';
  # Set your time zone.
  time.timeZone = "Atlantic/Reykjavik";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "is_IS.UTF-8";
    LC_IDENTIFICATION = "is_IS.UTF-8";
    LC_MEASUREMENT = "is_IS.UTF-8";
    LC_MONETARY = "is_IS.UTF-8";
    LC_NAME = "is_IS.UTF-8";
    LC_NUMERIC = "is_IS.UTF-8";
    LC_PAPER = "is_IS.UTF-8";
    LC_TELEPHONE = "is_IS.UTF-8";
    LC_TIME = "is_IS.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    cups-bjnp
    carps-cups
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix.settings.trusted-users = ["root" "@wheel"];

  programs._1password = {
    enable = true;
  };

  programs._1password-gui = {
    enable = true;
  };

  # programs.neovim = {
  #   enable = true;
  #   defaultEditor = true;
  # };

  programs.firefox = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
  };

  environment.sessionVariables = rec {
    HYPRLAND_CONFIG = "$HOME/.config/hypr/${config.networking.hostName}.conf";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    shellAliases = {
      cat = "bat";
    };
    shellInit = ''
      # Reverse search global - arrow keys local
      up-line-or-local-history() {
          zle set-local-history 1
          zle up-line-or-history
          zle set-local-history 0
      }
      zle -N up-line-or-local-history
      down-line-or-local-history() {
          zle set-local-history 1
          zle down-line-or-history
          zle set-local-history 0
      }
      zle -N down-line-or-local-history
      bindkey "$\{terminfo[kcuu1]}" up-line-or-local-history
      bindkey "$\{terminfo[kcud1]}" down-line-or-local-history
      export MCFLY_KEY_SCHEME=vim
      eval "$(mcfly init zsh)"
    '';
    ohMyZsh = {
      enable = true;
      # theme = "robbyrussell";
      preLoaded = ''
        zstyle ':omz:*' aliases no
      '';
      plugins = [
        "sudo"
        "pip"
        "git"
        "git-lfs"
        "git-flow"
      ];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      corefonts
      ubuntu-classic
      powerline-fonts
      font-awesome
      source-code-pro
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      kanji-stroke-order-font
      ipafont
      fira-code
      fira-code-symbols
      jetbrains-mono

      liberation_ttf
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [
          "JetBrains Mono"
          "Fira Code"
          "Fira Mono for Powerline"
          "DejaVu Sans Mono"
          "Noto Mono"
          "Noto Color Emoji"
        ];
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    wget
    curl
    bluetuith
    mcfly
    inetutils
    bat
    silver-searcher
    file
    unzip
    psmisc
    git
    git-lfs
    polkit
    hyprpolkitagent
    nwg-bar
    myNixVim.packages.${pkgs.stdenv.hostPlatform.system}.default
    vim-alias
    deja-dup
  ];

  # Let's do fingerprints.
  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  security.polkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      X11UseLocalhost = true;
    };
  };

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
