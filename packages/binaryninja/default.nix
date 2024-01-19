{ 
  stdenv, autoPatchelfHook, makeWrapper, unzip, requireFile, python3, libGL, zlib, 
  xcbutilwm, xcbutilimage, xcbutilkeysyms, xcbutilrenderutil, libxkbcommon, freetype,
  fontconfig, wayland-scanner, dbus,
  ... 
}:

stdenv.mkDerivation {
  name = "binaryninja";

  src = requireFile {
    name = "BinaryNinja-dev.zip";
    url = "https://binary.ninja";
    sha256 = "188azn87c9m7zwsklklqjbza7kaa0jgcsk7nb4byirkcxj07zwla";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  # error: auto-patchelf could not satisfy dependency libGL.so.1 
  # error: auto-patchelf could not satisfy dependency libz.so.1 
  # error: auto-patchelf could not satisfy dependency libfreetype.so.6 
  buildInputs = [
    dbus
    libGL             # libGL.so.1
    stdenv.cc.cc.lib  # libstdc++.so.6
    zlib              # libz.so.1
    xcbutilwm         # libxcb-icccm.so.4
    xcbutilimage      # libxcb-image.so.4
    xcbutilkeysyms    # libxcb-keysyms.so.1
    xcbutilrenderutil # libxcb-render-util.so.0
    libxkbcommon      # libxkbcommon.so.0
    freetype          # libfreetype.so.6  
    fontconfig.lib
    wayland-scanner.out
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6Qml.so.6"
    "libQt6Widgets.so.6"
    "libQt6PrintSupport.so.6"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r * $out/opt
    chmod +x $out/opt/binaryninja

    mkdir -p $out/bin
    makeWrapper $out/opt/binaryninja $out/bin/binaryninja

    runHook postInstall
  '';

  meta = {
    platforms = [ "x86_64-linux" ];
  };
}
