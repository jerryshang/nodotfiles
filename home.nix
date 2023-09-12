{ config, pkgs, lib, ... }:
### https://nix-community.github.io/home-manager/options.html
{
  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    # zsh
    # basic
    coreutils
    inetutils
    du-dust
    tree
    curl
    wget
    openssl
    rsync
    htop
    # shell
    tmux
    # neovim
    # documentation
    hugo
    asciidoctor-with-extensions
    watchexec
    pandoc
    imagemagick
    # dev
    docker
    # git
    glab
    gh
    jq
    httpie
    # c and cpp
    cmake
    boost
    # javascript
    nodejs_18
    yarn
    # java
    temurin-bin-17
    gradle
    ## 🤔 deps on pkgs.jdk(now zulu jdk19)
    maven
  ] ++ lib.optionals stdenv.isDarwin [
    # for macOS only
    cocoapods
    m-cli
    colima
  ];

  home.sessionVariables = lib.mkMerge [
    {
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = /var/run/docker.sock;
    }
    (lib.mkIf (pkgs.stdenv.isDarwin) {
      DOCKER_HOST = "unix://\${HOME}/.colima/docker.sock";
      # only on myOtherMac
      # manually install android studio first
      ANDROID_HOME = "\${HOME}/Library/Android/sdk";
      PATH = "\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools";
    })
  ];

  editorconfig.enable = true;
  editorconfig.settings = {
    "*" = {
      charset = "utf-8";
      end_of_line = "lf";
      trim_trailing_whitespace = true;
      insert_final_newline = true;
      max_line_width = 120;
      indent_style = "space";
      indent_size = 2;
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-17;
  };

  programs.zsh = {
    enable = true;
    # need turn off default prompt
    # https://github.com/NixOS/nixpkgs/blob/4ecab3273592f27479a583fb6d975d4aba3486fe/nixos/modules/programs/zsh/zsh.nix#L89
    initExtra = "autoload -Uz promptinit && promptinit && prompt off && prompt pure";
    initExtraFirst = ''
      DISABLE_MAGIC_FUNCTIONS="true"
      setopt interactive_comments
      unsetopt nomatch
      autoload -U compinit && compinit
    '';
    completionInit = "";
    envExtra = "";
    defaultKeymap = "viins";
    syntaxHighlighting = {
      enable = true;
    };
    # can placed in home.shellAliases
    shellAliases = {
      ll = "ls -lah";
      # build and switch
      ns-mac = "darwin-rebuild switch --flake \"$HOME/.config/nix#myOtherMac\"";
      ns-linux = "nix run home-manager -- --flake ~/.config/nix#jerry@server switch";
      ns-pi = "nix run home-manager -- --flake ~/.config/nix#jerry@rpi switch";
      how = "echo $(compgen -a) | tr -s '[:blank:]' '\n' | grep -e '^ns-' ";
    };
    shellGlobalAliases = {
      UUID = "$(uuidgen | tr -d \\n)";
    };
    history = {
      size = 10000;
      ignorePatterns = [
        "rm *"
        "kill *"
        "pkill *"
      ];
    };

    autocd = true;

    # https://getantidote.github.io/
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/antidote.nix
    antidote = {
      enable = true;
      useFriendlyNames = true;
      plugins = [
        "rupa/z"
        "zsh-users/zsh-completions"
        "zsh-users/zsh-autosuggestions"
        "sindresorhus/pure     kind:fpath"
        # deps by copypath/copyfile/copybuffer/...
        "ohmyzsh/ohmyzsh path:lib"
        # ESC, ESC
        "ohmyzsh/ohmyzsh path:plugins/sudo"
        "ohmyzsh/ohmyzsh path:plugins/copypath"
        "ohmyzsh/ohmyzsh path:plugins/copyfile"
        # CTRL-O
        "ohmyzsh/ohmyzsh path:plugins/copybuffer"
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/macos
        "ohmyzsh/ohmyzsh path:plugins/macos"
      ];
    };
  };

  programs.neovim = {
    enable = true;
    coc.enable = false;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
        set termguicolors
        set incsearch ignorecase smartcase hlsearch
        set list listchars=trail:»,tab:»-
        set wrap breakindent
        set number
        set relativenumber

        " disable mouse select to visual block
        set mouse-=a

        let mapleader = ","
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = rainbow;
        config = "let g:rainbow_active = 1";
      }
      {
        plugin = indent-blankline-nvim;
        config = ''
            " indentLine
            let g:indentLine_setConceal = 0
        '';
      }
      # https://github.com/marko-cerovac/material.nvim/
      {
        plugin = material-nvim;
        config = ''
            let g:material_style = 'deep ocean'
            colorscheme material
        '';
      }
    ];
  };

  # https://direnv.net/
  # https://github.com/nix-community/nix-direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Jerry Shang";
    userEmail = "jerryshang@gmail.com";
    aliases = {
      co = "checkout";
      cob = "checkout -b";
      del = "branch -D";
      br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
      undo = "reset HEAD~1 --mixed";
      save = "!git add -A && git commit -m 'chore: commit save point'";
      done = "!git push origin HEAD";
      lg = "!git log --pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30";
      ver = "!git log --graph --all --oneline --simplify-by-decoration --date=format:%Y-%m-%d\\ %H:%M:%S --pretty=format:\"%C(brightblack)%cd%Creset %C(yellow)%h%C(auto)%d%  %s\"";
      al = "config --get-regexp '^alias\.'";
      clr = "git rm --cached $(git ls-files -i -c --exclude-from=.gitignore)";
    };
    attributes = [
      "merge.ours.driver true"
      "core.quotepath off"
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "nvim";
      };
      pull = {
        rebase = true;
      };
      safe = {
        directory = "*";
      };
      push = {
        default = "current";
        autoSetupRemote = "true";
      };
    };
    difftastic.enable = true;
    ignores = [
      ".DS_Store"
      "._*"
      "Thumbs.db"
      "tmp/"
      "target/"
      "build/"
      "out/"
      "dist/"
      "log/"
      "logs/"
      "*~"
      "*.swp"
      "*.log"
      "*.bak"
      "*.pid"
      ".idea/"
      ".settings/"
      ".gradle/"
      ".env"
      ".env.*"
      "node_modules/"
    ];
  };

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    matchBlocks = {
      "rpi.local" = {
        hostname = "rpi.local";
        user = "jerry";
      };
    };
    includes = [] ++ lib.optionals pkgs.stdenv.isDarwin [
      ".colima/ssh_config"
    ];
  };
}
