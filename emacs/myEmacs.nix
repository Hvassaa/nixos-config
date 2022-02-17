pkgs:
with pkgs;
let
  config = (builtins.readFile ./config.el);
  default = writeText "default.el" config;
  packages = (with emacsPackages.melpaPackages; [
    use-package
    flycheck
    lsp-mode
    lsp-ui
    lsp-pyright
    web-mode
    nix-mode
    rust-mode
    go-mode
    (aspellWithDicts (d: [d.en]))    
  ] ++ ( with emacsPackages.elpaPackages; [
    vertico
    orderless
    marginalia    
    which-key
    company
    auctex
    modus-themes        
  ]));
in
  (emacs.pkgs.withPackages (epkgs: [
    (runCommand "default.el" {} ''
      mkdir -p $out/share/emacs/site-lisp
      cp ${default} $out/share/emacs/site-lisp/default.el
    '')] ++ packages))
