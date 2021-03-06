{ config, lib, pkgs, home-manager, nix-profiles, ... }:

with lib;

let
  cfg = config.home-manager;

in {
  # import home manager
  imports = [
    home-manager.nixosModules.home-manager
  ];

  options = {
    home-manager.defaults = mkOption {
      description = "Home manager defaults applied to every user";
      type = types.listOf types.attrs;
      default = [];
    };

    home-manager.users = mkOption {
      type = types.attrsOf (types.submodule ({...}: {
        imports = cfg.defaults ++ [ nix-profiles.lib.home-manager.module ];
      }));
    };
  };

  config = {
    home-manager = {
      # installation of user packages through the users.users.<name>.packages
      useUserPackages = mkDefault true;

      specialArgs.nix-profiles = nix-profiles;

      defaults = [{
        config = {
          # passthru pkgs
          _module.args.pkgs = mkForce pkgs;
        };
      }];
    };
  };
}
