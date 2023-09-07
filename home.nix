{ config, pkgs, lib, ... }:

{
  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    # zsh
    # basic
    coreutils
    du-dust
    curl
    wget
    openssl
    rsync
    htop
    # shell
    tmux
    neovim
    # documentation
    hugo
    asciidoctor-with-extensions
    watchexec
    pandoc
    imagemagick
    # dev
    docker
    git
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
    })
  ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-17;
  };

  programs.zsh = {
    enable = true;
    package = pkgs.zsh;
    # need turn off default prompt
    # https://github.com/NixOS/nixpkgs/blob/4ecab3273592f27479a583fb6d975d4aba3486fe/nixos/modules/programs/zsh/zsh.nix#L89
    initExtra = "autoload -Uz promptinit && promptinit && prompt off && prompt pure";
    initExtraFirst = ''
      setopt interactive_comments
      unsetopt nomatch
      autoload -U compinit && compinit
    '';
    defaultKeymap = "viins";
    syntaxHighlighting = {
      enable = true;
    };
    # can placed in home.shellAliases
    shellAliases = {
      ll = "ls -lah";
      # build and switch
      nix-dre = "darwin-rebuild switch --flake \"$HOME/.config/nix#myOtherMac\"";
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

  # https://direnv.net/
  # https://github.com/nix-community/nix-direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
