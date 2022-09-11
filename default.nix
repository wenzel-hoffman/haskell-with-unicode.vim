let sources = import nix/sources.nix; in

{ pkgs ? import sources.nixpkgs {}

# Automatically set to `true` when using this configuration with `nix-shell`
, inNixShell ? false

# Adding “vim” and “nvim” to nix-shell for running tests
, withVim ? true
, withNeovim ? true
}:

let
  thisRepoSource =
    pkgs.nix-gitignore.gitignoreRecursiveSource [ ./.gitignore ] ./.;

  haskell-with-unicode = pkgs.vimUtils.buildVimPlugin rec {
    pname = "haskell-with-unicode.vim";
    name = pname;
    src = thisRepoSource;
  };

  # WARNING! Changes in this configuration may take effect on whether the tests
  # will pass or fail.
  vimRC = ''
    set nocompatible

    " Use spaces instead of tabs for Haskell
    set expandtab

    " Common indentation size for Haskell
    set tabstop=2
    set shiftwidth=2

    syntax on
    filetype plugin indent on
  '';

  vim = pkgs.vim_configurable.customize {
    vimrcConfig = {
      packages.myPlugins.start = [ haskell-with-unicode ];
      customRC = vimRC;
    };
  };

  neovim = pkgs.neovim.override {
    configure = {
      packages.myPlugins.start = [ haskell-with-unicode ];
      customRC = vimRC;
    };
  };

  shell = pkgs.mkShell {
    buildInputs = [
      # Some dependencies for scripts (e.g. tests running script) to work
      pkgs.bash
      pkgs.coreutils
      pkgs.diffutils

      vim
      neovim
    ] ++ pkgs.lib.optional withVim vim
      ++ pkgs.lib.optional withNeovim neovim;
  };
in

(if inNixShell then shell else {}) // {
  inherit shell vim neovim haskell-with-unicode;
}
