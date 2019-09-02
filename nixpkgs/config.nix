{
  android_sdk.accept_license = true;

  packageOverrides = pkgs: {
    duplicity = pkgs.duplicity.overrideAttrs (attrs: {
      patches = (attrs.patches or []) ++ [
        ./duplicity-performance.patch
      ];
    });

    fzf = pkgs.fzf.overrideAttrs (attrs: {
      patchPhase = ''
        ${attrs.patchPhase}
        patchPhase
      '';
      patches = (attrs.patches or []) ++ [
        (pkgs.fetchpatch {
          url = https://github.com/strager/fzf/commit/e2baf624790bed56f233433236c03b81f313ba51.patch;
          sha256 = "1bg42l1fr6236ss03m2g9g2904rwv4f1w4crr7a6pvw8m2hi4a1j";
        })
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
