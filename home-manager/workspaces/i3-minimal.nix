# creates a sensible i3 desktop setup

{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./base.nix

    ../profiles/xserver.nix
    ../profiles/i3.nix
    ../profiles/i3status.nix
    ../profiles/rofi.nix
    ../profiles/dunst.nix
    ../profiles/xterm.nix
  ];

  config = {
    services.random-background = {
      enable = mkDefault true;
      imageDirectory = mkDefault "%h/backgrounds";
    };

    xsession.windowManager.i3 = {
      defaultBarConfig.statusCommand =
        "${pkgs.python3Packages.py3status}/bin/py3status -c ~/.config/i3status/config";
    };
  };
}
