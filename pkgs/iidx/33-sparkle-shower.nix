{ stdenvNoCC, requireFile }:
stdenvNoCC.mkDerivation {
  pname = "iidx";
  version = "33-sparkle-shower";

  src =
    let
      name = "LDJ-012-2026011300";
    in
    requireFile {
      inherit name;
      hash = "sha256-VsxEGB3KxGpADzyyNClD83pLg9UqR5rUMEocsAitq+w=";
      hashMode = "recursive";
      message = ''
        Please download ${name} manually and add it
        to the nix store afterwards:
        nix store add ${name}
      '';
    };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r {.*,*} $out
    runHook postInstall
  '';
}
