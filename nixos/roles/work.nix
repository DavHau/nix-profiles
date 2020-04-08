# work role is used for systems that are used for work

{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./base.nix

    ../profiles/network-manager.nix
    ../profiles/pulseaudio.nix
    ../profiles/bluetooth.nix
    ../profiles/android.nix
    ../profiles/xserver.nix
    ../profiles/firmware.nix
    ../profiles/virtualbox-host.nix
  ];

  config = {
    # add yubikey udev packages and usb-modeswitch
    services.udev.packages = with pkgs; [ libu2f-host yubikey-personalization usb-modeswitch-data ];

    # add yubikey group, all uses in yubikey group can access yubikey devices
    users.extraGroups.yubikey = {};

    # For office work we need printing support
    services.printing = {
      enable = true;

      # enable hp printers, since it's what i'm usually dealing with
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # For office work we need scanners
    hardware.sane = {
      enable = true;

      # enable hp scanners, since this is what i'm usually dealing with
      extraBackends = [ pkgs.hplipWithPlugin ];
    };

    services.saned.enable = true;

    # enable pcscd daemon by default
    services.pcscd.enable = mkDefault true;

    # enable udisks2 dbus service on all work machines by default
    services.udisks2.enable = mkDefault true;

    # enable geoclue2 dbus service to get location information for apps like redshift
    services.geoclue2.enable = mkDefault true;

    # enable dconf support on all workstations for storage of configration
    programs.dconf.enable = mkDefault true;

    # add additional dbus packages
    services.dbus.packages = [ pkgs.gcr ];

    # hiberante on power key by default on all workstations
    services.logind.extraConfig = ''
      HandlePowerKey=hibernate
    '';

    # enable tun and fuse on work machines
    boot.kernelModules = [ "tun" "fuse" ];

    # install a set of fonts i use
    fonts = {
      fonts = with pkgs; [
        terminus_font
        opensans-ttf
        roboto
        roboto-mono
        roboto-slab
        noto-fonts
        noto-fonts-emoji
        hasklig
        material-design-icons
        material-icons
        source-code-pro
        source-sans-pro
      ];
      fontconfig = {
        enable = mkForce true;
        defaultFonts = {
          monospace = ["Roboto Mono 13"];
          sansSerif = ["Roboto 13"];
          serif = ["Roboto Slab 13"];
        };
      };
      enableDefaultFonts = true;
    };
  };
}
