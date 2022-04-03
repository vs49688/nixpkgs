{ stdenv, lib, fetchgit, meson, ninja, pkg-config
, libdrm, mesa, cairo, udev, libinput, epoxy, gtk3
}:

stdenv.mkDerivation rec {
  pname = "drminfo";
  version = "8.1";

  src = fetchgit {
    url = "https://git.kraxel.org/git/drminfo";
    rev = "drminfo-8-1";
    sha256 = "084fy1ifjxhf2bb7qc78fx93vxvzy729b0hflkv0lx3bmwsp1593";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libdrm
    mesa # for libgbm
    cairo
    udev
    libinput
    epoxy
    gtk3
  ];

  meta = with lib; {
    description = "Some info / test tools for linux drm drivers (also fbdev)";
    homepage = "https://git.kraxel.org/cgit/drminfo/";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.zane ];
    platforms = platforms.linux;
  };
}
