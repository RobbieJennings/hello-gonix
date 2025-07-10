{
  description = "A Nix flake for a GO devshell, package and Docker image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "i686-linux"
        "aarch64-linux"
      ];
      pkgs = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        default = pkgs.${system}.buildGoModule {
          pname = "hello";
          version = "0.1.0";
          src = ./.;
          vendorHash = null;
        };

        dockerImage = pkgs.${system}.dockerTools.buildImage {
          name = "hello";
          tag = "latest";
          copyToRoot = pkgs.${system}.buildEnv {
            name = "image-root";
            paths = [ self.outputs.packages.${system}.default ];
            pathsToLink = [ "/bin" ];
          };
          config = {
            Cmd = [ "${self.outputs.packages.${system}.default}/bin/hello" ];
            ExposedPorts = {
              "8080/tcp" = { };
            };
          };
        };
      });

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShell {
          buildInputs = with pkgs.${system}; [
            go
            go-tools
            git
          ];
          shellHook = ''
            echo "Welcome to your Go development shell!"
          '';
        };
      });
    };
}
