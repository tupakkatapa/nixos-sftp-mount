{ lib, config, ... }:
let
  cfg = config.services.sftpServer;
in
{
  options.services.sftpServer = {
    enable = lib.mkEnableOption "Whether to enable the SFTP server";

    dataDir = lib.mkOption {
      type = lib.types.str;
      description = "Data directory for the SFTP server.";
      example = "/mnt/wd-red/sftp";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra groups for the SFTP user.";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of authorized SSH keys for the SFTP user.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      allowSFTP = true;
      extraConfig = ''
        Match User sftp
          AllowTcpForwarding no
          ChrootDirectory %h
          ForceCommand internal-sftp
          PermitTunnel no
          X11Forwarding no
        Match all
      '';
    };

    users.users."sftp" = {
      createHome = true;
      isSystemUser = true;
      useDefaultShell = false;
      group = "sftp";
      extraGroups = [ "sshd" ] ++ cfg.extraGroups;
      home = cfg.dataDir;
      homeMode = "770";
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
    users.groups."sftp" = { };
  };
}

