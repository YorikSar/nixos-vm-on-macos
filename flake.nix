{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      vm =
        { config, pkgs, lib, modulesPath, ... }:

        {
          imports = [
            "${modulesPath}/virtualisation/qemu-vm.nix"
          ];

          system.stateVersion = "22.05";

          # Configure networking
          networking.useDHCP = false;
          networking.interfaces.eth0.useDHCP = true;

          # Create user "test"
          services.getty.autologinUser = "test";
          users.users.test.isNormalUser = true;

          # Enable paswordless ‘sudo’ for the "test" user
          users.users.test.extraGroups = [ "wheel" ];
          security.sudo.wheelNeedsPassword = false;

          # Make it output to the terminal instead of separate window
          virtualisation.graphics = false;
        };
      withStoreImage = {
        virtualisation.useNixStoreImage = true;
        virtualisation.writableStore = true;
      };
    };
    nixosConfigurations = {
      vm-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.vm
          {
            virtualisation.host.pkgs = nixpkgs.legacyPackages.x86_64-darwin;
          }
        ];
      };
      vm-x86_64-storeImage = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.vm
          self.nixosModules.withStoreImage
          {
            virtualisation.host.pkgs = nixpkgs.legacyPackages.x86_64-darwin;
          }
        ];
      };
      vm-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.vm
          {
            virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          }
        ];
      };
      vm-aarch64-storeImage = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.vm
          self.nixosModules.withStoreImage
          {
            virtualisation.host.pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          }
        ];
      };
    };
    packages.x86_64-darwin.default = self.nixosConfigurations.vm-x86_64.config.system.build.vm;
    packages.x86_64-darwin.withStoreImage = self.nixosConfigurations.vm-x86_64-storeImage.config.system.build.vm;
    packages.aarch64-darwin.default = self.nixosConfigurations.vm-aarch64.config.system.build.vm;
    packages.aarch64-darwin.withStoreImage = self.nixosConfigurations.vm-aarch64-storeImage.config.system.build.vm;
  };

  nixConfig = {
    extra-substituters = [ "https://yoriksar-gh.cachix.org" ];
    extra-trusted-public-keys = [ "yoriksar-gh.cachix.org-1:YrztCV1unI7qDV6IXmiXFig5PgptqTlUa4MiobULGT8=" ];
  };
}
