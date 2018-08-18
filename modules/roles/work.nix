{ config, pkgs, lib, ... }:

with lib;

let
  proxsign = (import (builtins.fetchTarball {
    url = "https://github.com/domenkozar/proxsign-nix/archive/cc26bee496facdb61c2cbb2bcfef55e167d4a85b.tar.gz";
    sha256 = "0smhpz7hw382mlin79v681nws4pna5bdg0w8cjb4iq23frnb5dw6";
  }));
in {
  options.roles.work.enable = mkEnableOption "work role";

  config = mkIf config.roles.work.enable {
    # Chromium settings
    programs.chromium = {
      enable = mkDefault true;
      homepageLocation = mkDefault "https://encrypted.google.com";
      defaultSearchProviderSearchURL = mkDefault
        "https://encrypted.google.com/search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}{google:instantExtendedEnabledParameter}ie={inputEncoding}";
      defaultSearchProviderSuggestURL = mkDefault
        "https://encrypted.google.com/complete/search?output=chrome&q={searchTerms}";
      extensions = [
        "klbibkeccnjlkjkiokjodocebajanakg" # the great suspender
        "chlffgpmiacpedhhbkiomidkjlcfhogd" # pushbullet
        "mbniclmhobmnbdlbpiphghaielnnpgdp" # lightshot
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      ];
    };

    # enable tmux on work environments
    profiles.tmux.enable = mkDefault true;

    # dbus
    services.dbus.enable = true;
    services.udisks2.enable = true;

    # Polkit allow kexec
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.policykit.exec") &&
            subject.local && subject.active && subject.isInGroup("users")) {
                return polkit.Result.YES;
        }
      });
    '';

    # yubikey support
    services.udev.packages = with pkgs; [ libu2f-host  ];
    users.extraGroups.yubikey = {};
    services.udev.extraRules = ''
      ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0111", MODE="664", GROUP="yubikey"
    '';

    # default pulseaudio config
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };

    # Enable network manager
    networking.networkmanager = {
      enable = mkDefault true;
      insertNameservers = ["127.0.0.1"];
    };

    # enable dnsmasq
    services.dnsmasq.enable = mkDefault true;

    # gnome keyring is needed for saving some secrets
    services.gnome3.gnome-keyring.enable = true;

    # dbus packages
    services.dbus.packages = [ pkgs.gnome3.gconf ] ++ 
      optionals config.hardware.bluetooth.enable [pkgs.blueman];

    environment.systemPackages = with pkgs; [
      mupdf
      libreoffice
      feh
      gimp

      # browsers
      chromium

      # distro tools
      cdrkit
      unetbootin

      # cloud storage
      dropbox
      dropbox-cli

      # windows emulation
      wine
      winetricks
      dosbox

      # p2p stuff
      transmission_gtk

      # telephony
      skype

      # docs/images
      mupdf

      # audio/video
      vlc
      xvidcap
      ffmpeg
      nodePackages.peerflix
      youtube-dl

      # remote
      rdesktop
      gtkvnc

      # task managment
      taskwarrior
      pythonPackages.bugwarrior

      # journaling
      python27Packages.jrnl

      gnome3.dconf

      pavucontrol

      # crypto
      proxsign
    ];
  };
}
