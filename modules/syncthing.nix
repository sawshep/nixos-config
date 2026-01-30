let
  defaultSyncthingDevices = [ "NAS" "HP EliteBook 835 G7" "ASUSTeK" ];
  defaultVersioning = {
    type = "staggered";
    params = {
      cleanInterval = "3600";
      maxAge = "7776000";
    };
  };
  mkSyncFolder = path: {
    inherit path;
    devices = defaultSyncthingDevices;
    versioning = defaultVersioning;
  };
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = "/home/me";
    user = "me";
    group = "users";
    guiAddress = "localhost:8384";
    overrideFolders = true;
    settings = {
      devices = {
        "HP EliteBook 835 G7" = { id = "PDH4BFZ-4FU2BYM-XY2TZNM-YMC3D6Y-G6K2JYE-KKFFVBH-7NRQU55-KA6HNAX"; };
        "NAS" = { id = "TAESSIS-MV6E3ID-BNKTN7P-K36MHEP-YHF73BP-5OIN2Q7-U3BOCXC-7D6SUQ3"; };
        "ASUSTeK" = { id = "O2RXYBG-MXB3BJG-HDB4R5U-QBIMCPI-4BAHWJD-KRZ56HQ-TFGPDJA-MNKPLAM"; };
      };
      folders = {
        "Binaries"  = mkSyncFolder "~/bin";
        "Cyber"     = mkSyncFolder "~/cyber";
        "Desktop"   = mkSyncFolder "~/desk";
        "Documents" = mkSyncFolder "~/doc";
        "Downloads" = mkSyncFolder "~/down";
        "Music"     = mkSyncFolder "~/music";
        "Media"     = mkSyncFolder "~/media";
      };
    };
  };
}
