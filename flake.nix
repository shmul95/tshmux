{
  description = "Home Manager module for the tshmux tmux configuration";

  outputs = { self }:
    {
      homeManagerModules = {
        default = import ./nixos/modules/home-manager/tshmux.nix;
      };
    };
}
