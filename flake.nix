{
  description = "Nix configuration - personal computers";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sysbase = {
      url = "github:signalwalker/nix.sys.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homebase.follows = "homebase";
      inputs.homelib.follows = "homelib";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homelib = {
      url = "github:signalwalker/nix.home.lib";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.home-manager.follows = "home-manager";
    };
    homebase = {
      url = "github:signalwalker/nix.home.base";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    with builtins; let
      std = nixpkgs.lib;
      hlib = inputs.homelib.lib;
      home = hlib.home;
      signal = hlib.signal;
      sys = hlib.sys;
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      signalModules.default = {
        name = "sys.home.default";
        dependencies = signal.flake.set.toDependencies {
          flakes = inputs;
          filter = [];
          outputs = {
            sysbase = {
              nixosModules = ["default"];
            };
          };
        };
        outputs = dependencies: {
          homeManagerModules = {
            config,
            lib,
            ...
          }: {
          };
          nixosModules = {
            config,
            lib,
            ...
          }: {
            imports = [./nixos-module.nix];
          };
        };
      };
      homeConfigurations = home.configuration.fromFlake {
        flake = self;
        flakeName = "sys.home";
        isNixOS = false;
      };
      nixosConfigurations = sys.configuration.fromFlake {
        flake = self;
        flakeName = "sys.home";
      };
    };
}
