{
  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
    monkeysphere = pkgs.monkeysphere.overrideAttrs (attrs: {
      patches = (attrs.patches or []) ++ [
        ./monkeysphere-macos.patch
      ];
    });

    my-ninja = pkgs.ninja.overrideAttrs (attrs: {
      patches = (attrs.patches or []) ++ [
        ./ninja-vim.patch
      ];
    });

    python3 = pkgs.python3.override {
      packageOverrides = python-self: python-super: {
        twitch-python = python-super.twitch-python.overrideAttrs (attrs: {
          patches = (attrs.patches or []) ++ [
            ./twitch-allow-no-token.patch
            ./twitch-custom-comments-client-id.patch
          ];
        });
      };
    };

    sapling = pkgs.sapling.overrideAttrs (attrs: {
      patches = (attrs.patches or []) ++ [
        ./sapling-metaedit-annoyance.patch
      ];
    });

    twitch-chat-downloader = pkgs.twitch-chat-downloader.overrideAttrs (attrs: {
      src = pkgs.fetchFromGitHub {
        owner = "PetterKraabol";
        repo = "Twitch-Chat-Downloader";
        rev = "7d8b00d1836cbb804489a75b57d6af131fc2cc55";
        sha256 = "sha256-2eO4TKuP2k2AqRnJAfcvIuX3UDrD9J823ud2l2wogvg";
      };
      patches = (attrs.patches or []) ++ [
        ./twitch-chat-downloader-no-oauth.patch
        ./twitch-chat-downloader-separate-client-ids.patch
      ];
    });

    strager-emacs = let
      strager-emacs-unwrapped = (pkgs.emacsPackagesFor pkgs.emacs29-gtk3).emacsWithPackages (epkgs: [
        epkgs.vterm
      ]);
      in pkgs.runCommand "strager-emacs" {
        emacsWrapper = ''
          #!${pkgs.runtimeShell}
          # On Linux Mint, my mouse pointer cursor icon is in /usr/share/icons.
          XCURSOR_PATH=~/.icons:/usr/share/icons:/usr/share/pixmaps
          export XCURSOR_PATH
          exec ${strager-emacs-unwrapped}/bin/emacs "''${@}"
        '';
        meta = {
          mainProgram = "emacs";
        };
      } ''
        mkdir $out/
        mkdir $out/bin/
        printf '%s\n' "$emacsWrapper" >$out/bin/emacs
        chmod +x $out/bin/emacs
        ln -s ${strager-emacs-unwrapped}/bin/emacsclient $out/bin/emacsclient
      '';

    strager-vim = pkgs.vim.overrideAttrs (attrs: rec {
      version = "9.0.1377";
      src = pkgs.fetchFromGitHub {
        owner = "vim";
        repo = "vim";
        rev = "v${version}";
        sha256 = "sha256-GjJKkF52YzRSbqlExwXpDg84SbesVlY5xUITG74su6U=";
      };

      buildInputs = attrs.buildInputs ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
        pkgs.xorg.libX11
        pkgs.xorg.libXext
        pkgs.xorg.libXt
      ];
      configureFlags = attrs.configureFlags ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
        "--with-x"
      ];
    });
  };
}
