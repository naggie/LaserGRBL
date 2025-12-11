# Building LaserGRBL with Nix

This repository includes Nix derivations for building LaserGRBL on Linux using Mono.

## Quick Start

### Using Nix Flakes (Recommended)

If you have flakes enabled:

```bash
# Build the project
nix build

# Run LaserGRBL directly
nix run

# Enter development shell
nix develop
```

### Using Traditional Nix

To build LaserGRBL using Nix:

```bash
nix-build
```

This will create a `result` symlink pointing to the built package.

### Running LaserGRBL

After building, you can run LaserGRBL with:

```bash
./result/bin/lasergrbl
```

### Installing

To install LaserGRBL to your Nix profile:

```bash
nix-env -f default.nix -i
```

Or with flakes:

```bash
nix profile install
```

Then you can run it directly:

```bash
lasergrbl
```

## Development

For development, you can enter a shell with all the necessary dependencies:

```bash
nix-shell
```

Or with flakes:

```bash
nix develop
```

This provides `mono`, `msbuild`, and other tools needed for building.

Within the shell, you can build manually:

```bash
msbuild LaserGRBL.sln /p:Configuration=Release
```

## Requirements

- Nix package manager (https://nixos.org/download.html)
- X11 display server (for GUI)
- For flakes: Enable flakes in your Nix configuration

## Notes

- LaserGRBL is a Windows Forms application running under Mono
- Some Windows-specific features may have limited functionality on Linux
- The application requires X11 to run (it won't work in a headless environment)
- The build includes Microsoft Core Fonts (unfree) and DejaVu fonts to handle font references in resource files
- **Unfree License**: This derivation uses Microsoft Core Fonts which are unfree. The derivation automatically enables unfree packages (`config.allowUnfree = true`)

## Troubleshooting

### Font Errors During Build

The build automatically includes necessary fonts (Microsoft Core Fonts, DejaVu fonts) for compiling resource files. The derivation:
- Enables unfree packages to allow Microsoft Core Fonts
- Configures fontconfig with proper cache directories
- Sets UTF-8 locale using `LOCALE_ARCHIVE` for proper character encoding
- Enables `MONO_IOMAP` for better cross-platform file handling
- Sets `MONO_EXTERNAL_ENCODINGS=UTF-8` to avoid Windows code page detection

If you still encounter font-related errors, ensure your Nix installation is up to date.

### Display Issues

If you encounter display issues, ensure you have X11 running:

```bash
echo $DISPLAY
```

### Missing Libraries

If you get library errors, you may need to install additional dependencies:

```bash
nix-shell -p xorg.libX11 xorg.libXext
```

### Flakes Not Enabled

To enable flakes, add this to your `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

## License

LaserGRBL is licensed under GPLv3. See LICENSE.md for details.
