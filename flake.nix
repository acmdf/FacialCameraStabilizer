{
  description = "VRCX-0";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      pkgsFor = lib.genAttrs systems (system:
        import nixpkgs {
          localSystem.system = system;
        });
    in
    {
      packages =
        lib.mapAttrs
          (system: pkgs: {
            facialcamerastabilizer =
              let
                dotnet = pkgs.dotnetCorePackages.dotnet_10;
              in
              pkgs.buildDotnetModule (finalAttrs: rec {

                src = pkgs.fetchFromGitHub {
                  owner = "Sebane1";
                  repo = "FacialCameraStabilizer";
                  rev = "5ff4da6b9e786483e64d2fcb7e57b2a677df0646"; # refactor/avalonia
                  hash = "sha256-0P2eMqRHSpwz5iFS1K7J5o3qGwDJItT+IsNWPEUcClc=";
                  fetchSubmodules = true;
                };

                version = "5.4.5.0";
                pname = "facialcamerastabilizer";

                nugetDeps = ./nix/deps.json;
                dotnet-sdk = dotnet.sdk;
                dotnet-runtime = dotnet.runtime;
                executables = [
                  "FacialCameraStabilizer"
                ];
                projectFile = [
                  "FacialCameraStabilizer/FacialCameraStabilizer.csproj"
                ];

                nativeBuildInputs = with pkgs; [
                  autoPatchelfHook
                ];

                buildInputs = with pkgs; [
                  pkg-config
                  openssl
                  icu
                ];

                meta = {
                  platforms = lib.platforms.linux;
                  homepage = "https://github.com/Sebane1/FacialCameraStabilizer/";
                  description = "App to recieve camera data from facial cameras";
                  mainProgram = "FacialCameraStabilizer";
                };
              });

            default = self.packages.${system}.facialcamerastabilizer;
          })
          pkgsFor;

      devShells =
        lib.mapAttrs
          (system: pkgs: {
            default = pkgs.mkShell {
              inputsFrom = [ self.packages.${system}.facialcamerastabilizer ];
            };
          })
          pkgsFor;

      overlays.default = final: prev: { inherit (self.packages.${prev.system}) facialcamerastabilizer; };
    };
}
