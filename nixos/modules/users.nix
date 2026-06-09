{ pkgs, ... }:

{
  # Configure user accounts
  users.users.irasikhin = {
    isNormalUser = true;
    description = "Ivan Rasikhin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "qemu-libvirtd"
      "docker"
      "libvirtd"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh; # Set default shell to Zsh
  };
  users.users.ir = {
    isNormalUser = true;
    description = "ir";
    hashedPassword = "";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "qemu-libvirtd"
      "docker"
      "libvirtd"
      "irasikhin"
      "users"
    ];
    home = "/home/ir";

    packages = with pkgs; [ ];
    shell = pkgs.zsh; # Set default shell to Zsh
  };
  programs.zsh.enable = true;

  # VirtualBox user groups
  users.extraGroups.vboxusers.members = [
    "irasikhin"
    "ir"
  ];

  # Allow users in wheel group to execute sudo commands without password
  security.sudo.wheelNeedsPassword = false;
}
