{ ... }:

{
  programs.mbsync.enable = true;

  accounts.email = {
    maildirBasePath = "usr/mail";
    accounts = {
      "ruby@srxl.me" = rec {
        address = "ruby@srxl.me";
        realName = "Ruby Iris Juric";
        gpg.key = "B6D7116C451A5B41";
        primary = true;

        userName = address;
        # TODO: make this not suck balls
        passwordCommand = "cat ~/.email-password";
        imap = {
          host = "imap.migadu.com";
          port = 993;
        };
        smtp = {
          host = "smtp.migadu.com";
          port = 465;
        };

        mbsync = {
          enable = true;
          create = "both";
        };
        mu.enable = true;
      };
    };
  };

  srxl.emacs.mu4e = {
    enable = true;
    address = "ruby@srxl.me";
  };
}
