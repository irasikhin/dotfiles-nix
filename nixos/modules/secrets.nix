_:

{
  # sops-nix: decrypts secrets at activation using the host's age key,
  # derived from the SSH ed25519 host key.
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Declared secrets are decrypted at runtime under /run/secrets/<name>.
    secrets = {
      example_secret = { };

      # gost upstream proxies — value is the full `PROXY_UPSTREAM=...` line
      # so systemd EnvironmentFile can read it directly.
      proxy_7777.owner = "ir";
      proxy_8888.owner = "ir";
      proxy_9999.owner = "ir";

      # Encrypted SSH client config for the external VPN servers (node-a,
      # node-b). Rendered to /run/secrets/ssh_managed_hosts (owner ir) and
      # pulled in via `Include /run/secrets/ssh_managed_hosts` in ~/.ssh/config.
      # Source of truth: secrets/ssh-hosts.yaml (key `config`). The matching
      # private key (vpn-admin-key) is backed up in keepass.
      ssh_managed_hosts = {
        sopsFile = ../../secrets/ssh-hosts.yaml;
        key = "config";
        owner = "ir";
        mode = "0400";
      };
    };
  };
}
