{ lib, rustPlatform, fetchFromGitHub, pkg-config, ffmpeg_8, python3, discord }:

rustPlatform.buildRustPackage {
  pname = "discord-stream-codec";
  version = "0.1.0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "skyline69";
    repo = "discord-stream-fix";
    rev = "a72fe5a5311e1bec66630a1f2ba981a9baf3cd44";
    hash = "sha256-vD90TRoi2Q08Byeu1FDLPu1Wsqhqz5HJWqKiCYUGGkw=";
  };
  cargoHash = "sha256-gsjPXDikhTdskRd8l2J3xXCKFizjONOU9i4eSyr3dVQ=";

  nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];
  buildInputs = [ ffmpeg_8 ];
  cargoBuildFlags = [ "--lib" "--bin" "decoder_check" ];
  # Upstream tests assume Fedora paths and silently skip on NixOS.
  doCheck = false;

  postPatch = ''
    # Keep Discord's embedded FFmpeg ABI separate from the system decoder.
    substituteInPlace src/lib.rs \
      --replace-fail 'c"libavcodec.so.62"' 'c"${ffmpeg_8.lib}/lib/libavcodec.so.62"'
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 target/*/release/libdiscord_stream_fix.so \
      "$out/lib/libdiscord_stream_fix.so"
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ ffmpeg_8 python3 ];
  installCheckPhase = ''
    runHook preInstallCheck
    # Match the non-macroblock-aligned stream size that exposed the corruption.
    ffmpeg -v error -f lavfi -i testsrc2=size=1106x718:rate=30 \
      -t 0.5 -c:v libx264 -preset medium -tune zerolatency \
      -profile:v high -x264-params aud=1 -f h264 input.h264
    python3 - <<'PY'
    import struct
    from pathlib import Path
    data = Path("input.h264").read_bytes()
    marker = b"\0\0\0\1\x09"
    positions = [i for i in range(len(data)) if data.startswith(marker, i)]
    assert positions, "missing H.264 access units"
    with open("packets", "wb") as output:
        for start, end in zip(positions, positions[1:] + [len(data)]):
            packet = data[start:end]
            output.write(struct.pack("<I", len(packet)))
            output.write(packet)
    PY
    target/*/release/decoder_check \
      ${discord}/opt/Discord/libffmpeg.so \
      "$out/lib/libdiscord_stream_fix.so" packets decoded.yuv
    ffmpeg -v error -i input.h264 -f rawvideo -pix_fmt yuv420p reference.yuv
    cmp decoded.yuv reference.yuv
    runHook postInstallCheck
  '';

  meta = {
    description = "Native FFmpeg H.264 decoding behind Discord's OpenH264 interface";
    homepage = "https://github.com/skyline69/discord-stream-fix";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
