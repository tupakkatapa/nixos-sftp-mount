
# SFTP-Mount

A straightforward NixOS module that lets you mount remote directories from an SFTP server. This simple approach ensures your data is always in one central location and seamlessly accessible on any device. For more context, see my blog post: [Home Directory at SFTP Server](https://blog.coditon.com).

---

## TL;DR

Want a single home directory accessible on any device?

1. **Server Setup**: On your server, create a dedicated SFTP user with chrooted access.
2. **Client Setup**: In your workstation’s `services.sftpMount.mounts`, map that entire home directory to a local mount point, e.g., `/mnt/remote-sftp`.
3. **Bind Key Folders**: Use the `binds` option to place key folders (e.g., `Pictures`, `Documents`) into your local home directory.
4. **Mobile Client Setup**: Use a file manager such as [FX File Explorer](https://play.google.com/store/apps/details?id=nextapp.fx) or [Cx File Explorer](https://play.google.com/store/apps/details?id=com.cxinventor.file.explorer) to connect to the SFTP.

---

## Getting Started

Add this repository as a Nix flake input, then enable the module in your NixOS configuration:

```nix
{
  inputs = {
    sftp-mount.url = "github:tupakkatapa/sftp-mount";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs: {
    nixosConfigurations = {
      yourhostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          inputs.sftp-mount.nixosModules.sftpMount

          # Module configuration
          {
            services.sftpMount = {
              enable = true;
              defaults = {
                identityFile = "/home/user/.ssh/id_ed25519";
                port = "22";
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
        ];
      };
    };
  };
}
```

### Usage

1. **Remote SFTP Mounts**
   Define each remote mount in `services.sftpMount.mounts`. Use `what` (e.g., `user@host:/path`) and `where` (local path). Toggle `autoMount` as needed.

2. **Local Bind Mounts**
   Reference subfolders on the remote SFTP path in `services.sftpMount.binds`. The module ensures bind mounts occur after the corresponding SFTP mount is available.

3. **Manual Mounting**
   If `autoMount = false`, you can mount and unmount manually. This is useful if SSH keys are not available at boot:
   ```bash
   sftp-mount
   sftp-unmount
   ```

4. **Identity & SSH Options**
   Override defaults like `identityFile` or `port`. The module appends any necessary SSHFS options automatically.
