{
  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
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
