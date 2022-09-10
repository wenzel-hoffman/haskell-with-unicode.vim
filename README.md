# Syntax Highlighting and Indentation for Haskell and Cabal with Unicode Support

Vim/Neovim plugin for Haskell language support (including Cabal) which provides
better experience than builtin Haskell support in Vim.

This is a fork of [haskell-vim][] with added unicode support. There is no
promise though it will always be as the original plugin but only with unicode
support. This fork may have other differences from its origin. The original
plugin itself was also forked from [idris-vim][].

## Features

* Covers a broader spectrum of keywords
* Highlighting for new features like type families, pattern synonyms, arrow
  syntax, recursive do, role annotations, QuasiQuotation
* More contextual highlighting
  (e.g. highlight `as` or `family` only in appropriate places)
* Smarter indentation
* Better Cabal support

## Installation

### Nix or NixOS

If you are using [Nix or NixOS][] you can look at this page to figure out how to
configure your Vim or Neovim including how to add/install the plugins:
https://nixos.wiki/wiki/Vim

If you can’t find this `haskell-with-unicode.vim` plugin in your nixpkgs pin
(in `pkgs.vimPlugins.*` namespace) here are a couple of examples how you can
configure it in your `configuration.nix`.

As `programs.vim` in case of NixOS:

``` nix
{ pkgs, ... }
let
  haskell-with-unicode = vimUtils.buildVimPlugin rec {
    pname = "haskell-with-unicode.vim";
    name = pname;
    src = fetchTarball {
      # Replace `fff` with your commit hash
      url = "https://github.com/wenzel-hoffman/haskell-with-unicode.vim/archive/fff.tar.gz";
      # To get a checksum try to rebuild the configuration once and take the hash
      # from the error log or call (the URL from above, remember to replace `fff`):
      #   nix-prefetch-url --unpack https://github.com/wenzel-hoffman/haskell-with-unicode.vim/archive/fff.tar.gz
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  };
in
{
  programs.vim = {
    enable = true;
    plugins = [ haskell-with-unicode ];
    extraConfig = ''
      syntax on
      filetype plugin indent on
    '';
  };
}
```

Or as a regular derivation (this can be used just with Nix, outside of NixOS).
Just create `default.nix` with the below contents:

``` nix
{ pkgs ? import <nixpkgs> {} }:
let
  haskell-with-unicode = pkgs.vimUtils.buildVimPlugin rec {
    pname = "haskell-with-unicode.vim";
    name = pname;
    src = fetchTarball {
      # Replace `fff` with your commit hash
      url = "https://github.com/wenzel-hoffman/haskell-with-unicode.vim/archive/fff.tar.gz";
      # To get a checksum try to rebuild the configuration once and take the hash
      # from the error log or call (the URL from above, remember to replace `fff`):
      #   nix-prefetch-url --unpack https://github.com/wenzel-hoffman/haskell-with-unicode.vim/archive/fff.tar.gz
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  };

  vimWithPlugins = pkgs.vim_configurable.customize {
    vimrcConfig = {
      packages.myplugins = {
        start = [ haskell-with-unicode ];
      };
      customRC = ''
        syntax on
        filetype plugin indent on
      '';
    };
  };
in
pkgs.mkShell {
  buildInputs = [ vimWithPlugins ];
}
```

And run (being in the directory where you created that `default.nix` file):

``` sh
nix-shell --run 'vim hello.hs'
```

P.S. You can use [Niv][] (written in Haskell) for easier management of the
plugin updates.

### VimPlug

Add this line into your `.vimrc` (Vim) or `init.vim` (Neovim):

``` viml
Plug 'wenzel-hoffman/haskell-with-unicode.vim'
```

Restart Vim/Neovim and execute `:PlugInstall`

### Pathogen

N.B. For Neovim just replace `~/.vim` to `~/.config/nvim`

Clone this repo into your `~/.vim/bundle` directory and you are ready to go.

``` sh
cd ~/.vim/bundle
git clone https://github.com/wenzel-hoffman/haskell-with-unicode.vim.git
```

### Manual Installation

Copy content into your `~/.vim` (Vim) or `~/.config/nvim` (Neovim) directory.

## Configuration

### Features

To enable the features you would like to use, just add the according line to
your `.vimrc` (Vim) or `init.vim` (Neovim).

```viml
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
```

### Highlighting

This plugin has an opinionated highlighting. If you do not like that you can
switch to a more traditional mode by setting
`g:haskell_classic_highlighting` to `1`.

Disabling Template Haskell and QuasiQuoting syntax is possible by setting
`g:haskell_disable_TH` to `1`.

### Indentation

If you dislike how indentation works you can disable it by setting
`g:haskell_indent_disable` to `1`.

Additionally you can use the [vim-hindent][] plugin to achieve automatic
indentation using [hindent][]. Mind that *hindent* itself recommends to just use
`formatprg` feature for this purpose:

``` viml
setlocal formatprg=hindent
```

And then press `gq` to reformat. See `:help 'formatprg'` and `:help gq` for
detauls.

#### Haskell

* `let g:haskell_indent_if = 3`

  ``` haskell
  if bool
  >>>then ...
  >>>else ...
  ```

* `let g:haskell_indent_case = 2`

  ``` haskell
  case xs of
  >>[]     -> ...
  >>(y:ys) -> ...
  ```

* `let g:haskell_indent_let = 4`

  ``` haskell
  let x = 0 in
  >>>>x
  ```

* `let g:haskell_indent_where = 6`

  ``` haskell
  where f :: Int -> Int
  >>>>>>f x = x
  ```

* `let g:haskell_indent_before_where = 2`

  ``` haskell
  foo
  >>where
  ```

* `let g:haskell_indent_after_bare_where = 2`

  ``` haskell
  where
  >>foo
  ```

* `let g:haskell_indent_do = 3`

  ``` haskell
  do x <- a
  >>>y <- b
  ```

* `let g:haskell_indent_in = 1`

  ``` haskell
  let x = 1
  >in x
  ```

* `let g:haskell_indent_guard = 2`

  ``` haskell
  f x y
  >>|
  ```

This plugin also supports an alterative style for `case` indentation.

* `let g:haskell_indent_case_alternative = 1`

  ``` haskell
  f xs ys = case xs of
  >>[]     -> ...
  >>(y:ys) -> ...
  ```

#### Cabal

*  `let g:cabal_indent_section = 2` (limited to max. 4 spaces)

        executable name
        >>main-is:             Main.hs

## Author

* Original author of the [haskell-vim][] plugin: [raichoo][]
* Author/maintainer of [this fork][]: Viacheslav Lotsmanov

[Nix/NixOS]: https://nixos.org/
[Niv]: https://github.com/nmattia/niv
[Pathogen]: https://github.com/tpope/vim-pathogen

[idris-vim]: https://github.com/idris-hackers/idris-vim
[haskell-vim]: https://github.com/neovimhaskell/haskell-vim
[vim-hindent]: https://github.com/alx741/vim-hindent
[hindent]: https://github.com/mihaimaruseac/hindent

[raichoo]: https://github.com/raichoo
[this fork]: https://github.com/wenzel-hoffman/haskell-with-unicode.vim
