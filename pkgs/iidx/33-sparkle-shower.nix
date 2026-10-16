{
  stdenvNoCC,
  requireFile,
  writeShellScript,
  findutils,
}:
let
  message = name: ''
    Please download ${name} manually and add it
    to the nix store afterwards:
    nix store add ${name}
  '';
  baseGame =
    let
      name = "LDJ-010-2026081900";
    in
    requireFile {
      inherit name;
      hash = "sha256-TuyYpvMts8WKFeK3Wo2U+rItp8HiSnP0YPMgyz6XeME=";
      hashMode = "recursive";
      message = message name;
    };
  patch =
    let
      name = "LDJ-010_2026090400";
    in
    requireFile {
      inherit name;
      hash = "sha256-EaOCKtQZj25Qnv6qi+HUOR90N03xfb0h67Dw5DXWZgg=";
      hashMode = "recursive";
      message = message name;
    };
  copyScript =
    drv:
    writeShellScript "copy-script" ''
      dir=$(dirname "$1")
      dir=''${dir#${drv}/*}/
      out="$2"/"$dir"
      mkdir -p "$out"
      ln -sf "$1" "$out"
    '';
in
stdenvNoCC.mkDerivation {
  pname = "iidx";
  version = "33-sparkle-shower";

  dontUnpack = true;
  dontFixup = true;

  nativeBuildInputs = [ findutils ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    find ${baseGame} -type f -exec ${copyScript baseGame} {} "$out" \;
    find ${patch} -type f -exec ${copyScript patch} {} "$out" \;
    runHook postInstall
  '';
}
