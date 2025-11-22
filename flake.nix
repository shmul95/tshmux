{
  description = "Reproducible tmux configuration with plugin fetch support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    tmuxPlugins = {
      # TPM
      tpm.url = "github:tmux-plugins/tpm";

      # Core plugins
      sensible.url = "github:tmux-plugins/tmux-sensible";
      resurrect.url = "github:tmux-plugins/tmux-resurrect";
      continuum.url = "github:tmux-plugins/tmux-continuum";
      yank.url = "github:tmux-plugins/tmux-yank";

      # Navigation + theme pack
      navigator.url = "github:christoomey/vim-tmux-navigator";
      themepack.url = "github:jimeh/tmux-themepack";
    };
  };

  outputs = { self, nixpkgs, tmuxPlugins, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;

      mkPlugin = name: src: system:
        let
          pkgs = import nixpkgs { inherit system; };
        in pkgs.stdenvNoCC.mkDerivation {
          pname = "tmux-plugin-${name}";
          version = src.rev or "unknown";
          inherit src;
          installPhase = ''
            mkdir -p $out
            cp -R . $out
          '';
        };
    in {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };

          # Build all plugins from GitHub inputs
          pluginSet = nixpkgs.lib.mapAttrs (name: v: mkPlugin name v system) tmuxPlugins;

          # Build the final combined plugin tree
          plugins = pkgs.symlinkJoin {
            name = "tmux-plugins";
            paths = builtins.attrValues pluginSet;
          };
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "tshmux";
            version = if self ? shortRev then self.shortRev else "dev";

            src = ./.;

            installPhase = ''
              mkdir -p $out/share/tshmux
              cp ${./tmux.conf} $out/share/tshmux/tmux.conf
              cp -R ${plugins} $out/share/tshmux/plugins
            '';
          };

          inherit plugins pluginSet;
        });

      formatter = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.nixpkgs-fmt);
    };
}

