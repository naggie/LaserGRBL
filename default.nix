{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "lasergrbl";
  version = "unstable-2024-12-11";

  src = ./.;

  nativeBuildInputs = with pkgs; [
    mono
    msbuild
  ];

  buildInputs = with pkgs; [
    mono
  ];

  # Configure mono environment for the build
  configurePhase = ''
    runHook preConfigure

    # Set up mono paths
    export MONO_PATH="${pkgs.mono}/lib/mono/4.5"
    export FrameworkPathOverride="${pkgs.mono}/lib/mono/4.5"
    
    # Create necessary directories
    mkdir -p LaserGRBL/bin/Release

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Build using MSBuild
    # Use /p:TargetFrameworkVersion=v4.0 to ensure compatibility
    # Disable post-build events as they may fail in sandboxed build
    msbuild LaserGRBL.sln \
      /p:Configuration=Release \
      /p:Platform="Any CPU" \
      /p:TargetFrameworkVersion=v4.0 \
      /p:RunPostBuildEvent=None \
      /t:Build \
      /verbosity:minimal \
      /maxcpucount:''${NIX_BUILD_CORES:-1}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Create output directory structure
    mkdir -p $out/bin
    mkdir -p $out/lib/lasergrbl
    mkdir -p $out/share/lasergrbl
    
    # Copy the compiled executable and dependencies
    if [ -d LaserGRBL/bin/Release ]; then
      cp -r LaserGRBL/bin/Release/* $out/lib/lasergrbl/
    else
      echo "Error: Build output directory not found"
      exit 1
    fi
    
    # Ensure the main executable exists
    if [ ! -f $out/lib/lasergrbl/LaserGRBL.exe ]; then
      echo "Error: LaserGRBL.exe not found after build"
      exit 1
    fi
    
    # Copy resource files (these are marked as CopyToOutputDirectory in .csproj)
    # These files are required for proper operation
    if [ -f LaserGRBL/StandardButtons.zbn ]; then
      cp LaserGRBL/StandardButtons.zbn $out/lib/lasergrbl/
    else
      echo "Warning: StandardButtons.zbn not found"
    fi
    
    if [ -f LaserGRBL/StandardMaterials.psh ]; then
      cp LaserGRBL/StandardMaterials.psh $out/lib/lasergrbl/
    else
      echo "Warning: StandardMaterials.psh not found"
    fi
    
    # Copy optional directories if they exist
    # Firmware directory (optional, for flashing functionality)
    if [ -d LaserGRBL/Firmware ]; then
      cp -r LaserGRBL/Firmware $out/lib/lasergrbl/
    fi
    
    # Autotrace directory (optional, for advanced features)
    if [ -d LaserGRBL/Autotrace ]; then
      cp -r LaserGRBL/Autotrace $out/lib/lasergrbl/
    fi
    
    # Create wrapper script that sets up the environment
    cat > $out/bin/lasergrbl <<'EOF'
#!/bin/sh
# LaserGRBL wrapper script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
LIB_DIR="$SCRIPT_DIR/../lib/lasergrbl"

# Set mono environment
export MONO_PATH="${pkgs.mono}/lib/mono/4.5"

# Change to library directory so relative paths work
cd "$LIB_DIR"

# Run LaserGRBL
exec ${pkgs.mono}/bin/mono "$LIB_DIR/LaserGRBL.exe" "$@"
EOF
    
    chmod +x $out/bin/lasergrbl

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Laser engraving software for GRBL";
    longDescription = ''
      LaserGRBL is a Windows GUI for GRBL. Unlike other GUI, LaserGRBL is
      specifically developed for use with laser cutter and engraver.
      In order to use all of LaserGRBL features, your engraver must support
      laser power modulation through gcode "S" command.
      
      This package runs LaserGRBL using Mono on Linux.
    '';
    homepage = "https://lasergrbl.com";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "lasergrbl";
  };
}
