{ tmuxPluginTpm, tmuxPluginSensible, tmuxPluginContinuum, tmuxPluginYank, tmuxPluginNavigator }:

{ config, lib, pkgs, ... }:

let
  inherit (lib) concatStringsSep mkEnableOption mkIf mkOption optionalString types optional;
  cfg = config.programs.tshmux;

  pluginSources = {
    inherit
      tmuxPluginTpm
      tmuxPluginSensible
      tmuxPluginContinuum
      tmuxPluginYank
      tmuxPluginNavigator;
  };

  mkPlugin = name: src: pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = name;
    version = src.rev or "dev";
    inherit src;
  };

  pluginSet = pkgs.lib.mapAttrs mkPlugin pluginSources;
  allPlugins = pkgs.symlinkJoin {
    name = "tmux-plugins";
    paths = builtins.attrValues pluginSet;
  };

  pluginLoader = pkgs.lib.concatMapStringsSep "\n"
    (p: "run-shell ${p}/share/tmux-plugins/${p.pluginName}/${p.pluginName}.tmux")
    (builtins.attrValues pluginSet);

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

  baseTmuxConf = pkgs.replaceVars ./tmux.conf {
    pluginPath = allPlugins;
    inherit pluginLoader;
    clipboardCmd = clipboardScript;
    zshBin = "${pkgs.zsh}/bin/zsh";
  };

  generatedTmuxConf = pkgs.writeText "tmux.conf" (
    builtins.readFile baseTmuxConf + "\n"
    + concatStringsSep "\n" [
      "# Home Manager overrides from programs.tshmux"
      "set -g @color-yellow \"${cfg.theme.yellow}\""
      "set -g @color-black \"${cfg.theme.black}\""
      "set -g @color-gray-light \"${cfg.theme.grayLight}\""
      "set -g @color-gray-medium \"${cfg.theme.grayMedium}\""
      "set -g @color-gray-dark \"${cfg.theme.grayDark}\""
      "set -g mouse ${if cfg.enableMouse then "on" else "off"}"
      "set -g mode-keys ${if cfg.enableViCopyMode then "vi" else "emacs"}"
      "set -g status-keys ${if cfg.enableViCopyMode then "vi" else "emacs"}"
      "set -g @continuum-restore '${if cfg.enableSessionRestore then "on" else "off"}'"
      "set -g status-position ${cfg.status.position}"
      "set -g status-left \"${cfg.status.left}\""
      "set -g status-right \"${cfg.status.right}\""
      "set -g status-style \"fg=#{@color-yellow},bg=#{@color-black}\""
      "set -g message-style \"fg=#{@color-gray-light},bg=#{@color-black}\""
      "set -g mode-style \"fg=#{@color-gray-dark},bg=#{@color-yellow}\""
      "set -g copy-mode-selection-style \"bg=#{@color-gray-dark}\""
      "set -g pane-border-style \"fg=#{@color-gray-dark}\""
      "set -g pane-active-border-style \"fg=#{@color-gray-medium}\""
    ]
    + optionalString (!cfg.clipboard.enable) ''

      unbind-key -T copy-mode-vi y
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    ''
    + optionalString cfg.enableShellIntegration ''

      set -g default-command "${cfg.defaultShellCommand}"
    ''
    + optionalString (cfg.extraConfig != "") ''

      ${cfg.extraConfig}
    ''
  );

  tshmuxScript = pkgs.writeShellScriptBin "tshmux" ''
    export PATH=${pkgs.lib.makeBinPath [ pkgs.wl-clipboard pkgs.xclip ]}:$PATH
    exec ${pkgs.tmux}/bin/tmux -f ${generatedTmuxConf} "$@"
  '';

  tshmuxDefaultPackage = pkgs.symlinkJoin {
    name = "tshmux";
    paths = [ tshmuxScript ];
    postBuild = ''
      ln -s $out/bin/tshmux $out/bin/tmux
    '';
  };

  installedPackage = if cfg.setAsDefaultTmux then tshmuxDefaultPackage else tshmuxScript;
in {
  options.programs.tshmux = {
    enable = mkEnableOption "tshmux Home Manager integration";

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = "Install the tshmux wrapper package.";
    };

    setAsDefaultTmux = mkOption {
      type = types.bool;
      default = true;
      description = "Expose tshmux as both `tshmux` and `tmux` when installed.";
    };

    enableShellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Set tmux panes to start an interactive login shell.";
    };

    defaultShellCommand = mkOption {
      type = types.str;
      default = "$" + "{SHELL} -l";
      description = "Command used for new tmux panes when shell integration is enabled.";
    };

    enableMouse = mkOption {
      type = types.bool;
      default = true;
    };

    enableViCopyMode = mkOption {
      type = types.bool;
      default = true;
    };

    enableSessionRestore = mkOption {
      type = types.bool;
      default = true;
    };

    clipboard.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Copy yanks to the system clipboard.";
    };

    status.position = mkOption {
      type = types.enum [ "top" "bottom" ];
      default = "top";
    };

    status.left = mkOption {
      type = types.str;
      default = "#[fg=#{@color-yellow},bold]\\[#S\\]#[fg=#{@color-gray-light},bold] | ";
    };

    status.right = mkOption {
      type = types.str;
      default = "";
    };

    theme = {
      yellow = mkOption {
        type = types.str;
        default = "#FFDF32";
      };

      black = mkOption {
        type = types.str;
        default = "#000000";
      };

      grayLight = mkOption {
        type = types.str;
        default = "#D8DEE9";
      };

      grayMedium = mkOption {
        type = types.str;
        default = "#ABB2BF";
      };

      grayDark = mkOption {
        type = types.str;
        default = "#3B4252";
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra tmux configuration appended after tshmux defaults.";
    };
  };

  config = mkIf cfg.enable {
    home.file.".tmux.conf".source = generatedTmuxConf;
    home.packages = optional cfg.installPackage installedPackage;
  };
}
