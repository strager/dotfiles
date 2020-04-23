{
  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
    vim = pkgs.vim.overrideAttrs (attrs: rec {
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
