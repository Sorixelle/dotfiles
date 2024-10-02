{
  writeScriptBin,
  powershell,
  bash,
  libnotify,
  grimblast,
  hyprland,
  wl-clipboard,
}:

let
  grimblast-cmd = "${grimblast}/bin/grimblast";
  hyprctl = "${hyprland}/bin/hyprctl";
  notify-send = "${libnotify}/bin/notify-send";
  # shadower-cmd = "${shadower}/bin/shadower";
  wl-copy = "${wl-clipboard}/bin/wl-copy";
in
writeScriptBin "scr" ''
  #!${powershell}/bin/pwsh

  Param(
      [Parameter(Mandatory, HelpMessage="What region of the screen to capture. Valid options are Screen, Active and Selection.")]
      [ValidateSet("Screen", "Active", "Selection")]
      [string]$Mode,

      [Parameter(HelpMessage="Copies the image to the clipboard. If false, saves the screenshot to the images dir.")]
      [switch]$Clipboard = $false
    )

    $ActionName = If ($Clipboard) {"Copied"} Else {"Saved"}
    $OutPath = ""

    If ($Mode -eq "Active") {
        $Radius = (${hyprctl} -j getoption decoration:rounding | ConvertFrom-Json).int

        $OutPath = If ($Clipboard) {""} Else {
            $Date = Get-Date -Format "o"
            "$env:XDG_PICTURES_DIR/$Date\.png"
        }
        # BUG: shadower currently broken
        # $Args = If ($Clipboard) {"| ${wl-copy}"} Else {"-o $OutPath"}
        $Args = If ($Clipboard) {"- | ${wl-copy}"} Else {"$OutPath"}

        # bash -c "${grimblast-cmd} save active - | {shadower-cmd} -r $Radius -c 0x00000070 $Args"
        bash -c "${grimblast-cmd} save active $Args"
    } Else {
        $Action = If ($Clipboard) {"copy"} Else {"save"}
        $Target = If ($Mode -eq "Screen") {"output"} Else {"area"}

        $OutPath = ${grimblast-cmd} $Action $Target
    }

    ${notify-send} -a "Screenshot" "$ActionName!" $OutPath
''
