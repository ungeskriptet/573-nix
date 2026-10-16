{
  lib,
  stdenv,
  fetchFromCodeberg,
  cmake,
  libarchive,
  mitm-cache,
  ninja,
  wget,
  targets ? [ ],
  files ? { },
}:
assert targets != [ ];
assert files != { };
stdenv.mkDerivation (finalAttrs: {
  pname = "spice2x";
  version = "0.2.4_2026-02-17";

  src = fetchFromCodeberg {
    owner = "nixac";
    repo = "spicetools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9CjSy4MNXGl/hrZeugbWKUSm64MxWGKkwGa7e2aePIM=";
  };

  mitmCache = mitm-cache.fetch {
    name = "${finalAttrs.pname}-deps";
    data = {
      "https://web.archive.org/web/20260212204718if_/https://download.zip.dll-files.com/d01cab97ad497201c4ad99eb6e4182b3/dsdmo.zip?token=f7cVie5KOSz-hnFUYC37Ow&expires=1770974229".hash =
        "sha256-gVnzFFKm6FE4MOemlul3mZq9WgL4tFzclZ406M839n0=";
      "https://web.archive.org/web/20260212203516if_/https://download.zip.dll-files.com/2627c69b89807078f5fdf63ee104dddf/dsdmo.zip?token=1rLcDAA2LFA6YRyinX0GXg&expires=1770973374".hash =
        "sha256-rwBwAo60BTD4wf0U6DVqAc2nksVz81qeJ7NKwMIaCHo=";
    };
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    libarchive
    mitm-cache
    ninja
    wget
  ];

  ninjaFlags = targets;

  postPatch = ''
    substituteInPlace overlay/windows/config.cpp \
      --replace-fail \
      "ImGui::TextColored(ImVec4(1.f, 0.7f, 0, 1), cat.c_str());" \
      "ImGui::TextColored(ImVec4(1.f, 0.7f, 0, 1), \"%s\", cat.c_str());"
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
