{
  packageOverrides = pkgs: {
    fzf = pkgs.fzf.overrideAttrs (attrs: {
      # TODO(strager): Move fzf outside the vim directory.
      src = ../vim/vim/bundle/fzf;
    });
  };
}
