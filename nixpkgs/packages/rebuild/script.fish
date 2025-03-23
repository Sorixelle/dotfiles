#!/usr/bin/env fish

# Parse command-line arguments supported by this script, ignoring unknown ones
# The unknown arguments just get forwarded to the nixos-rebuild call
argparse -i h/help 'c/config=' 's/system=' -- $argv
or return

# If no config repo was passed, default to environment variable defined by system/modules/rebuild.nix
if test -z $_flag_config
    set _flag_config $REBUILD_CHECKOUT_PATH
end

if set -ql _flag_help
    echo "rebuild - Rebuild the NixOS configuration"
    echo ""
    echo "Usage: rebuild [-h] [-s system] [-c config] [args]"
    echo "Flags:"
    echo "  -h/--help: Display this help message"
    echo "  -c/--config: Path to the NixOS configuration repo (defaults to $REBUILD_CHECKOUT_PATH)"
    echo "  -s/--system: Name of the file in [config]/system to build (defaults to hostname)"
    echo ""
    echo "Examples:"
    echo "  Switch to the new configuration for this system:"
    echo "  rebuild"
    echo ""
    echo "  Test the configuration for this system in /etc/nixos, without creating a new generation:"
    echo "  rebuild -c /etc/nixos test"
    echo ""
    echo "  Build a virtual machine running the configuration for tanzanite:"
    echo "  rebuild -s tanzanite build-vm"
    exit 1
end

# If system flag not provided, default to hostname
if test -z $_flag_system
    set _flag_system (hostname)
end

# If no arguments were passed, default to running nixos-rebuild switch
if test (count $argv) -eq 0
    set -a argv switch
end

# Evaluate path to nixpkgs checkout in npins, to add to NIX_PATH
set -l pinned_nixpkgs (nix eval --raw -f "$_flag_config/npins" nixpkgs)

# If we're on macOS, we'll need to call darwin-rebuild, and nixos-rebuild for NixOS
switch (uname)
    case Darwin
        # Like Nixpkgs, get a path to the pinned nix-darwin
        set -l pinned_nix_darwin (nix eval --raw -f "$_flag_config/npins" nix-darwin)

        darwin-rebuild \
            # Show build logs (darwin-rebuild doesn't seem to work with nix-output-monitor, unfortunately)
            -L \
            # Tell darwin-rebuild where the system configuration to build lives
            -I "darwin-config=$_flag_config/system-darwin/$_flag_system.nix" \
            # Tell the build to use the pinned version of nixpkgs from npins
            -I "nixpkgs=$pinned_nixpkgs" \
            # And the pinned nix-darwin
            -I "darwin=$pinned_nix_darwin" \
            # Pass any extra arguments given to the rebuild
            $argv
    case '*'
        sudo nixos-rebuild \
            # Set log format to feed into nix-output-monitor
            --log-format internal-json -v \
            # Don't build nixos-rebuild and re-execute with it to speed up eval
            --no-reexec \
            # Tell nixos-rebuild where the system configuration to build lives
            -I "nixos-config=$_flag_config/system/$_flag_system.nix" \
            # Tell the build to use the pinned version of nixpkgs from npins
            -I "nixpkgs=$pinned_nixpkgs" \
            # Pass any extra arguments given to the rebuild, and show progress with nix-output-monitor
            $argv &| nom --json
end
