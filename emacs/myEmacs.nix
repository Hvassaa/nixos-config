pkgs:
with pkgs;
let
  config = (builtins.readFile ./config.el);
  default = writeText "default.el" config;
in
  (emacs.pkgs.withPackages (epkgs: (with epkgs.melpaStablePackages; [
    (runCommand "default.el" {} ''
      mkdir -p $out/share/emacs/site-lisp
      cp ${default} $out/share/emacs/site-lisp/default.el
    '')
    use-package
    which-key
    company
    flycheck
    lsp-mode
    lsp-ui
    auctex
    web-mode
    nix-mode
    (aspellWithDicts (d: [d.en]))
  ])))
