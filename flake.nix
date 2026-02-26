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
          default = tshmux;

          # Raw configuration files and plugins (for home-manager or manual setup)
          config = pkgs.stdenvNoCC.mkDerivation {
            pname = "tshmux-config";
            version = if self ? shortRev then self.shortRev else "dev";

            src = ./.;

            installPhase = ''
              mkdir -p $out/share/tshmux
              cp ${./tmux.conf} $out/share/tshmux/tmux.conf
              ln -s ${allPlugins} $out/share/tshmux/plugins
            '';
          };

          # Complete tmux setup with configuration
          tshmux = pkgs.symlinkJoin {
            name = "tshmux-complete";
            paths = [ tmux-configured ];
            postBuild = ''
              # Create wrapper script for easy setup
              mkdir -p $out/bin
              cat > $out/bin/tshmux-setup <<'EOF'
              #!/bin/sh
              echo "Setting up tshmux configuration..."
              
              # Create tmux config directory
              mkdir -p ~/.config/tmux
              
              # Copy configuration
              cp ${tmux-configured}/share/tmux.conf ~/.config/tmux/tmux.conf
              
              # Setup plugins directory
              mkdir -p ~/.tmux/plugins
              rm -rf ~/.tmux/plugins/tpm
              ln -sf ${allPlugins}/share/tmux-plugins/* ~/.tmux/plugins/
              
              echo "tshmux configuration installed!"
              echo "You can now run: tmux"
              EOF
              chmod +x $out/bin/tshmux-setup
              
              # Also provide direct tmux command with config
              cat > $out/bin/tshmux <<'EOF'
              #!/bin/sh
              exec ${pkgs.tmux}/bin/tmux -f ${tmux-configured}/share/tmux.conf "$@"
              EOF
              chmod +x $out/bin/tshmux
            '';
          };

          # Tmux with embedded configuration
          tmux-configured = pkgs.stdenvNoCC.mkDerivation {
            pname = "tshmux-tmux";
            version = if self ? shortRev then self.shortRev else "dev";

            src = ./.;

            buildInputs = [ pkgs.tmux ];

            installPhase = ''
              mkdir -p $out/share $out/bin

              # Create the complete tmux configuration
              cat > $out/share/tmux.conf <<'EOF'
              # zsh default term  
              set-option -g default-shell ${pkgs.zsh}/bin/zsh
              set-option -g default-command ${pkgs.zsh}/bin/zsh

              # Global color palette
              set -g @color-yellow "#FFDF32"
              set -g @color-black "#000000"
              set -g @color-gray-light "#D8DEE9"
              set -g @color-gray-medium "#ABB2BF"
              set -g @color-gray-dark "#3B4252"

              # Bind Alt-n to a new window
              bind -n M-n new-window -c "#{pane_current_path}"
              # Bind Alt-Shift-n to a new session rooted in the current path
              bind -n M-N command-prompt -p "New session name:" "new-session -A -s '%%' -c '#{pane_current_path}'"
              bind -n M-d detach-client
              bind -n M-q copy-mode

              # Bind Alt-s to session switcher
              bind -n M-s choose-tree -s

              # Bind Alt-h/j/k/l to go to specific windows
              bind -n M-h select-window -t 0
              bind -n M-j select-window -t 1
              bind -n M-k select-window -t 2
              bind -n M-l select-window -t 3
              bind -n M-H select-window -t 4
              bind -n M-J select-window -t 5
              bind -n M-K select-window -t 6
              bind -n M-L select-window -t 7

              bind -n M-Left select-pane -L
              bind -n M-Right select-pane -R
              bind -n M-Up select-pane -U
              bind -n M-Down select-pane -D

              bind -n M-- split-window -h  # Vertical split (side-by-side)
              bind -n M-_ split-window -v  # Horizontal split (stacked)

              bind -n M-: command-prompt

              # Bind Alt-r to restore sessions via tmux-resurrect
              bind -n M-r run-shell -b '${allPlugins}/share/tmux-plugins/resurrect/scripts/restore.sh'

              # Plugin paths (using nix store paths instead of ~/.tmux/plugins)
              set-environment -g TMUX_PLUGIN_MANAGER_PATH "${allPlugins}/share/tmux-plugins"

              # List of plugins (sources from nix store)
              run-shell "${allPlugins}/share/tmux-plugins/sensible/sensible.tmux"
              run-shell "${allPlugins}/share/tmux-plugins/resurrect/resurrect.tmux"  
              run-shell "${allPlugins}/share/tmux-plugins/continuum/continuum.tmux"
              run-shell "${allPlugins}/share/tmux-plugins/navigator/vim-tmux-navigator.tmux"
              run-shell "${allPlugins}/share/tmux-plugins/yank/yank.tmux"

              # ---- Vi copy-mode + M-q tweaks ----
              # Use vi keys in copy-mode and status line
              set -g mode-keys vi
              set -g status-keys vi

              set -sg escape-time 0

              # Enter copy-mode with Alt-q
              unbind -n M-q
              bind -n M-q copy-mode

              # In copy-mode-vi, add vim-like selection and easy exit
              bind -T copy-mode-vi v send -X begin-selection
              bind -T copy-mode-vi V send -X select-line
              bind -T copy-mode-vi Escape send -X cancel
              bind -T copy-mode-vi M-q send -X cancel

              # Also support exiting from emacs copy-mode table just in case
              bind -T copy-mode M-q send -X cancel

              bind -n M-w \
                send-keys 'codex' C-m \; \
                new-window -n nvim -c "#{pane_current_path}" -d 'nvim' \; \
                new-window -n term -c "#{pane_current_path}"

              # Resurrect
              set -g @resurrect-capture-pane-contents 'on'
              set -g @continuum-restore 'on'

              set -g status-position top
              set -g status-style "fg=#{@color-yellow},bg=#{@color-black}"
              set -g status-left "#[fg=#{@color-yellow},bold]\[#S\]#[fg=#{@color-gray-light},bold] | "
              set -g status-left-length 40
              set -g window-status-format "#[fg=#{@color-gray-dark}] #W "
              set -g window-status-current-format "#[fg=#{@color-yellow},bg=#{@color-black},bold] #W "
              set -g status-right ""
              set -g message-style "fg=#{@color-gray-light},bg=#{@color-black}"
              # Copy-mode cursor line + selection styling
              set -g mode-style "fg=#{@color-gray-dark},bg=#{@color-yellow}"
              set -g copy-mode-selection-style "bg=#{@color-gray-dark}"
              set -g pane-border-style "fg=#{@color-gray-dark}"
              set -g pane-active-border-style "fg=#{@color-gray-medium}"

              # Local overrides for system clipboard (adjust based on your display server)
              # Make `y` in copy-mode-vi yank to system clipboard and exit
              bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${
                if pkgs.stdenv.isLinux then 
                  if pkgs.wayland != null then "wl-copy" else "xclip -selection clipboard"
                else "pbcopy"
              }"
              EOF
            '';
          };

          plugins = allPlugins;
        });

      formatter = forEachSystem (system:
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.nixpkgs-fmt);
    };
}
