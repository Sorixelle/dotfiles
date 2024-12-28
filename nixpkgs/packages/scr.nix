{
  lib,
  writeScriptBin,

  powershell,

  libnotify,
  sway-contrib,
  wl-clipboard,
}:

writeScriptBin "scr" ''
  #!${lib.getExe powershell}

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
        $OutPath = If ($Clipboard) {""} Else {
            $Date = Get-Date -Format "o"
            "$env:XDG_PICTURES_DIR/$Date\.png"
        }

        # TODO: figure out why the shadower build is completely busted
        # $Args = If ($Clipboard) {"| ${wl-clipboard}/bin/wl-copy"} Else {"-o $OutPath"}
        # bash -c "${lib.getExe sway-contrib.grimshot} save active - | {lib.getExe shadower} -c 0x00000070 $Args"

        $Args = If ($Clipboard) {"- | ${wl-clipboard}/bin/wl-copy"} Else {"$OutPath"}
        bash -c "${lib.getExe sway-contrib.grimshot} save active $Args"
    } Else {
        $Action = If ($Clipboard) {"copy"} Else {"save"}
        $Target = If ($Mode -eq "Screen") {"output"} Else {"area"}

        $OutPath = ${lib.getExe sway-contrib.grimshot} $Action $Target
    }

    ${lib.getExe libnotify} -a "Screenshot" "$ActionName!" $OutPath
''
