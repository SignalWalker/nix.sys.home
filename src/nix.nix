{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
  network = config.signal.network;
  foldMachines = init: fn:
    foldl' (acc: key: let
      mcn = network.machines.${key};
    in
      if mcn.name == config.networking.hostName # skip if self
      then acc
      else fn acc key network.machines.${key})
    init (attrNames network.machines);
in {
  options = with lib; {};
  disabledModules = [];
  imports = [];
  config = lib.mkMerge [
    {
      nix = {
        settings = {
          substituters = foldMachines [] (acc: key: mcn:
            if mcn.substituter.enable
            then
              acc
              ++ [
                "${mcn.substituter.protocol}://${mcn.fqdn}"
              ]
            else acc);
          trusted-public-keys = foldMachines [] (acc: key: mcn:
            if mcn.substituter.enable && (mcn.substituter.publicKey != null)
            then acc ++ [mcn.substituter.publicKey]
            else acc);
        };
        distributedBuilds = true;
        buildMachines = foldMachines {} (acc: key: mcn:
          if mcn.buildMachine.enable
          then
            acc
            // {
              ${mcn.fqdn} = {
                hostName = mcn.fqdn;
                protocol = "ssh-ng";
                publicHostKey = mcn.ssh.publicHostKey;
                supportedFeatures = mcn.buildMachine.supportedFeatures;
                inherit (mcn.buildMachine) systems;
              };
            }
          else acc);
      };
    }
    (lib.mkIf config.nix.sshServe.write {
      nix.settings.trusted-users = ["nix-ssh"];
    })
  ];
  meta = {};
}
