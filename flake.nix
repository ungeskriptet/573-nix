{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ];
      treefmtEval = forAllSystems (
        system:
        inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} (
          { ... }:
          {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              keep-sorted.enable = true;
              mdformat = {
                enable = true;
                settings = {
                  number = true;
                  wrap = 100;
                };
              };
              nixf-diagnose = {
                enable = true;
                autoFix = false;
              };
            };
            settings = {
              verbose = 1;
              on-matched = "debug";
              formatter.nixf-diagnose.options = [
                "--ignore=sema-unused-def-lambda-witharg-formal"
              ];
            };
          }
        )
      );
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgsScope = pkgs.callPackage ./pkgs/default.nix { inherit pkgs; };
          filterScope = scope: pkgs.lib.filterAttrs (n: v: pkgs.lib.isDerivation v) scope;
        in
        filterScope pkgsScope
      );
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check inputs.self;
      });

    };
}
