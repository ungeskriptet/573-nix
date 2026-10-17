{
  pkgs ? import <nixpkgs> { },
}:
with pkgs;
let
  spice32Args = {
    targets = [
      "spicetools_cfg"
      "spicetools_spice"
      "spicetools_stubs_cpusbxpkm"
    ];
    files = {
      "spicetools/32/cpusbxpkm.dll" = "stubs/32/cpusbxpkm.dll";
      "spicetools/32/spice.exe" = "spice.exe";
      "spicetools/spicecfg.exe" = "spicecfg.exe";
    };
  };
  spice64Args = {
    targets = [
      "spicetools_spice64"
      "spicetools_stubs_nvcuda"
      "spicetools_stubs_nvcuvid"
      "spicetools_stubs_nvEncodeAPI64"
    ];
    files = {
      "spicetools/64/nvcuda.dll" = "stubs/64/nvcuda.dll";
      "spicetools/64/nvcuvid.dll" = "stubs/64/nvcuvid.dll";
      "spicetools/64/nvEncodeAPI64.dll" = "stubs/64/nvEncodeAPI64.dll";
      "spicetools/64/spice64.exe" = "spice64.exe";
    };
  };
in
lib.makeScope newScope (
  self:
  let
    _573-launcher = self.callPackage ./573-launcher;
  in
  {
    # keep-sorted start block=yes prefix_order=ddr,iidx
    ddr-a20-plus = _573-launcher {
      gamePkg = self.ddr-a20-plus-data;
      spiceExe = "spice.exe";
      winetricksVerbs = [ "dxvk" ];
      spice2x = self.spice2x;
      spiceDefaultArgs = [
        "-audiohookdisable"
        "-runas user"
      ];
    };
    ddr-a20-plus-data = self.callPackage ./ddr/a20-plus.nix { };
    iidx-33-sparkle-shower = _573-launcher {
      gamePkg = self.iidx-33-sparkle-shower-data;
      spice2x = self.spice2x-nixac;
      spiceDefaultArgs = [
        "-audiobackend pipewire"
        "-audiodummy"
        "-runas user"
      ];
    };
    iidx-33-sparkle-shower-data = self.callPackage ./iidx/33-sparkle-shower.nix { };
    bmsound = self.callPackage ./bmsound/default.nix { };
    spice2x = pkgs.symlinkJoin {
      name = "spice2x";
      paths = [
        self.spice32
        self.spice64
      ];
    };
    spice2x-nixac = pkgs.symlinkJoin {
      name = "spice2x-nixac";
      paths = [
        self.spice32-nixac
        self.spice64-nixac
      ];
    };
    spice32 = pkgsCross.mingw32.callPackage ./spice2x/default.nix spice32Args;
    spice32-nixac = pkgsCross.mingw32.callPackage ./spice2x/nixac.nix spice32Args;
    spice64 = pkgsCross.mingwW64.callPackage ./spice2x/default.nix spice64Args;
    spice64-nixac = pkgsCross.mingwW64.callPackage ./spice2x/nixac.nix spice64Args;
    # keep-sorted end
  }
)
