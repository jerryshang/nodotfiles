{ config, pkgs, lib, ... }:
### https://nix-community.github.io/home-manager/options.html
{
  home.stateVersion = lib.mkDefault "25.05";

  home.packages = with pkgs; [
    ### basic
    coreutils
    moreutils
    inetutils
    du-dust
    tree
    curl
    wget
    openssl
    rsync
    htop
    netcat-gnu
    ### shell
    tmux
    # neovim

    ### documentation
    #asciidoc-full-with-plugins
    asciidoctor-with-extensions
    watchexec
    pandoc
    #imagemagick
    imagemagickBig
    graphviz
    ### dev tools
    jq
    httpie
    ### c and cpp
    cmake

    ### javascript

    ### python
    uv
    ### java
    gradle
    # 🤔 deps on pkgs.jdk(now zulu jdk19)
    maven

    ### rust
    rustup
  ] ++ lib.optionals stdenv.isDarwin [
    # for macOS only
    ruby_3_2
    cocoapods
    m-cli
    # colima
  ] ++ lib.optionals stdenv.isLinux [
    # for linux only
    docker
  ];

  home.sessionVariables = lib.mkMerge [
    {
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
    }
    (lib.mkIf (pkgs.stdenv.isDarwin) {
      # only on myOtherMac
      # manually install android studio first
      ANDROID_HOME = "\${HOME}/Library/Android/sdk";
      PATH = "\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools";
      # for colima
      # DOCKER_HOST = "unix://\${HOME}/.colima/docker.sock";
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
    "*.{md,adoc}" = {
      max_line_length = "off";
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-17;
  };

  # NOTE: zsh config moved to chezmoi, see ~/.local/share/chezmoi/dot_zshrc

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
  # NOTE: zsh hook is in chezmoi zshrc
  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
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
        user = "pi";
      };
      "npi.local" = {
        hostname = "npi.local";
        user = "root";
      };
    };
    includes = [] ++ lib.optionals pkgs.stdenv.isDarwin [
      ".colima/ssh_config"
    ];
  };
}
