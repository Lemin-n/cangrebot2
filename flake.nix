{
  description = "Rust Lang Es flake for Cangrebot ❄️  🦀 ";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    fenix.url = "github:nix-community/fenix/monthly";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
  };
  outputs = inputs @ {
    flake-parts,
    fenix,
    nixpkgs,
    flake-utils,
    crane,
    self,
    ...
  }:
    inputs.flake-parts.lib.mkFlake
    {
      inherit inputs;
    }
    {
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) lib;
        # Toolchain
        toolchain = with fenix.packages.${system};
          combine [
            complete.cargo
            complete.clippy
            complete.rust-src
            complete.rustc
            complete.rustfmt
            targets.x86_64-pc-windows-gnu.latest.rust-std
            targets.x86_64-unknown-linux-gnu.latest.rust-std
          ];
        craneLib = crane.lib.${system}.overrideToolchain toolchain;
      in {
        # nix develop
        devShells.default = craneLib.devShell {
          packages = with pkgs; [
            toolchain
            openssl.dev
            pkg-config
          ];
        };
      };
    };
}
