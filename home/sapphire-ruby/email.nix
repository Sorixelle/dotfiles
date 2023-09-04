{ config, pkgs, ... }:

{
  programs.mbsync.enable = true;

  accounts.email = {
    maildirBasePath = "mail";
    accounts = {
      ruby-srxl = rec {
        address = "ruby@srxl.me";
        realName = "Ruby Iris Juric";
        gpg.key = "B6D7116C451A5B41";
        primary = true;

        userName = address;
        passwordCommand =
          "${config.programs.gpg.package}/bin/gpg --quiet --decrypt --armor /home/ruby/.email-password";
        imap = {
          host = "imap.migadu.com";
          port = 993;
        };
        smtp = {
          host = "smtp.migadu.com";
          port = 465;
        };

        imapnotify = {
          enable = true;
          boxes = [ "Inbox" "info-gnu-emacs" "qubes-announce" ];
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

  programs.msmtp.enable = true;

  services.imapnotify.enable = true;

  srxl.emacs = {
    mu4e = {
      enable = true;
      address = "ruby@srxl.me";
    };

    extraConfig = let smtp = config.accounts.email.accounts.ruby-srxl.smtp;
    in ''
      (setq mu4e-maildir-shortcuts '((:maildir "/Inbox" :key ?i :name "Inbox")
                                     (:maildir "/info-gnu-emacs" :key ?e :name "Emacs Info")
                                     (:maildir "/qubes-announce" :key ?q :name "Qubes Info")
                                     (:maildir "/Receipts" :key ?r :name "Receipts" :hide t)))

      (setq smtpmail-smtp-server "${smtp.host}"
            smtpmail-smtp-service ${toString smtp.port}
            smtpmail-stream-type 'ssl)
    '';
  };
}
