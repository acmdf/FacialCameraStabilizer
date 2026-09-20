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
              pkgs.buildDotnetModule (finalAttrs: {

                src = pkgs.fetchFromGitHub {
                  owner = "acmdf";
                  repo = "FacialCameraStabilizer";
                  rev = "3e57ef29588d6651dbdde91d49286f045d049979";
                  hash = "sha256-cSbGrikj5Jpmh80M3AoRu3h83IV6GGvWjrjMq8MhH4Y=";
                  fetchSubmodules = true;
                };

                version = "0.0.1.0";
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
