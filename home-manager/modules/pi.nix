{
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  llm-agents = inputs.llm-agents.packages.${system};
  pi-pack = inputs.pi-pack.lib;
in
{
  # pi (AI coding agent) and dsh (deepseek-harness), both packaged upstream in
  # llm-agents.nix so they share a single versioned source. pi is also pulled
  # transitively by pi-pack, but keeping it explicit here documents the intent.
  home.packages = [
    llm-agents.pi
    llm-agents.dsh
  ];

  # Declarative DeepSeek model list. pi's baked catalog only advertises
  # `deepseek-flash` and `deepseek-v4-pro`, while api.deepseek.com also
  # accepts the legacy `deepseek-chat`/`deepseek-reasoner` names and the
  # experimental `deepseek-v4-flash-vision-exp` id (all verified against the
  # /chat/completions endpoint). Listing them here keeps the whole DeepSeek
  # lineup visible in `/model` across pi updates.
  home.file.".pi/agent/models.json".source = ../pi/models.json;

  # pi-pack resources (extensions/skills/prompts/themes) into ~/.pi/agent/.
  programs.pi-pack = {
    enable = true;
    # All resources by default; trim here to opt out of a specific extension or
    # skill (dependency packages follow via the module's resourcePackages map).
    inherit (pi-pack)
      extensions
      skills
      prompts
      themes
      ;
  };
}
