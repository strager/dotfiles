{
  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
    duplicity = pkgs.duplicity.overrideAttrs (attrs: {
      patches = (attrs.patches or []) ++ [
        ./duplicity-performance.patch
      ];
    });

    vim = pkgs.vim.overrideAttrs (attrs: rec {
      # Work around quickfix bug in Vim v8.1.1547 (fixed in v8.1.1549).
      version = "8.1.1546";
      src = pkgs.fetchFromGitHub {
        owner = "vim";
        repo = "vim";
        rev = "v${version}";
        sha256 = "01sj4wwcxfqvm5ijh33v4m8kx08p2kabqnqgwc0ym7bc52r6yliw";
      };
    });
  };
}
