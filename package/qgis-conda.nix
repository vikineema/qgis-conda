{
  pkgs,
  micromambaShellPkg,
  qgisVersion,
  ...
}:
let
  qgisBin = pkgs.writeShellScriptBin "qgis-conda" ''
    # Ensures the environment exists safely inside the FHS bubble
    ${micromambaShellPkg}/bin/micromamba-shell -c "
      if [ ! -d \"\$MAMBA_ROOT_PREFIX/envs/qgis-conda-env\" ]; then
        echo 'Initializing QGIS environment...'
        micromamba create -y -n qgis-conda-env -c conda-forge qgis==${qgisVersion}
        echo 'QGIS environment created successfully.'
      fi
    "

    # Launches the app by feeding the activation and exec commands into micromamba-shell
    exec ${micromambaShellPkg}/bin/micromamba-shell -c "micromamba activate qgis-conda-env && exec qgis \"\$@\""
  '';

  # Create a desktop item for QGIS Ltr because nix pkgs makes the same item
  # for both QGIS stable and ltr
  desktopItem = pkgs.makeDesktopItem {
    type = "Application";
    name = "org.qgis.qgis-conda";
    desktopName = "QGIS (Conda)";
    genericName = "Geographic Information System";
    icon = "qgis";
    tryExec = "${qgisBin}/bin/qgis-conda";
    exec = "${qgisBin}/bin/qgis-conda %F";
    terminal = false;
    # This tells standard launchers not to trigger feedback
    startupNotify = false;
    categories = [
      "Qt"
      "Education"
      "Science"
      "Geography"
    ];
    keywords = [
      "map"
      "globe"
      "postgis"
      "wms"
      "wfs"
      "ogc"
      "osgeo"
    ];
    startupWMClass = "qgis";
    mimeTypes = [
      "application/x-qgis-project"
      "application/x-qgis-project-container"
      "application/x-qgis-layer-settings"
      "application/x-qgis-layer-definition"
      "application/x-qgis-composer-template"
      "image/tiff"
      "image/jpeg"
      "image/jp2"
      "application/x-raster-aig"
      "application/x-raster-ecw"
      "application/x-raster-mrsid"
      "application/x-mapinfo-mif"
      "application/x-esri-shape"
      "application/vnd.google-earth.kml+xml"
      "application/vnd.google-earth.kmz"
      "application/geopackage+sqlite3"
    ];
  };

in
pkgs.symlinkJoin {
  name = "qgis-conda";
  paths = [
    qgisBin
    desktopItem
  ];
}
