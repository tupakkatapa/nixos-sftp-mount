{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, treefmt-nix, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      treefmtFor = system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
        projectRootFile = "flake.nix";
        programs.nixpkgs-fmt.enable = true;
      };
    in
    {
      nixosModules = {
        sftpClient = import ./nixosModules/sftpClient.nix;
        sftpServer = import ./nixosModules/sftpServer.nix;
        default = self.nixosModules.sftpClient;
      };

      formatter = forAllSystems (system:
        (treefmtFor system).config.build.wrapper
      );
    };
}
