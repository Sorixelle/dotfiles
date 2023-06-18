{ config, pkgs, ... }:

{
  programs.mbsync.enable = true;

  accounts.email = {
    maildirBasePath = "usr/mail";
    accounts = {
      ruby-srxl = rec {
        address = "ruby@srxl.me";
        realName = "Ruby Iris Juric";
        gpg.key = "B6D7116C451A5B41";
        primary = true;

        userName = address;
        passwordCommand =
          "${pkgs.gnupg}/bin/gpg --quiet --decrypt --armor /home/ruby/.email-password";
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
          boxes = [
            "Inbox"
            "emacs-orgmode"
            "help-gnu-emacs"
            "info-gnu-emacs"
            "mu-discuss"
          ];
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
      (setq mu4e-maildir-shortcuts
            '((:maildir "/Inbox" :key ?i :name "Inbox"
              (:maildir "/Receipts" :key ?r :name "Receipts" :hide-unread))))

      (setq smtpmail-smtp-server "${smtp.host}"
            smtpmail-smtp-service ${toString smtp.port}
            smtpmail-stream-type 'ssl)
    '';
  };
}
