{
  lib,
  stdenv,
  fetchFromCodeberg,
  cmake,
  ffmpeg,
  git,
  libsndfile,
  pipewire,
  pkg-config,
  python3,
  wine64Packages,
  winePackages,
  nix-update-script,
}:
assert (!stdenv.hostPlatform.isx86_64 || !stdenv.hostPlatform.isx86_32);
let
  selectArch =
    _64bitOption: _32bitOption: if stdenv.hostPlatform.isx86_64 then _64bitOption else _32bitOption;
  arch = selectArch "x64" "x86";
  wine = selectArch wine64Packages.minimal winePackages.minimal;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bmsound";
  version = "0.2.4-unstable-2026-10-06";

  src = fetchFromCodeberg {
    owner = "nixac";
    repo = "bmsound_wine";
    rev = "213f4bc8becb944fe4b231caa88ae95e6d5ba53d";
    hash = "sha256-u4R+hEoBHkTnjoUDcw2BlKHTVkGuLuxxC+0FOcTdhh8=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    python3
    wine
  ];

  buildInputs = [
    ffmpeg
    libsndfile
    pipewire
  ];

  buildPhase = ''
    runHook preBuild
    ${lib.concatStringsSep " " [
      "make"
      "SHELL='${stdenv.shell} -O globstar'" # See ExtEnvironment.mk
      "build"
      "TARGET_ARCH=${arch}"
      "TARGET_TYPE=Release"
    ]}
    runHook postBuild
  '';

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mv bin/Release/${arch} $out
    runHook postInstall
  '';

  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
        "--version"
        "branch=master"
      ];
    };
  };
})
