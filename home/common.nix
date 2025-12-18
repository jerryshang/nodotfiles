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
    neovim
    difftastic

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
    maven

    ### rust
    rustup
  ] ++ lib.optionals stdenv.isDarwin [
    # for macOS only
    ruby_3_2
    cocoapods
    m-cli
  ] ++ lib.optionals stdenv.isLinux [
    # for linux only
    docker
  ];

  home.sessionVariables = lib.mkMerge [
    {
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
    }
    (lib.mkIf (pkgs.stdenv.isDarwin) {
      ANDROID_HOME = "\${HOME}/Library/Android/sdk";
      PATH = "\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/tools/bin:\$ANDROID_HOME/platform-tools";
    })
  ];

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-17;
  };

  # https://direnv.net/
  # https://github.com/nix-community/nix-direnv
  # NOTE: zsh hook is in chezmoi zshrc
  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };

  # NOTE: configs moved to chezmoi:
  # - zsh: ~/.local/share/chezmoi/dot_zshrc
  # - git: ~/.local/share/chezmoi/dot_gitconfig
  # - ssh: ~/.local/share/chezmoi/private_dot_ssh/config
  # - nvim: ~/.local/share/chezmoi/private_dot_config/nvim/init.vim
  # - editorconfig: ~/.local/share/chezmoi/dot_editorconfig
}
