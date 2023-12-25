{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.shairport-sync;

  # This is based off the upstream versions, but they can't be used directly because
  # we allow customising the user.
  dbusPolicy = pkgs.writeTextDir "etc/dbus-1/system.d/shairport-sync-dbus-policy.conf" ''
    <!-- initial version, based on /etc/dbus-1/system.d/avahi-dbus.conf, with thanks -->
    <!DOCTYPE busconfig PUBLIC
              "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
              "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
    <busconfig>

      <!-- Allow users "root" and "${cfg.user}" to own the Shairport Sync services -->
      <policy user="root">
        <allow own="org.gnome.ShairportSync"/>
        <allow own="org.mpris.MediaPlayer2.ShairportSync"/>
      </policy>
      <policy user="${cfg.user}">
        <allow own="org.gnome.ShairportSync"/>
        <allow own="org.mpris.MediaPlayer2.ShairportSync"/>
      </policy>


      <!-- Allow anyone to invoke methods on Shairport Sync servers -->
      <policy context="default">
        <allow send_destination="org.gnome.ShairportSync"/>
        <allow receive_sender="org.gnome.ShairportSync"/>
        <allow send_destination="org.mpris.MediaPlayer2.ShairportSync"/>
        <allow receive_sender="org.mpris.MediaPlayer2.ShairportSync"/>
      </policy>

    </busconfig>
  '';

in

{

  ###### interface

  options = {

    services.shairport-sync = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Enable the shairport-sync daemon.

          Running with a local system-wide or remote pulseaudio server
          is recommended.
        '';
      };

      arguments = mkOption {
        type = types.str;
        default = "-v -o pa";
        description = lib.mdDoc ''
          Arguments to pass to the daemon. Defaults to a local pulseaudio
          server.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Whether to automatically open ports in the firewall.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "shairport";
        description = lib.mdDoc ''
          User account name under which to run shairport-sync. The account
          will be created.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "shairport";
        description = lib.mdDoc ''
          Group account name under which to run shairport-sync. The account
          will be created.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf config.services.shairport-sync.enable {

    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    users = {
      users.${cfg.user} = {
        description = "Shairport user";
        isSystemUser = true;
        createHome = true;
        home = "/var/lib/shairport-sync";
        group = cfg.group;
        extraGroups = [ "audio" ] ++ optional config.hardware.pulseaudio.enable "pulse";
      };
      groups.${cfg.group} = {};
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5000 ];
      allowedUDPPortRanges = [ { from = 6001; to = 6011; } ];
    };

    systemd.services.shairport-sync =
      {
        description = "shairport-sync";
        after = [ "network.target" "avahi-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${pkgs.shairport-sync}/bin/shairport-sync ${cfg.arguments}";
          RuntimeDirectory = "shairport-sync";
        };

        environment = {
          # Force to use system dbus.
          DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket";
        };
      };

    environment.systemPackages = [ pkgs.shairport-sync ];

    services.dbus.packages = [
      dbusPolicy
    ];

  };

}
