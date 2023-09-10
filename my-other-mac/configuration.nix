# https://daiderd.com/nix-darwin/manual/index.html
# - nix.settings
# - services
# - environment
# - programs
# - fonts
# - system
# - users.users
{ pkgs, lib, ... }:
{
  # will apply on nix
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "auto-allocate-uids"
    ];

    # A substituter is an additional store from which Nix can obtain store objects instead of building them
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-substituters
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];

    # `admin` is macOS's `wheel` group
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-trusted-users
    trusted-users = [ "@admin" ];

    auto-optimise-store = true;

    # /etc/nix/nix.conf content generated by
    # https://github.com/DeterminateSystems/nix-installer
    bash-prompt-prefix = "(nix:$name)\040";
    extra-nix-path = "nixpkgs=flake:nixpkgs";

    # on mac chip system, build intel chip too
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-extra-platforms
    extra-platforms = lib.mkIf (pkgs.system == "aarch64-darwin") [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };

  # 🤔
  # https://daiderd.com/nix-darwin/manual/index.html#opt-nix.configureBuildUsers
  nix.configureBuildUsers = true;

  # 🤔 nix-daemon for what?
  # https://daiderd.com/nix-darwin/manual/index.html#opt-services.nix-daemon.enable
  # /Library/LaunchDaemons
  services.nix-daemon.enable = true;

  # system-wide packages
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  # appears in /run/current-system/sw
  # automatically available to all users
  # automatically updated every time you rebuild the system configuration.
  environment.systemPackages = [
    # 🤔 https://daiderd.com/nix-darwin/manual/index.html#opt-environment.systemPackages
  ];

  # should disable to avoid conflict with zsh func like copypath
  # nix-index and its command-not-found helper
  # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.nix-index.enable
  programs.nix-index.enable = false;

  # must enable it, so new session can enable nix-env
  # if not enable, system built-in zsh will run without nix
  # https://daiderd.com/nix-darwin/manual/index.html#opt-programs.zsh.enable
  programs.zsh.enable = true;

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = [
    pkgs.inconsolata-nerdfont
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
  ];

  # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    brews = [
      "emqx/mqttx/mqttx-cli"
    ];
    taps = [
      "emqx/mqttx"
    ];
    casks = [
      "alfred"
      "amethyst"
      "anki"
      "calibre"
      "google-chrome"
      "iterm2"
      "logseq"
      "microsoft-remote-desktop"
      "snipaste"
      "squirrel"
      "tor-browser"
      "visual-studio-code"
    ];
  };

  # macOS system tweaking
  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # only specify home directory
  # will automatically create user? 🤔
  # https://daiderd.com/nix-darwin/manual/index.html#opt-users.users
  users.users."jerry" = {
    home = "/Users/jerry";
  };
}
