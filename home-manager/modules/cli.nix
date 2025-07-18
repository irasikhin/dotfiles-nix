# Manages Command Line Interface tools
{ pkgs, ... }: {
  home.packages = with pkgs; [
    htop unzip zip git lazygit bat fzf ripgrep jq tree eza coreutils-prefixed fd
    cloc bc lshw gparted parted feh imagemagick sshpass oath-toolkit yamllint
    qrencode httpie skopeo nmap sops age aria2 proxychains speedtest-cli p7zip
    xarchiver tflint nixfmt-rfc-style treefmt nil ytt dive podman-tui autoconf
    gnumake graphviz pandoc file gcc autossh clang-tools python3 nodejs clang
    zig go-task maven cargo pnpm ansible_2_17 quarkus kind
    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [ helm-diff helm-secrets helm-s3 ];
    })
    helmfile kubectl kustomize jira-cli-go opentofu terragrunt
    openapi-generator-cli nh npins mergiraf
  ];

  home.shellAliases = { l = "eza"; ls = "eza"; cat = "bat"; };
}
