# no dotfiles, please

## on my mac

rebuild

```shell
darwin-rebuild switch --flake ~/.config/nix#myOtherMac
```

## on server

add mirrors to `/etc/nix/nix.conf`

```ini
substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
#trusted-substituters =
trusted-users = *
```

rebuild

```shell
nix run home-manager -- --flake ~/.config/nix#jerry@server switch

# on my raspberry pi
nix run home-manager -- --flake ~/.config/nix#jerry@rpi switch
```
