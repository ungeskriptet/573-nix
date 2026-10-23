{
  stdenvNoCC,
  requireFile,
  writeShellScript,
  findutils,
}:
let
  message = name: ''
    Please download ${name} manually and add the
    content folder to the nix store afterwards.
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
      name = "LDJ-012-2026091600";
    in
    requireFile {
      inherit name;
      hash = "sha256-URpZM4WY3e/UTE/Rjf2Yga+WiXqQaoEBLlQ1jOS0XdM=";
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
  version = "34-zinrai";

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
