{ stdenvNoCC, requireFile }:
stdenvNoCC.mkDerivation {
  pname = "ddr";
  version = "a20-plus";

  src =
    let
      name = "MDX-001-2022020200";
    in
    requireFile {
      inherit name;
      hash = "sha256-7SaURWpa3WqXlQJqPFXbaOiGjR34vxrxvXYWxItOHpE=";
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
