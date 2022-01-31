;; do not use the customize interface, at all
(setq custom-file "/dev/null")
;; Disable auto backup
(setq make-backup-files nil)
;; disable the bell
(setq ring-bell-function 'ignore)
;; no scroll bar, menu bar, tool bar
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
;; show paren matches instantly
(show-paren-mode t)
(setq show-paren-delay 0)
;; larger font
(set-face-attribute 'default nil :height 110)
;; line numbers
(dolist (hook '(prog-mode-hook text-mode-hook))
  (add-hook hook 'display-line-numbers-mode))
;; Spelling for text
(add-hook 'text-mode-hook 'flyspell-mode)
;; wrap lines
(add-hook 'text-mode-hook 'auto-fill-mode)

;;;;;;package manager config;;;;;
;; managed by nix
(require 'package)
(package-initialize 'noactivate)
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure nil)

;;; Package that shows command-completions
(use-package which-key
  :init (which-key-mode))

(use-package modus-themes
  :init
  (modus-themes-load-themes)
  :config
  (modus-themes-load-operandi))

(use-package selectrum
  :init (selectrum-mode))

(use-package marginalia
  :init (marginalia-mode))

(use-package nix-mode
  :mode ("\\.nix\\'" "\\.nix.in\\'"))

;;; web-mode - mixing html/js/jsx/ts/tsx
(use-package web-mode
  :mode (("\\.js\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.ts\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.html\\'" . web-mode)
	 ("\\.json\\'" . web-mode)))

;;; COMPANY ;;;
(use-package company
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2)
  ; Use C-n and C-p for company navigation
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  :hook
  (prog-mode . company-mode)
  (text-mode . company-mode))

;;; FLYCHECK ;;;
(use-package flycheck
  :init (global-flycheck-mode))

;;; LSP ;;;
(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
	 (javascript-mode . lsp)
	 (typescript-mode . lsp)
	 (web-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deffered))

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package lsp-pyright
  :custom (lsp-pyright-disable-organize-imports nil)
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred)))
  :config (defun python-run-clipboard ()
	    (interactive)
	    (progn
	      (setq old-buffer (buffer-name))
	      (python-shell-send-buffer)
	      (switch-to-buffer-other-window "*Python*")
	      (end-of-buffer)
	      (yank)
	      (comint-send-input)
	      (switch-to-buffer-other-window old-buffer)
	      ))
  :bind (:map python-mode-map ("C-c c" . python-run-clipboard)))

;;; LSP Optimizations
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq lsp-log-io nil) ; if set to true can cause a performance hit

;;; LaTeX ;;;
(use-package latex
  :defer t
  :hook (LaTeX-mode . reftex-mode) ; C-c = ...
  :config
  ; standard stuff
  (setq TeX-save-query nil)
  (setq TeX-parse-self t)
  (setq TeX-auto-save t)
  ; use reftex with auctex
  (setq reftex-plug-into-AUCTeX t)
  (setq reftex-toc-split-windows-horizontally t)
  (setq reftex-toc-split-windows-horizontally-fraction 0.3))

;;; Org-mode ;;;
(use-package org-mode
  ; Pretty indentation  
  :hook (org-mode . org-indent-mode)
  :custom 
	   ; HTML export: control image width
	   (org-mode-html-head "<style type='text/css'>img{ max-width:90%; margin:auto; }</style>")
	   ; show \alpha as the real symbol etc
	   (org-pretty-entities t))
