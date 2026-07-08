{
  config,
  lib,
  pkgs,
  username,
  name,
  email,
  stateVersion,
  homeDirectory,
  nur,
  pkgs-stable,
  codex-cli-nix,
  ...
}:

let
  warmBurnoutState = "${homeDirectory}/.local/state/warm-burnout/variant";
  zedSettings = variant: builtins.replaceStrings
    [ ''"theme": {
    "mode": "system",'' ]
    [ ''"theme": {
    "mode": "${variant}",'' ]
    (builtins.readFile ./zed_settings.json);
  zellijConfig = variant: builtins.replaceStrings
    [ ''theme "warm-burnout-dark"'' ]
    [ ''theme "warm-burnout-${variant}"'' ]
    (builtins.readFile ./zellij/config.kdl);
  nurNopkgs = import nur {
    pkgs = pkgs;
    nurpkgs = pkgs;
  };
  allowUnfree = config.allowUnfree;
  useWayland = config.useWayland;
  thinkpad = config.thinkpad;
  graphical = config.graphical;
  hostSystem = pkgs.stdenv.hostPlatform.system;
  pkillCmd = if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pkill" else "${pkgs.procps}/bin/pkill";
  psCmd = if pkgs.stdenv.hostPlatform.isDarwin then "/bin/ps" else "${pkgs.procps}/bin/ps";
  clipboardCmd =
    if builtins.match ".*darwin$" hostSystem != null then "pbcopy" else "xclip -selection clipboard";
  helixSettings = variant: {
    theme = "warm-burnout-${variant}";
    editor = {
      line-number = "relative";
      true-color = true;
      lsp.display-messages = true;
    };
    keys.normal.space = {
      B = [
        '':sh jj --ignore-working-copy file annotate %{buffer_name} -T "if(self.line_number() == %{cursor_line}, concat(self.commit().change_id().shortest(), \" \", self.commit().commit_id().shortest(), \" \", self.commit().author().timestamp().format(\"%%Y-%%m-%%d\"), \" \", self.commit().author(), \"\\n\", self.commit().description()))"''
      ];
      q = '':sh echo "$(jj --ignore-working-copy git remote list | awk '{print $2}')/commit/$(jj --ignore-working-copy file annotate %{buffer_name} -T 'if(self.line_number() == %{cursor_line}, self.commit().commit_id())')" | ${clipboardCmd}'';
      Q = '':sh echo "$(jj --ignore-working-copy git remote list | awk '{print $2}')/blob/$(jj --ignore-working-copy file annotate -r @ %{buffer_name} -T 'if(self.line_number() == %{cursor_line}, concat(self.commit().commit_id(), "/%{buffer_name}#L", self.original_line_number()))')" | ${clipboardCmd}'';
      l = '':sh echo "$(jj --ignore-working-copy git remote list | awk '{print $2}')/blob/master/%{buffer_name}" | ${clipboardCmd}'';
      L = '':sh echo "$(jj --ignore-working-copy git remote list | awk '{print $2}')/blob/$(jj --ignore-working-copy log -r 'latest(heads(::@ & ::trunk()))' -T 'self.commit_id()' --no-graph)/%{buffer_name}#L%{cursor_line}" | ${clipboardCmd}'';
    };
  };
  tomlFormat = pkgs.formats.toml { };
  warmBurnout = pkgs.writeShellScriptBin "warm-burnout" ''
    set -eu

    usage() {
      echo "usage: warm-burnout {light|dark|toggle}" >&2
      exit 2
    }

    config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
    state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
    state_dir="$state_home/warm-burnout"
    state_file="$state_dir/variant"
    variant="''${1:-}"

    case "$variant" in
      light|dark) ;;
      toggle)
        if [ "$(cat "$state_file" 2>/dev/null || true)" = dark ]; then
          variant=light
        else
          variant=dark
        fi
        ;;
      *) usage ;;
    esac

    mkdir -p "$state_dir" "$config_home/ghostty" "$config_home/eza" \
      "$config_home/helix" "$config_home/zed" "$config_home/zellij"

    state_tmp="$state_file.$$"
    ghostty_file="$config_home/ghostty/warm-burnout"
    ghostty_tmp="$ghostty_file.$$"
    trap 'rm -f "$state_tmp" "$ghostty_tmp"' EXIT

    printf '%s\n' "$variant" > "$state_tmp"
    mv -f "$state_tmp" "$state_file"
    printf 'theme = warm-burnout-%s\n' "$variant" > "$ghostty_tmp"
    mv -f "$ghostty_tmp" "$ghostty_file"

    ln -sfn "$config_home/eza/warm-burnout-$variant.yml" "$config_home/eza/theme.yml"
    ln -sfn "$config_home/helix/config-$variant.toml" "$config_home/helix/config.toml"
    ln -sfn "$config_home/zed/settings-$variant.json" "$config_home/zed/settings.json"
    ln -sfn "$config_home/zellij/config-$variant.kdl" "$config_home/zellij/config.kdl"

    if [ "$variant" = dark ]; then
      foreground="#bfbdb6"
      background="#1a1510"
      cursor="#f5c56e"
      palette="0;#23211b;1;#f06b73;2;#70bf56;3;#fdb04c;4;#4fbfff;5;#d0a1ff;6;#93e2c8;7;#c7c7c7;8;#686868;9;#f07178;10;#aad94c;11;#ffb454;12;#59c2ff;13;#d2a6ff;14;#95e6cb;15;#ffffff"
    else
      foreground="#3a3630"
      background="#f5ede0"
      cursor="#8a6600"
      palette="0;#3a3630;1;#b82820;2;#2d6a14;3;#8a6000;4;#2060a0;5;#8a3090;6;#146858;7;#c0b8aa;8;#686868;9;#c83028;10;#3a7a20;11;#9a7008;12;#2870b0;13;#9a38a0;14;#208870;15;#faf6f0"
    fi

    emit_colors() {
      printf '\033]10;%s\033\\' "$foreground"
      printf '\033]11;%s\033\\' "$background"
      printf '\033]12;%s\033\\' "$cursor"
      printf '\033]4;%s\033\\' "$palette"
    }

    { emit_colors > /dev/tty; } 2>/dev/null || true
    while IFS= read -r terminal; do
      case "$terminal" in
        /dev/*) terminal_path="$terminal" ;;
        *) terminal_path="/dev/$terminal" ;;
      esac
      { emit_colors > "$terminal_path"; } 2>/dev/null || true
    done < <(
      ${psCmd} eww -axo tty=,command= 2>/dev/null \
        | ${pkgs.gawk}/bin/awk '$1 != "?" && $1 != "??" && /(^| )TERM_PROGRAM=ghostty( |$)/ && !seen[$1]++ { print $1 }'
    )

    if [ -z "''${WARM_BURNOUT_NO_RELOAD:-}" ]; then
      ${pkillCmd} -USR2 -x ghostty 2>/dev/null || ${pkillCmd} -USR2 -x Ghostty 2>/dev/null || true

      ${pkillCmd} -USR1 -u "$USER" -x '(hx|\.hx-wrapped)' 2>/dev/null || true
      ${pkillCmd} -USR1 -x nvim 2>/dev/null || true
      zellij list-sessions --short 2>/dev/null | while IFS= read -r session; do
        zellij --session "$session" options --theme "warm-burnout-$variant" >/dev/null 2>&1 || true
      done
    fi

    echo "Warm Burnout: $variant"
  '';
  editorPackages = with pkgs; [
    # lsp
    clojure-lsp
    cmake-language-server
    docker-ls
    # dhall-lsp-server
    haskell-language-server
    java-language-server
    kotlin-language-server
    metals
    nil
    bash-language-server
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
    ocamlPackages.ocaml-lsp
    pyright
    statix
    lua-language-server
    texlab
    typescript

    # formatters
    black
    nixpkgs-fmt
    ocamlformat
    ocamlPackages.ocamlformat-rpc-lib
  ];
in
{
  nixpkgs.config.allowUnfree = allowUnfree;
  home = {
    stateVersion = stateVersion;
    username = username;
    homeDirectory = homeDirectory;
    sessionVariables = {
      COLORTERM = "truecolor";
      EZA_CONFIG_DIR = "${homeDirectory}/.config/eza";
      TERM = "xterm-256color";
    };

    # rnsh reticulum ids
    sessionVariables = {
      HAL = "8eeb2f0512b1d221bc6e7698f937b977";
      HFCS = "241cbb84406357c9f33ce285839c5d2a";
    };

    packages =
      with pkgs;
      [
        ffmpeg
        stow
        dust
        gopass
        gopass-jsonapi
        binwalk
        fastfetch
        fzy
        unzip
        unrar
        rlwrap
        zip
        mosh
        todoist
        wget
        killall
        graphviz
        nix-search
        (python3.withPackages (
          ps: with ps; [
            requests
            pynvim
            polars
          ]
        ))
        claude-code
        gemini-cli
        codex-cli-nix.packages.${hostSystem}.default
        asciinema
        nodejs_24
        imagemagick
        poppler-utils
        gh
        ty
        ruff
        rust-analyzer
        (writeScriptBin "vimtabdiff.py" (builtins.readFile ./bin/vimtabdiff.py))
        warmBurnout
        # copyparty
        jjui
        lazyjj
        weechat
        jq
        llama-cpp
        opencode
        rns
        python313Packages.nomadnet
      ]
      ++ (
        if graphical then
          [
            nerd-fonts.jetbrains-mono
            font-awesome
            liberation_ttf
            neovide
          ]
          ++ (
            if useWayland then
              [
                grim
                slurp
                wl-clipboard
                bemenu
              ]
            else
              [
              ]
          )
        else
          [ ]
      )
      ++ (
        if thinkpad then
          [
            eog
            usbutils
            light
            xclip
            xmlstarlet
            lxappearance
            paprefs
          ]
        else
          [ ]
      )
      ++ (
        if graphical && thinkpad then
          [
            qFlipper
            todoist-electron
            libreoffice
            pinentry-gtk2
            chromium
            pavucontrol
            nemo
            calibre
            zoom
            obsidian
            pulseaudioFull
            slack
            webex
            openconnect
            discord
            zathura
            caprine-bin
            geogebra
            pear-desktop
          ]
        else if graphical then
          [
            pinentry_mac
          ]
        else
          [ pinentry-curses ]
      );
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

  xdg.configFile."ghostty/themes/warm-burnout-dark".source = ./ghostty/themes/warm-burnout-dark;
  xdg.configFile."ghostty/themes/warm-burnout-light".source = ./ghostty/themes/warm-burnout-light;
  xdg.configFile."eza/warm-burnout-dark.yml".source = ./eza/warm-burnout-dark.yml;
  xdg.configFile."eza/warm-burnout-light.yml".source = ./eza/warm-burnout-light.yml;
  xdg.configFile."helix/config-dark.toml".source = tomlFormat.generate "helix-config-dark" (helixSettings "dark");
  xdg.configFile."helix/config-light.toml".source = tomlFormat.generate "helix-config-light" (helixSettings "light");
  xdg.configFile."helix/runtime/themes/warm-burnout-dark.toml".source = ./helix/themes/warm-burnout-dark.toml;
  xdg.configFile."helix/runtime/themes/warm-burnout-light.toml".source = ./helix/themes/warm-burnout-light.toml;
  xdg.configFile."zed/themes/warm-burnout.json".source = ./zed/themes/warm-burnout.json;
  xdg.configFile."zed/settings-dark.json".text = zedSettings "dark";
  xdg.configFile."zed/settings-light.json".text = zedSettings "light";
  xdg.configFile."wezterm/colors/warm-burnout-dark.toml".source = ./wezterm/warm-burnout-dark.toml;
  xdg.configFile."wezterm/colors/warm-burnout-light.toml".source = ./wezterm/warm-burnout-light.toml;
  xdg.configFile."zellij/config-dark.kdl".text = zellijConfig "dark";
  xdg.configFile."zellij/config-light.kdl".text = zellijConfig "light";

  xdg.configFile.agent-os = {
    source = ./agent-os;
    recursive = true;
  };

  home.activation.warmBurnout = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    variant=light
    if [ -f ${pkgs.lib.escapeShellArg warmBurnoutState} ]; then
      variant=$(cat ${pkgs.lib.escapeShellArg warmBurnoutState})
    fi
    case "$variant" in
      light|dark) ;;
      *) variant=light ;;
    esac
    $DRY_RUN_CMD env WARM_BURNOUT_NO_RELOAD=1 ${warmBurnout}/bin/warm-burnout "$variant"
  '';

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    man = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      generateCaches = false;
    };

    # no config programs
    tealdeer.enable = true; # tldr
    gpg.enable = true;
    fish.enable = true; # shell replacement
    bottom.enable = true; # htop replacement
    bat.enable = true;
    difftastic.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    rclone.enable = true;
    yt-dlp.enable = true;
    television = {
      enable = true;
      enableFishIntegration = true;
    };

    # ls replacement
    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    zellij = {
      enable = true;
      enableFishIntegration = false;
      themes = {
        warm-burnout-dark = ./zellij/themes/warm-burnout-dark.kdl;
        warm-burnout-light = ./zellij/themes/warm-burnout-light.kdl;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # shell prompt manager
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        # Add custom modules to the format
        format = "$username$hostname$localip$shlvl$singularity$kubernetes$directory$vcsh$fossil_branch$fossil_metrics\${custom.git_branch}\${custom.git_commit}$git_state\${custom.git_metrics}\${custom.git_status}$hg_branch$pijul_channel$docker_context$package$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$golang$guix_shell$haskell$haxe$hg_branch$java$julia$kotlin$lua$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$raku$ruby$rust$scala$solidity$swift$terraform$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$env_var$crystal\${custom.jj}$sudo$cmd_duration$line_break$jobs$battery$time$status$os$container$shell$character";

        character = {
          success_symbol = "[>>=](yellow)";
          error_symbol = "[_|_](red)";
          vicmd_symbol = "[<*>](green)";
        };
        directory.style = "bold bright-yellow";
        git_branch.style = "green";
        git_state.style = "bright-black";
        cmd_duration.style = "bright-black";
        python.style = "bright-black";
        python.detect_extensions = [ ];

        # replace builtin git modules with ones that detect jj
        git_status.disabled = true;
        git_commit.disabled = true;
        git_metrics.disabled = true;
        git_branch.disabled = true;

        custom = {
          jj = {
            description = "The current jj status";
            detect_folders = [".jj"];
            symbol = "🥋 ";
            shell = ["sh" "--noprofile" "--norc"];
            command = "jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template 'separate(\" \", change_id.shortest(4), bookmarks, \"|\", concat(if(conflict, \"💥\"), if(divergent, \"🚧\"), if(hidden, \"👻\"), if(immutable, \"🔒\")), raw_escape_sequence(\"\\x1b[1;32m\") ++ if(empty, \"(empty)\"), raw_escape_sequence(\"\\x1b[1;32m\") ++ coalesce(truncate_end(29, description.first_line(), \"…\"), \"(no description set)\") ++ raw_escape_sequence(\"\\x1b[0m\"))'";
          };
          git_status = {
            detect_folders = ["!.jj"];
            command = "starship module git_status";
            style = "blue";
            description = "Only show git_status if we're not in a jj repo";
          };
          git_commit = {
            detect_folders = ["!.jj"];
            command = "starship module git_commit";
            style = "";
            description = "Only show git_commit if we're not in a jj repo";
          };
          git_metrics = {
            detect_folders = ["!.jj"];
            command = "starship module git_metrics";
            style = "";
            description = "Only show git_metrics if we're not in a jj repo";
          };
          git_branch = {
            detect_folders = ["!.jj"];
            command = "starship module git_branch";
            style = "";
            description = "Only show git_branch if we're not in a jj repo";
          };
        };
      };
    };

    # quick shell navigation
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    git = {
      enable = true;
      settings = {
        user.name = name;
        user.email = email;
        core.editor = "hx";
        credential.helper = "store";
      };
    };

    gitui.enable = true;

    jujutsu = {
      enable = true;
      settings = {
        user.name = name;
        user.email = email;
        ui.diff-formatter = "difft";
        ui.diff-editor = [
          "nvim"
          "-c"
          "DiffEditor $left $right $output"
        ];
        ui.merge-editor = "diffconflicts";
        ui.pager = ":builtin";
        merge-tools.vimdiff = {
          diff-invocation-mode = "file-by-file";
        };
        revset-aliases."immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine()) | bookmarks(glob:rel_*) | bookmarks(glob:prod_*)";
        revsets."bookmark-advance-to" = "@-";
        aliases = {
          l = ["log"];
        };
        merge-tools.diffconflicts = {
          program = "nvim";
          merge-args = [
            "-c"
            "let g:jj_diffconflicts_marker_length=$marker_length"
            "-c"
            "JJDiffConflicts!"
            "$output"
            "$base"
            "$left"
            "$right"
          ];
          merge-tool-edits-conflict-markers = true;
        };
      };
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      defaultEditor = false;

      plugins = with pkgs.vimPlugins; [
        # the goat
        mini-nvim

        # util
        leap-nvim
        vim-repeat

        # git
        git-blame-nvim
        gitsigns-nvim
        neogit

        # ide features
        friendly-snippets
        lsp-status-nvim
        lspkind-nvim
        nvim-dap
        nvim-dap-python
        nvim-dap-ui
        nvim-treesitter-context
        nvim-treesitter-endwise
        nvim-treesitter-textobjects
        nvim-treesitter
        rainbow-delimiters-nvim
        vista-vim

        # language specific
        dhall-vim
        haskell-tools-nvim
        haskell-vim
        # parinfer-rust
        purescript-vim
        typescript-tools-nvim
        # vim-sexp
        # vim-sexp-mappings-for-regular-people
        vimtex

        hunk-nvim
      ];

      # only loaded when neovim is launched!
      extraPackages = editorPackages;
    };

    helix = {
      enable = true;
      extraPackages = editorPackages;
      defaultEditor = true;
      languages = {
        language = [
          {
            name = "python";
            language-id = "python";
            auto-format = true;
            language-servers = [
              "ty"
              "ruff"
            ];
            file-types = [ "py" ];
            comment-token = "#";
            shebangs = [ "python" ];
            roots = [
              "pyproject.toml"
              "setup.py"
              "poetry.lock"
              ".git"
              ".jj"
              ".venv/"
            ];
          }
        ];
      };
      settings = { };
    };
  }
  // (
    if graphical then
      {

        wezterm = {
          enable = true;
          extraConfig = ''
            local variant_file = "${warmBurnoutState}"
            wezterm.add_to_config_reload_watch_list(variant_file)

            local variant = "light"
            local file = io.open(variant_file, "r")
            if file then
              variant = file:read("*l") or variant
              file:close()
            end

            return {
              font = wezterm.font("JetBrains Mono"),
              font_size = 13.0,
              color_scheme = variant == "dark" and "Warm Burnout Dark" or "Warm Burnout Light",
              hide_tab_bar_if_only_one_tab = true,
              -- default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
              keys = {
                {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},
              --   {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
              }
            }
          '';
        };

        ghostty = {
            enable = true;
            package = pkgs.ghostty-bin;
            enableFishIntegration = true;
            settings."config-file" = "?${homeDirectory}/.config/ghostty/warm-burnout";
        };
      }
    else
      { }
  );
}
// (
  if graphical && thinkpad then
    {
      services.mako.enable = useWayland; # wayland notification daemon
      mpv.enable = true; # media player
      firefox = {
        enable = true;
        package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
          extraPolicies = {
            ExtensionSettings = { };
          };
        };
        profiles.default = {
          id = 0;
          name = "Default";
          isDefault = true;
          extensions = with nurNopkgs.repos.rycee.firefox-addons; [
            ublock-origin
            vimium
            gopass-bridge
            addy_io
            darkreader
          ];
          settings = {
            "browser.theme.content-theme" = 0; # dark theme
            "browser.theme.toolbar-theme" = 0; # dark theme
            "findbar.modalHighlight" = true; # dims screen and animates during ctrl-f
            "findbar.highlightAll" = true; # highlights all ctrl-f results
            "browser.newtabpage.activity-stream.enabled" = false; # better new tab
            "extensions.pocket.enabled" = false; # disable pocket
            "browser.compactmode.show" = true;
            "identity.fxaccounts.enabled" = false;
          };
        };
      };
      i3status = {
        enable = true;
        enableDefault = false;
        general = {
          interval = 1;
          colors = true;
          color_good = "#b8bb26";
          color_bad = "#fb4934";
          color_degraded = "#fabd2f";
        };
        modules = {
          "volume master" = {
            position = 1;
            settings = {
              format = "%volume  ";
              format_muted = " ";
              device = "default";
              mixer = "Master";
              mixer_idx = 0;
            };
          };
          "wireless wlp2s0" = {
            position = 2;
            settings = {
              format_up = "%quality  %essid %ip";
              format_down = "";
            };
          };
          "battery 0" = {
            position = 3;
            settings = {
              format = "%status %percentage %consumption %remaining";
              format_down = "";
              last_full_capacity = true;
              integer_battery_capacity = true;
              low_threshold = 11;
              threshold_type = "percentage";
              hide_seconds = true;
              status_chr = " ";
              status_bat = " ";
              status_unk = " ";
              status_full = " ";
            };
          };
          "tztime local" = {
            position = 4;
            settings = {
              format = " %I:%M %p";
            };
          };
        };
      };
    }
  else
    { }
)
// (
  if graphical && useWayland then
    {

      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        config = {
          modifier = "Mod4";
          gaps = {
            inner = 10;
            outer = 0;
            smartGaps = true;
          };
          input =
            if thinkpad then
              {
                "2:10:TPPS/2_Elan_TrackPoint".tap = "enabled";
                "1739:0:Synaptics_TM3289-021".tap = "enabled";
              }
            else
              { };
          terminal = "ghostty";
          output = {
            "*" = {
              bg = "~/.config/nixpkgs/backgrounds/cozywindow.jpg fill";
            };
          };
        };
      };
    }
  else if thinkpad && graphical && !useWayland then
    {
      xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps; # TODO: remove when merger hits
        config = {
          terminal = "wezterm";
          modifier = "Mod4";
          window.hideEdgeBorders = "smart";
          workspaceAutoBackAndForth = true;
          gaps = {
            inner = 10;
            outer = 0;
            smartGaps = true;
          };
          window.commands = [
            {
              criteria = {
                title = "HearthstoneOverlay";
              };
              command = "sticky enable";
            }
          ];
        };
      };
    }
  else
    { }
)
// (
  if thinkpad then
    {
      services.gpg-agent = {
        enable = true;
        pinentryFlavor = if graphical then "gtk2" else "tty";
        enableFishIntegration = true;
      };
    }
  else
    { }
)
