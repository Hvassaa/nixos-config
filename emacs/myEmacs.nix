pkgs:
with pkgs;
let
  config = (builtins.readFile ./config.el);
  default = writeText "default.el" config;
in
  (emacs.pkgs.withPackages (epkgs: (with epkgs.melpaPackages; [
    (runCommand "default.el" {} ''
      mkdir -p $out/share/emacs/site-lisp
      cp ${default} $out/share/emacs/site-lisp/default.el
    '')
    use-package
    which-key
    company
    flycheck
    selectrum
    marginalia

    lsp-mode
    lsp-ui
    lsp-pyright
    web-mode
    nix-mode
    rust-mode
    # rustic
    auctex

    modus-themes

    (aspellWithDicts (d: [d.en]))

  ])))
