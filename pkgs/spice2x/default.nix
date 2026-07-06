{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libarchive,
  ninja,
  wget,
  targets ? [ ],
  files ? { },
}:
assert targets != [ ];
assert files != { };
stdenv.mkDerivation (finalAttrs: {
  pname = "spice2x";
  version = "26-06-28";

  src = fetchFromGitHub {
    owner = "spice2x";
    repo = "spice2x.github.io";
    tag = finalAttrs.version;
    hash = "sha256-JXelO/qNqWaxgwh0CNHiFYp9aVsk+H/cWsVorPD0mec=";
  };

  sourceRoot = "${finalAttrs.src.name}/src/spice2x";

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    libarchive
    ninja
    wget
  ];

  ninjaFlags = targets;

  postPatch = ''
    substituteInPlace hooks/lang.cpp \
      --replace-fail \
      "_WIN32_WINNT 0x0600" \
      "_WIN32_WINNT 0x0601"
  '';

  installPhase = ''
    runHook preInstall
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (src: dst: ''
        mkdir -p $(dirname $out/${dst})
        cp ${src} $out/${dst}
      '') files
    )}
    runHook postInstall
  '';

  __structuredAttrs = true;
})
