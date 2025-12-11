{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    mono
    msbuild
    dotnet-sdk  # For additional .NET tooling if needed
  ];

  shellHook = ''
    echo "LaserGRBL development environment"
    echo "Mono version: $(mono --version | head -n1)"
    echo ""
    echo "To build the project:"
    echo "  msbuild LaserGRBL.sln /p:Configuration=Release"
    echo ""
    echo "Or use Nix to build:"
    echo "  nix-build"
  '';
}
