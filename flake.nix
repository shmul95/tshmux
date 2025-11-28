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
    tmuxPluginResurrect = {
      url = "github:tmux-plugins/tmux-resurrect";
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
    tmuxPluginThemepack = {
      url = "github:jimeh/tmux-themepack";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pluginSources = {
        tpm = inputs.tmuxPluginTpm;
        sensible = inputs.tmuxPluginSensible;
        resurrect = inputs.tmuxPluginResurrect;
        continuum = inputs.tmuxPluginContinuum;
        yank = inputs.tmuxPluginYank;
        navigator = inputs.tmuxPluginNavigator;
        themepack = inputs.tmuxPluginThemepack;
      };

      mkPluginSet = system:
        let
          pkgs = import nixpkgs { inherit system; };
          mkPlugin = name: src:
            pkgs.tmuxPlugins.mkTmuxPlugin {
              pluginName = name;
              version = src.rev or "dev";
              inherit src;
              postInstall = pkgs.lib.optionalString (name == "resurrect") ''
                rm -rf $out/share/tmux-plugins/${name}/tests
                rm -f $out/share/tmux-plugins/${name}/run_tests
              '';
            };
        in nixpkgs.lib.mapAttrs mkPlugin pluginSources;
    in {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };

          pluginSet = mkPluginSet system;

          allPlugins = pkgs.symlinkJoin {
            name = "tmux-plugins";
            paths = builtins.attrValues pluginSet;
          };
        in rec {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "tshmux";
            version = if self ? shortRev then self.shortRev else "dev";

            src = ./.;

            installPhase = ''
              mkdir -p $out/share/tshmux
              cp ${./tmux.conf} $out/share/tshmux/tmux.conf
              ln -s ${allPlugins} $out/share/tshmux/plugins
            '';
          };

          plugins = allPlugins;
          inherit pluginSet;
        });

      formatter = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.nixpkgs-fmt);
    };
}
