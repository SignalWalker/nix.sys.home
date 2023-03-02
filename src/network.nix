{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  ts = config.services.tailscale;
in {
  options = with lib; {
    signal.network = {
      machines = mkOption {
        type = types.attrsOf (types.submoduleWith {
          modules = [
            ({
              config,
              lib,
              name,
              ...
            }: {
              options = {
                name = mkOption {
                  type = types.str;
                  default = name;
                };
                hostName = mkOption {
                  type = types.str;
                  default = config.name;
                };
                domain = mkOption {
                  type = types.str;
                  default = "local";
                };
                fqdn = mkOption {
                  type = types.str;
                  readOnly = true;
                  default = "${config.hostName}.${config.domain}";
                };
                system = mkOption {
                  type = types.str;
                };
                hostId = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                buildMachine = {
                  enable = mkEnableOption "use as nix build machine";
                  supportedFeatures = mkOption {
                    type = types.listOf types.str;
                    default = [];
                  };
                  systems = mkOption {
                    type = types.listOf types.str;
                    default = [config.system];
                  };
                };
                substituter = {
                  enable = mkEnableOption "use as nix substitution source";
                  protocol = mkOption {
                    type = types.str;
                    default = "ssh";
                  };
                  publicKey = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                };
                ssh = {
                  publicHostKey = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                };
              };
            })
          ];
        });
      };
    };
  };
  disabledModules = [];
  imports = lib.signal.fs.path.listFilePaths ./network;
  config = {
    signal.network.machines = {
      "ash-desktop" = {
        domain = "local";
        system = "x86_64-linux";
        buildMachine = {
          enable = true;
        };
        substituter = {
          enable = true;
          publicKey = "ash-desktop.local-1:vYnEbQgaSKfyp5YBEsWMvj0W3ZhvNWotYzH4HauHp8g=";
        };
      };
      "ash-laptop" = {
        domain = "local";
        system = "x86_64-linux";
        substituter = {
          enable = true;
          publicKey = "ash-laptop.local-1:K4jdUDsBjMS8EgyK793FHZz6cbCThkq24SiOUSRzKBk=";
        };
        ssh = {
          publicHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9HIoUKrBYO+qjyYQlybFUTVQv8VvfyMnHUKu6+qKmM";
        };
      };
      "anarres" = {
        domain = "local";
        system = "x86_64-linux";
        substituter = {
          enable = true;
        };
        ssh = {
        };
      };
      "ashwalker" = {
        domain = ts.tailnet.name;
        system = "x86_64-linux";
        substituter = {
          enable = true;
        };
        ssh = {
          publicHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0v+D2d69PTrv/Sg5UWLqCQ5VEggFu1oMSiZYNQQdCM";
        };
      };
    };
  };
  meta = {};
}
