{
  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
    monkeysphere = pkgs.monkeysphere.overrideAttrs (attrs: {
      patches = (attrs.patches or []) ++ [
        ./monkeysphere-macos.patch
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

    vim = pkgs.vim.overrideAttrs (attrs: rec {
      # Work around throwpoint bug in Vim v8.2.0499 (fixed in v8.2.0823).
      version = "8.2.0823";
      src = pkgs.fetchFromGitHub {
        owner = "vim";
        repo = "vim";
        rev = "v${version}";
        sha256 = "104wzl434scr43wdranch6jkpyxkxk27fs0lc4npk23gsjf46nld";
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
