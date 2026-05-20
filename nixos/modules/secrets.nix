{ ... }:

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
    };
  };
}
