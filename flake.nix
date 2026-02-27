{
  description = "Reproducible tmux configuration with plugin fetch support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    tmuxPluginTpm = {
      url = "github:tmux-plugins/tpm";
      flake = false;
    };
    tmuxPluginSensible = {
      url = "github:tmux-plugins/tmux-sensible";
      flake = false;
    };
    tmuxPluginContinuum = {
      url = "github:tmux-plugins/tmux-continuum";
      flake = false;
    };
    tmuxPluginYank = {
      url = "github:tmux-plugins/tmux-yank";
      flake = false;
    };
    tmuxPluginNavigator = {
      url = "github:christoomey/vim-tmux-navigator";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pluginSources = {
        inherit (inputs)
          tmuxPluginTpm
          tmuxPluginSensible
          tmuxPluginContinuum
          tmuxPluginYank
          tmuxPluginNavigator;
      };
    in {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Build Plugins
          mkPlugin = name: src: pkgs.tmuxPlugins.mkTmuxPlugin {
            pluginName = name;
            version = src.rev or "dev";
            inherit src;
          };
          pluginSet = pkgs.lib.mapAttrs (n: v: mkPlugin n v) pluginSources;
          allPlugins = pkgs.symlinkJoin {
            name = "tmux-plugins";
            paths = builtins.attrValues pluginSet;
          };

          # "run-shell" lines for the tmux.conf
          pluginLoader = pkgs.lib.concatMapStringsSep "\n"
            (p: "run-shell ${p}/share/tmux-plugins/${p.pluginName}/${p.pluginName}.tmux")
            (builtins.attrValues pluginSet);

          # clipboard command 
          clipboardCmd = if pkgs.stdenv.isLinux
            then (if pkgs.wayland != null
              then "wl-copy"
              else "xclip -section clipboard")
            else "pbcopy";

          # tmux.conf as a var in nix
          tmuxConf = pkgs.replaceVars ./tmux.conf {
            pluginPath = allPlugins;
            inherit pluginLoader clipboardCmd;
          };

          tshmux = pkgs.writeShellScriptBin "tshmux" ''
            exec ${pkgs.tmux}/bin/tmux -f ${tmuxConf} "$@"
          '';
        in {
          default = tshmux;
          inherit tshmux allPlugins;
        });

      formatter = forEachSystem (system: (import nixpkgs { inherit system; }).nixpkgs-fmt);
    };
}
