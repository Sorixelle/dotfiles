{
  config,
  lib,
  pkgs,
  ...
}:

{
  options =
    let
      inherit (lib) types mkOption mkEnableOption;
    in
    {
      srxl.email = {
        enable = mkEnableOption "configuration for accessing and synchronizing my email";

        watchFolders = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "List of mail folders for imapnotify to watch.";
        };

        mu4eShortcuts =
          let
            shortcutType = types.submodule {
              options = {
                name = mkOption {
                  type = types.str;
                  description = "The name of the shortcut to show in mu4e.";
                };
                folder = mkOption {
                  type = types.str;
                  description = "The maildir folder the shortcut is assigned to.";
                };
                key = mkOption {
                  type = types.str;
                  description = "The key that triggers the shortcut.";
                };
                hidden = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether to hide the shortcut on the mu4e main menu.";
                };
              };
            };
          in
          mkOption {
            type = types.listOf shortcutType;
            default = [ ];
            description = "A list of shortcuts to create within mu4e, if Emacs is setup.";
          };
      };
    };

  config =
    let
      conf = config.srxl.email;
    in
    lib.mkIf conf.enable {
      accounts.email = {
        maildirBasePath = lib.mkDefault "mail";
        accounts = {
          ruby-srxl = rec {
            address = "ruby@srxl.me";
            aliases = [ "ruby@isincredibly.gay" ];
            realName = "Ruby Iris Juric";
            gpg.key = "B6D7116C451A5B41";
            primary = true;

            userName = address;
            passwordCommand = "${pkgs.libsecret}/bin/secret-tool lookup email ruby@srxl.me";
            imap = {
              host = "shadow.mxrouting.net";
              port = 993;
            };
            smtp = {
              host = "shadow.mxrouting.net";
              port = 465;
            };

            imapnotify = {
              enable = true;
              boxes = [ "Inbox" ] ++ conf.watchFolders;
              onNotify = "${pkgs.isync}/bin/mbsync ruby-srxl";
              onNotifyPost = "${pkgs.mu}/bin/mu index";
            };

            mbsync = {
              enable = true;
              create = "both";
              expunge = "both";
            };
            msmtp.enable = true;
            mu.enable = true;
          };
        };
      };

      programs = {
        mbsync.enable = true;
        msmtp.enable = true;
        mu.enable = true;
      };

      services.imapnotify.enable = true;

      srxl.emacs = {
        emailAddress = "ruby@srxl.me";

        extraConfig =
          let
            smtp = config.accounts.email.accounts.ruby-srxl.smtp;

            defaultShortcuts = [
              {
                name = "Inbox";
                folder = "/ruby-srxl/Inbox";
                key = "i";
                hidden = false;
              }
              {
                name = "Receipts";
                folder = "/ruby-srxl/Receipts";
                key = "r";
                hidden = true;
              }
            ];
            mu4eShortcuts = lib.concatStringsSep "\n" (
              builtins.map (
                s:
                ''(:maildir "${s.folder}" :key ?${s.key} :name "${s.name}" :hide ${
                  if s.hidden then "t" else "nil"
                })''
              ) (defaultShortcuts ++ conf.mu4eShortcuts)
            );
          in
          ''
            (setq mu4e-maildir-shortcuts '(${mu4eShortcuts}))

            (setq smtpmail-smtp-server "${smtp.host}"
                  smtpmail-smtp-service ${toString smtp.port}
                  smtpmail-stream-type 'ssl)
          '';
      };
    };
}
