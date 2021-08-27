{
  mkDerivation,
  fetchpatch, extra-cmake-modules,
  frameworkintegration, kcmutils, kconfigwidgets, kcoreaddons, kdecoration,
  kguiaddons, ki18n, kwayland, kwindowsystem, plasma-framework, qtdeclarative,
  qtx11extras, fftw
}:

mkDerivation {
  name = "breeze-qt5";
  sname = "breeze";
  nativeBuildInputs = [ extra-cmake-modules ];
  propagatedBuildInputs = [
    frameworkintegration kcmutils kconfigwidgets kcoreaddons kdecoration
    kguiaddons ki18n kwayland kwindowsystem plasma-framework qtdeclarative
    qtx11extras fftw
  ];
  outputs = [ "bin" "dev" "out" ];
  cmakeFlags = [ "-DUSE_Qt4=OFF" ];

  patches = [
    # https://bugs.kde.org/show_bug.cgi?id=436473
    (fetchpatch {
      url = "https://invent.kde.org/plasma/breeze/-/commit/f99b7ef621c9c69544158d245699fd8104db6753.patch";
      sha256 = "1dd4qa56md39w9nz3vih2dqpbycvm9cvd4iqw7zi7qh64jzxhb47";
    })
  ];
}
