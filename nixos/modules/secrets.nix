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

      # Encrypted SSH client config, split by context. Each file's `config`
      # key is a plaintext ssh_config block (organize environments as Host
      # sections inside). Rendered as symlinks into ~/.ssh/config.d/ and
      # pulled in via `Include config.d/*` in ~/.ssh/config. Sources of truth:
      # secrets/ssh/{home,work}.yaml. Matching private keys live in
      # keepass (group ssh/).
      ssh_home = {
        sopsFile = ../../secrets/ssh/home.yaml;
        key = "config";
        owner = "ir";
        mode = "0400";
        path = "/home/ir/.ssh/config.d/10-home";
      };
      ssh_work = {
        sopsFile = ../../secrets/ssh/work.yaml;
        key = "config";
        owner = "ir";
        mode = "0400";
        path = "/home/ir/.ssh/config.d/20-work";
      };

      kpass_config = {
        sopsFile = ../../secrets/kpass.yaml;
        key = "config";
        owner = "ir";
        mode = "0400";
        path = "/home/ir/.config/kpass/config.toml";
      };
    };
  };
}
