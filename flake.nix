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

          # clipboard command - detect at runtime for proper system integration
          clipboardScript = pkgs.writeShellScript "clipboard-copy" ''
            if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
              wl-copy
            elif [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
              xclip -selection clipboard
            elif command -v wl-copy >/dev/null 2>&1; then
              wl-copy  
            elif command -v xclip >/dev/null 2>&1; then
              xclip -selection clipboard
            else
              cat > /dev/null
            fi
          '';

          # tmux.conf as a var in nix
          tmuxConf = pkgs.replaceVars ./tmux.conf {
            pluginPath = allPlugins;
            inherit pluginLoader;
            clipboardCmd = clipboardScript;
          };

          tshmux = pkgs.writeShellScriptBin "tshmux" ''
            export PATH=${pkgs.lib.makeBinPath [ pkgs.wl-clipboard pkgs.xclip ]}:$PATH
            exec ${pkgs.tmux}/bin/tmux -f ${tmuxConf} "$@"
          '';
        in {
          default = tshmux;
          inherit tshmux allPlugins;
        });

      formatter = forEachSystem (system: (import nixpkgs { inherit system; }).nixpkgs-fmt);
    };
}
