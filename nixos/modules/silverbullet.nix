_:

{
  # Self-hosted SilverBullet: markdown knowledge base served over HTTP.
  # Space lives in /var/lib/silverbullet; reachable from the machine itself
  # (or via `ssh -L 3000:localhost:3000 irnixos`) only.
  services.silverbullet = {
    enable = true;
    listenAddress = "127.0.0.1";
    listenPort = 3000;
  };
}
