{
  pkgs,
  inputs,
  system,
  ...
}:

let
  pkgsHelm3 = import inputs.nixpkgs-helm3 { inherit system; };
  myHelm = pkgsHelm3.wrapHelm pkgsHelm3.kubernetes-helm {
    plugins = with pkgsHelm3.kubernetes-helmPlugins; [
      helm-diff
      helm-secrets
      helm-s3
    ];
  };
  myHelmfile = pkgs.helmfile.override {
    inherit (myHelm.passthru) pluginsDir;
  };
  taskwarriorAsTw = pkgs.runCommand "taskwarrior-tw" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.taskwarrior3}/bin/task $out/bin/tw
  '';
  postgresqlClient = pkgs.runCommand "postgresql-client-${pkgs.postgresql.version}" { } ''
    mkdir -p $out/bin
    for b in psql pg_dump pg_dumpall pg_restore pg_isready \
             createdb dropdb createuser dropuser \
             clusterdb reindexdb vacuumdb pgbench; do
      ln -s ${pkgs.postgresql}/bin/$b $out/bin/$b
    done
  '';
  express = pkgs.callPackage ../pkgs/express.nix {
    src = inputs.express-appimage;
  };
  yaamp = pkgs.callPackage ../pkgs/yaamp.nix { };
  ideaPlugins = inputs.nix-jetbrains-plugins.plugins.${system}.idea."${pkgs.jetbrains.idea.version}";
  ideaWithPlugins = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea (
    map (id: ideaPlugins.${id}) [
      "IdeaVIM"
      "org.jetbrains.IdeaVim-EasyMotion"
      "com.joshestein.ideavim-quickscope"
      "IdeaVimExtension"
      "AceJump"
      "eu.theblob42.idea.whichkey"
      "org.yelog.ideavim.flash"
      "com.github.dankinsoid.multicursor"
      "com.github.eig114.darkburn"
      "ru.adelf.idea.dotenv"
      "com.github.lonre.gruvbox-intellij-theme"
      "indent-rainbow.indent-rainbow"
      "izhangzhihao.rainbow.brackets.lite"
      "Lombook Plugin"
      "org.mapstruct.intellij"
      "nix-idea"
      "com.andrey4623.rainbowcsv"
      "com.github.smashedtoatoms.zenburn"
    ]
  );
in
{
  home.packages = with pkgs; [
    htop
    unzip
    zip
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.pandas
      python-pkgs.requests
      python-pkgs.click
      python-pkgs.pyyaml
      python-pkgs.jinja2
      python-pkgs.distlib
      python-pkgs.pykeepass
      ansible
    ]))
    nodejs
    clang
    zig
    gnumake
    git
    lua
    just
    lazygit
    lazydocker
    bat
    fzf
    ripgrep
    jq
    tree
    eza
    foot
    ghostty
    curl
    kitty
    chafa
    screen
    fd
    antigen
    docker
    zsh-autosuggestions
    pango
    fira-code
    nerd-fonts.fira-code
    pass
    passExtensions.pass-import
    bc
    wl-clipboard
    networkmanagerapplet
    maven
    telegram-desktop
    express
    yaamp
    font-awesome
    ideaWithPlugins
    acpi
    brightnessctl
    lshw
    pamixer
    brillo
    gparted
    parted
    bash
    swaybg
    swayidle
    swaylock-effects
    imagemagick
    openconnect
    networkmanager-openconnect
    networkmanager-vpnc
    spotify
    ansible
    go-task
    dig
    inetutils
    libreoffice
    cloc
    delta
    vscode
    zoom-us
    sshpass
    oath-toolkit
    yamllint
    postgresqlClient
    obsidian
    ticktick
    yq-go
    pnpm
    insomnia
    kubectl
    kustomize
    cointop
    quarkus
    qrencode
    httpie
    httpie-desktop
    bruno
    skopeo
    nmap
    kind
    sops
    age
    myHelm
    myHelmfile
    cargo
    aria2
    proxychains
    speedtest-cli
    # nh managed declaratively via programs.nh in shell.nix
    p7zip
    xarchiver
    watchexec
    yandex-disk
    jira-cli-go
    opentofu
    terranix
    terragrunt
    tflint
    nixfmt
    npins
    treefmt
    jdt-language-server
    mergiraf
    nil
    ytt
    redocly
    clang-tools
    boost
    meson
    inkscape
    openapi-generator-cli
    gimp
    jmeter
    librechat
    allure
    aider-chat
    aichat
    google-chrome
    jbang
    flameshot # screenshot+annotate (works on wayland via xdg-desktop-portal)
    satty # wayland annotated-screenshot tool; bound to Print in sway (pipes grim+slurp)
    grim
    slurp
    fuzzel
    cliphist
    swaynotificationcenter
    libnotify
    appimage-run
    python312Packages.psycopg2
    woeusb-ng
    k9s
    deluge
    python312Packages.click
    dbeaver-bin
    vhs
    hurl
    clojure
    difftastic
    ncdu
    dust
    bottom
    glow
    hwatch
    hyperfine
    lnav
    mktoc
    mkdocs
    soapui
    keepassxc
    nextcloud-client
    yazi
    ast-grep
    procs
    bandwhich
    jless
    stern
    kubectx
    uv
    ruff
    pre-commit
    gitleaks
    trufflehog
    xh
    sd
    gum
    mods
    duckdb
    harlequin
    visidata
    miller
    websocat
    grpcurl
    posting
    trivy
    infracost
    terraform-docs
    # checkov  # broken: pins aiohttp<3.14.0, nixpkgs ships 3.14.1
    kubeshark
    ktop
    jujutsu
    gammastep
    clipse
    awww
    wlogout
    presenterm
    lazysql
    devenv
    navi
    trippy
    gping
    doggo
    popeye
    kubectl-tree
    kubectl-neat
    kubectl-view-secret
    kubectl-images # list images per pod/container
    kubectl-klock # live-updating `get` (better watch)
    kubectl-df-pv # disk usage per PersistentVolume
    kubectl-node-shell # root shell on a node
    kubectl-explore # fuzzy API-schema explorer
    kubectl-doctor # cluster health/diagnostics scan
    kubecolor # colorized kubectl output
    pgcli
    onefetch
    tokei
    dua
    lazyjj
    frogmouth
    typst
    tinymist
    systemctl-tui
    lazyjournal
    ouch
    fclones
    erdtree
    so
    tealdeer
    glances
    mosh
    asciinema
    asciinema-agg
    earthly
    wtfutil
    restic
    rclone
    croc
    taskwarriorAsTw
    timewarrior
    helix
    fabric-ai
    llm
    samply
    sccache
    buildah
    ko
    gpg-tui
    entr
    eww
    yt-dlp
    sniffnet
    fastfetch
    gitui
    git-cliff
    pixi
    aerc
    bluetuith
    cava
    hexyl
    code2prompt
    jnv
    gron
    fx
    ledger
    ledger-live-desktop
    ledger-udev-rules
    feishin
    outline
    inputs.kpass.packages.${system}.default
    inputs.llm-agents-wrappers.packages.${system}.default
    browsers # link/app chooser: default browser + per-URL rules + override picker
    tigervnc
    remmina
    virt-viewer
    gost
    vlc
    kooha
  ];
}
