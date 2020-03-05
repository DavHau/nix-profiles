{ config, pkgs, lib, ... }:

let
  nix-profiles = import <nix-profiles> { inherit pkgs lib; };

in {
  imports = with nix-profiles.modules.nixos; [
    hw.hyperv-vm

    # import base environment
    environments.base

    # create user
    profiles.user
  ];

  home-manager.users.user = { config, ... }: {
    imports = with nix-profiles.modules.home-manager; [
      # workspace.i3
      # themes.materia
      # themes.colorscheme.google-dark

      # roles.desktop.dev
    ];
  };

  # attributes = {
  #   recoverySSHKey = "<my-ssh-key>";
  #   recoveryPasswordHash = "<my-password-hash>";
  # };

  nix.nixPathAttrs.nix-profiles = "https://github.com/xtruder/nix-profiles/archive/nix-profiles-2-0.tar.gz";
}
