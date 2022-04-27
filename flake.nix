{
  description = "Sample nix-based user config for our server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils }:
    let
      overlay = import ./overlay/default.nix;
    in
    {
      overlay = import ./overlay/default.nix;
      users = {
        physicist = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          stateVersion = "21.11"; # typically you don't change this

          # change these yourself
          homeDirectory = "/home/physicist";
          username = "physicist";

          configuration = { pkgs, lib, ... }: {
            nixpkgs.overlays = [ overlay ];

            home.packages = with pkgs; [
              pkgs.home-manager

              # basic utilities
              bottom # bottom is top
              ripgrep
              fd
              tree
              git-annex

              # terminal debugging
              colortest

              # HEP
              root
              sxiv # image viewer

              # define additional packages here
              # you can search the package names on https://search.nixos.org/packages
              emacs
            ];

            imports = [
              # basic tools everyone should want
              ./profiles/git
              ./profiles/python
              ./profiles/tmux # screen replacement
              ./profiles/fzf # fuzzy find
              ./profiles/ranger # a nice CLI-based file manager

              # shell
              ./profiles/zsh

              # dev
              ./profiles/direnv
              ./profiles/bat # cat with syntax highlighting
              ./profiles/neovim # vi

              # config
              ./profiles/dircolors
            ];
          };
        };
      };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
          overlays = [ overlay ];
        };
      in
      {
        devShell = pkgs.mkShell {
          name = "server-user-config-devshell";
          buildInputs = with pkgs; [
            home-build
            home-switch
          ];
        };
      });
}
