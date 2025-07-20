
# NixOS SFTP Mount

A pair of complementary NixOS modules that let you set up an SFTP server or mount remote directories. The client module includes a bind mount functionality, allowing you to map remote subdirectories directly to local paths. This approach ensures your data is always in one central location and seamlessly accessible on any device.

For more context, see my blog post: [Home Directory at SFTP Server](https://blog.coditon.com/content/posts/Home%20Directory%20at%20SFTP%20Server.md).

## Getting Started

Add this repository as a Nix flake input, then enable either the `sftpServer` or `sftpClient` module in your NixOS configuration:

```nix
{
  inputs = {
    sftp-mount.url = "github:tupakkatapa/nixos-sftp-mount";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs: {
    nixosConfigurations = {
      yourhostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          inputs.sftp-mount.nixosModules.sftpClient
          {
            # Module configuration
            services.sftpClient = { ... };
          }
        ];
      };
    };
  };
}
```

## Module Configuration

### SFTP Server Module

This module simplifies SFTP server setup on your machine. It configures OpenSSH for SFTP access and creates a dedicated system user and group (sftp:sftp). The strict OpenSSH security settings, combined with the chrooted environment and the removal of the default shell, ensure that the SFTP user is properly isolated and does not have unnecessary access to the system. You can review the configuration at [nixosModules/sftpServer.nix](./nixosModules/sftpServer.nix).

Additionally, I advise disabling the `PasswordAuthentication` and `PermitRootLogin` to further enhance your server's security. Here are [my OpenSSH settings](https://github.com/tupakkatapa/nix-config/blob/4f71e1fcf53b0992a3b1e30c5ec9e11d581f7007/system/openssh.nix).

> **Tip**: Use a file manager such as [FX File Explorer](https://play.google.com/store/apps/details?id=nextapp.fx) or [Cx File Explorer](https://play.google.com/store/apps/details?id=com.cxinventor.file.explorer) to access the SFTP server via mobile.

#### Options
- **`enable`** - Enables the SFTP server.
- **`dataDir`** - Defines the SFTP server's data directory.
- **`authorizedKeys`** - A list of SSH keys allowed for authentication.
- **`extraGroups`** - Additional groups assigned to the SFTP user.

#### Example
```nix
{
  services.sftpServer = {
    enable = true;
    dataDir = "/mnt/sftp";
    authorizedKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    ];
  };
}
```

### SFTP Client Module

The client module allows you to mount remote directories locally using SSHFS, making remote filesystems accessible as if they were local. A key feature is the ability to bind specific subdirectories, such as `Documents`, `Pictures`, or `Downloads`, directly to the corresponding local paths, like your home directory. The module ensures bind mounts occur only after the corresponding SFTP mount is available.

#### Options
- **`enable`** - Enables the SFTP client.
- **`defaults.identityFile`** - Path to the SSH identity file.
- **`defaults.port`** - SSH port (default: `22`).
- **`defaults.autoMount`** - Whether to mount automatically.
- **`mounts`** - Defines remote directories to mount.
  - **`what`** - SFTP source (e.g., `user@host:/remote/path`).
  - **`where`** - Local mount point.
  - **`identityFile`** - Overrides `defaults.identityFile` for this mount.
  - **`port`** - Overrides `defaults.port` for this mount.
  - **`autoMount`** - Overrides `defaults.autoMount` for this mount.
- **`binds`** - Defines local bind mounts from remote directories.
  - **`what`** - Local path to bind from.
  - **`where`** - Local path to bind to.
  - **`autoMount`** - Overrides `defaults.autoMount` for this bind.

#### Example
```nix
{
  services.sftpClient = {
    enable = true;
    defaults = {
      identityFile = "/home/user/.ssh/id_ed25519";
      port = 22;
      autoMount = true;
    };
    mounts = [
      {
        what = "user@192.168.1.100:/";
        where = "/mnt/remote-sftp";
      }
    ];
    binds = [
      {
        what = "/mnt/remote-sftp/home/Pictures";
        where = "/home/user/Pictures";
      }
    ];
  };
}
```

#### Usage

The `sftp-mount` and `sftp-unmount` commands are available after enabling the module. These are useful when unexpected problems occur or when `autoMount = false` is configured. The latter should be set when SSH keys are not available at boot.

```
$ sudo sftp-mount
Mounting SFTP filesystems...
 -> Mounting /mnt/remote-sftp

Mounting bind filesystems...
 -> /home/user/Pictures

All done.
```
```
$ sudo sftp-unmount
Unmounting bind filesystems...
 -> /home/user/Pictures

Unmounting SFTP filesystems...
 -> /mnt/remote-sftp

All done.
```
