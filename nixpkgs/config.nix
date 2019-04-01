{
  packageOverrides = pkgs: {
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
  };
}
