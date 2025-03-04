{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, ... }: {
    nixosModules = {
      sftpMount = import ./module.nix;
      default = self.nixosModules.sftpMount;
    };
  };
}
