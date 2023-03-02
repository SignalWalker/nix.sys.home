{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = {
    services.tailscale = {
      tailnet.name = "tail3d611.ts.net";
    };
  };
  meta = {};
}
