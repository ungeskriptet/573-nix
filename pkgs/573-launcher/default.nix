{
  lib,
  writeShellApplication,
  coreutils,
  gst_all_1,
  winetricks,
  wineWow64Packages,
  bmsound,
  spice2x,
  # Following args must be set
  gamePkg,
  spiceDefaultArgs ? [ ],
  spiceExe ? "spice64.exe",
  winetricksVerbs ? [
    "dxvk"
    "d3dcompiler_43"
    "d3dx9_43"
  ],
}:
let
  launcherName = "${gamePkg.name}-launcher";
  gst = with gst_all_1; [
    gst-libav
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
  ];
in
writeShellApplication {
  name = launcherName;
  runtimeInputs = [
    coreutils
    winetricks
    wineWow64Packages.full # Full package required for GStreamer support
  ];
  bashOptions = [
    "errexit"
    "nounset"
    "pipefail"
  ];
  inheritPath = false;
  text = ''
    GAMEDIR=''${XDG_DATA_HOME:-"$HOME/.local/share"}/573-games

    help () {
      cat <<EOF
    Launcher script for ${gamePkg.name}

    Usage:
    ${launcherName} <options> <spice2x args>

    Options:
    -h, --help     Show help and exit
    -p, --path     Change default path where game data is stored (Default: $GAMEDIR)
    -c, --cfg      Launch spicecfg.exe
    -wc, --winecfg Launch winecfg
    --fix-display  Do not unset \$DISPLAY variable
    EOF
    exit "$1"
    }

    info () {
      NO_FORMAT="\033[0m"
      C_NAVY="\033[38;5;4m"
      echo -e "''${C_NAVY}$*''${NO_FORMAT}"
    }

    LAUNCH_CFG=0
    UNSET_DISPLAY=1
    WINECFG=0

    while [ $# -gt 0 ]; do
      case "$1" in
        --help|-h) help 0 ;;
        --path|-p) GAMEDIR="$2" ; shift 2 ;;
        --cfg|-c) LAUNCH_CFG=1; shift ;;
        --fix-display) UNSET_DISPLAY=0 ; shift ;;
        --winecfg|-wc) WINECFG=1; shift ;;
        *) break ;;
      esac
    done

    if [ $UNSET_DISPLAY -eq 1 ]; then
      unset DISPLAY
    fi

    GAMEDIR="$GAMEDIR"/${gamePkg.name}
    mkdir -p "$GAMEDIR"
    if [ ! -d "$GAMEDIR"/gamedata ]; then
      info "Symlinking game data to $GAMEDIR/gamedata"
      cp --no-preserve=mode,ownership -rsf ${gamePkg} "$GAMEDIR"/gamedata
      rm -rf "$GAMEDIR"/gamedata/contents/dev
    fi

    export GST_PLUGIN_SYSTEM_PATH_1_0="${lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gst}"
    export LD_LIBRARY_PATH="$GAMEDIR"/gamedata/contents/modules
    export WINEARCH=win64
    export WINEDEBUG=-all
    export WINEDLLPATH="$GAMEDIR"/gamedata/contents/modules
    export WINEPREFIX="$GAMEDIR"/wineprefix

    if [ ! -d "$WINEPREFIX" ]; then
      info "Creating wineprefix for ${gamePkg.name}"
      wineboot --init
      export WINESERVER_BIN=${lib.getExe' wineWow64Packages.full "wineserver"}
      export WINE_BIN=${lib.getExe' wineWow64Packages.full ".wine"}
      winetricks ${lib.concatStringsSep " " winetricksVerbs}
    fi

    ln -sf ${bmsound}/bmsound-*{.so,.dll} "$GAMEDIR"/gamedata/contents/modules
    ln -sf ${spice2x}/{${spiceExe},spicecfg.exe} "$GAMEDIR"/gamedata/contents
    ln -sf ${spice2x}/stubs/64/* "$GAMEDIR"/gamedata/contents/modules

    cd "$GAMEDIR"/gamedata/contents

    if [ "$LAUNCH_CFG" -eq 1 ]; then
      wine spicecfg.exe
    elif [ "$WINECFG" -eq 1 ]; then
      winecfg
    else
      wine ${spiceExe} ${lib.concatStringsSep " " spiceDefaultArgs} "$@"
    fi
  '';
}
