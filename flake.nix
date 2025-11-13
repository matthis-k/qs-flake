{
  description = "Quickshell desktop environment configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    quickshell.url = "github:quickshell-mirror/quickshell";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      quickshell,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        qs = quickshell.packages.${system}.default;
        configDir = ./.;
        quickde = pkgs.writeShellScriptBin "quickde" ''
          exec ${qs}/bin/quickshell -p ${configDir} $@
        '';
      in
      {
        packages.quickde = quickde;
        defaultPackage = quickde;
        apps.default = {
          type = "app";
          program = "${quickde}/bin/quickde";
        };
      }
    )
    // {
      nixosModules.default = { quickshell }: import ./module.nix { inherit quickshell; };
    };
}
