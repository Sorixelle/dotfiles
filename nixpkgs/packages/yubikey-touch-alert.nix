{
  writeShellApplication,
  coreutils,
  sway,
  yubikey-touch-detector,
}:

writeShellApplication {
  name = "yubikey-touch-alert";
  runtimeInputs = [
    coreutils
    sway
    yubikey-touch-detector
  ];

  text = ''
    ALERT_PID=""
    close_alert() {
      [ -n "$ALERT_PID" ] && { kill "$ALERT_PID" || true; }
      ALERT_PID=""
    }
    trap close_alert EXIT INT TERM

    yubikey-touch-detector -no-socket -stdout | while read -r L; do
      close_alert
      if [ "$(echo "$L" | cut -c5)" = "1" ]; then
        swaynag -t yubikey -m "Yubikey touch requested." 2>/dev/null &
        ALERT_PID="$!"
      fi
    done
  '';

  meta = {
    description = "Display alert when Yubikey touch is requested";
    longDescription = ''
      Creates an alert using swaynag to display a message prompting the user to touch their Yubikey.

      NOTE: swaynag is required to be in PATH when this script is executed.
    '';
  };
}
