{
  description = "Flake for building the protoc-gen-es NPM package";

  inputs = {
    # Pulling the nixpkgs repository for the necessary Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ]; # List of systems you want to support
      forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        pkgs.buildNpmPackage rec {
          pname = "protoc-gen-connect-es";
          version = "1.4.0";

          src = pkgs.fetchFromGitHub {
            owner = "connectrpc";
            repo = "connect-es";
            rev = "refs/tags/v${version}";
            hash = "sha256-qCIwr4Hyc5PARUa7tMntuyWRmO6ognmtjxN0myo8FXc=";

            postFetch = ''
              ${pkgs.lib.getExe pkgs.npm-lockfile-fix} $out/package-lock.json
            '';
          };

          npmDepsHash = "sha256-OGwEpXZqzMSIES+cmseQlo6/vzkx5ztO0gM/rUB0tGY=";

          npmWorkspace = "packages/protoc-gen-connect-es";

          passthru.updateScript = ./update.sh;

          meta = with pkgs.lib; {
            description = "Protobuf plugin for generating Connect-ecompatiblenabled ECMAScript code";
            homepage = "https://github.com/connectrpc/connect-es";
            changelog = "https://github.com/connectrpc/connect-es/releases/tag/v${version}";
            license = licenses.asl20;
            maintainers = with maintainers; [
              felschr
              jtszalay
            ];
          };
        }
      );

      # The default package for 'nix build'.
      defaultPackage = forAllSystems (system: self.packages.${system});
    };
}

