pkgs:
with pkgs;
let
  config = (builtins.readFile ./config.el);
  default = writeText "default.el" config;
  packages = (with emacsPackages.melpaPackages; [ # Search with "nix repl '<nixpkgs>'" and tab complete emacsPackages.melpaPackages.<package name>
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
  ] ++ ( with emacsPackages.elpaPackages; [ # Search with "nix repl '<nixpkgs>'" and tab complete emacsPackages.elpaPackages.<package name>
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
