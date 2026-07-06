# 573-nix

Run 573 games effortlessly on Linux using Nix

### Supported games

beatmania IIDX:

- 33 Sparkle Shower (`iidx-33-sparkle-shower`)

DanceDanceRevolution:

- A20 Plus (`ddr-a20-plus`)

### Usage

Simply run the follwing command (replace `<game>` with a supported game from above):

```
$ nix run https://codeberg.org/ungeskriptet/573-nix/archive/master.tar.gz#<game>
```

Be patient, as this command will build everything for you. This can take a long time depending on
your specs and internet connection. If you already have the game data, you can try adding it to the
nix store using `nix store add`.

If you use NixOS, it's recommended to incorporate this flake into your NixOS config to prevent
garbage collection of the game data.
