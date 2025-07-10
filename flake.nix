{
  description = "A Nix flake for a GO devshell, package and Docker image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      goApp = pkgs.buildGoModule {
        pname = "hello";
        version = "0.1.0";

        src = ./.;
        vendorHash = null;

        modRoot = ".";
        subPackages = [ "." ];
      };

      dockerImage = pkgs.dockerTools.buildImage {
        name = "hello";
        tag = "latest";

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [ goApp ];
          pathsToLink = [ "/bin" ];
        };

        config = {
          Cmd = [ "${goApp}/bin/hello" ];
          ExposedPorts = {
            "8080/tcp" = {};
          };
        };
      };
    in
    {
      packages.${system} = {
        default = goApp;
        dockerImage = dockerImage;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ go go-tools git ];
        shellHook = ''
          echo "Welcome to your Go development shell!"
        '';
      };
    };
}
