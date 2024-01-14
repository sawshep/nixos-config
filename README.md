# NixOS Config

## Installation
To use: Generate configuration.nix and hardware-configuration.nix to your
liking. Rename configuration.nix to something logical and create a symlink to
configuration.nix. Initialize a Git repo: `git init .` in your NiXOS config
directory, set a remote origin with `git remote add origin
https://github.com/sawshep/nixos-config`, then finally `git pull origin
master`. Commit and push any changes.

## Guidelines

* Each Nix file in the root directory corresponds to a system. Server is the
  server, workstation is the workstation, etc.
* Each hardware configuration corresponds to a piece of hardware. Workstation
  imports desktop, laptop imports the specific model, etc.
