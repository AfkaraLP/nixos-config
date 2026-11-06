{ lib, stdenv, kernel, kernelModuleMakeFlags }:

stdenv.mkDerivation {
  pname = "btusb-rtl8761bu";
  version = kernel.version;
  src = kernel.src;

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  unpackPhase = ''
    runHook preUnpack
    mkdir source
    tar -xf "$src" -C source --strip-components=3 \
      linux-${kernel.version}/drivers/bluetooth
    sourceRoot=source
    runHook postUnpack
  '';

  patches = [
    ./btusb-rtl8761bu-scan.patch
    ./btusb-event-ordering.patch
  ];

  buildPhase = ''
    runHook preBuild
    make ${lib.escapeShellArgs kernelModuleMakeFlags} \
      --eval='undefine src' --eval='undefine modules' \
      -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M="$PWD" btusb.ko
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 btusb.ko \
      "$out/lib/modules/${kernel.modDirVersion}/updates/btusb.ko"
    runHook postInstall
  '';

  meta = {
    description = "Bluetooth USB driver with upstream Realtek scan and event-ordering fixes";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
