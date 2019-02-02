
(setq gc-cons-threshold 20000000)

(setq inhibit-startup-message t)

(setq ring-bell-function 'ignore)

(defalias 'yes-or-no-p 'y-or-n-p)

(require 'savehist)
(savehist-mode t)

(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(setq make-backup-files nil)
(setq create-lockfiles nil)
(auto-save-mode nil)

(setq require-final-newline t)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(global-auto-revert-mode t)

(setq-default indent-tabs-mode nil)

(setq js-indent-level 2
      css-indent-offset 2)

(setq-default tab-width 2)

(setq vc-follow-symlinks t)

(let* ((conf-files '("aliases" "functions" "gitignore" "rc" ".tf"))
       (conf-regexp (concat (regexp-opt conf-files t) "\\'")))
  (add-to-list 'auto-mode-alist (cons conf-regexp 'conf-mode)))

(require 'package)

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "http://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(setq use-package-verbose nil
      use-package-always-ensure t)

(add-to-list 'load-path "~/.emacs.d/plugins/")

(use-package general
  :config
  (setq default-states '(normal emacs motion))
  (general-define-key :states 'motion "SPC" nil)
  (general-create-definer keys-l :prefix "SPC" :states default-states)
  (general-create-definer keys :states default-states))

(defun build-keymap (&rest key-commands)
  "Builds a new sparse keymap containing given commands"
  (let ((new-map (make-sparse-keymap)))
    (while (not (cl-endp key-commands))
      (define-key new-map (kbd (pop key-commands)) (pop key-commands)))
    new-map))

(keys "M-x" 'counsel-M-x)

(keys-l
  "b" 'ivy-switch-buffer
  "f" 'counsel-projectile-find-file
  "o" 'counsel-find-file
  "h" (build-keymap
       "a" 'counsel-apropos
       "f" 'describe-function
       "K" 'which-key-show-top-level
       "k" 'describe-key
       "m" 'describe-mode
       "p" 'describe-package
       "v" 'describe-variable)
  "q" 'kill-this-buffer
  "Q" 'delete-other-windows
  "x" 'projectile-ag)

(require 'dired)

(keys :keymaps 'dired-mode-map "q" 'kill-this-buffer)

(defun dired-current-dir ()
  (interactive)
  (dired ""))

(keys-l "d" 'dired-current-dir)

(setq-default dired-listing-switches "-alh")

(keys-l "B" 'ibuffer)

(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("code" (or (mode . clojure-mode)
                           (mode . clojurec-mode)
                           (mode . c-mode)
                           (mode . ruby-mode)
                           (mode . javascript-mode)
                           (mode . java-mode)
                           (mode . js-mode)
                           (mode . coffee-mode)
                           (mode . clojurescript-mode)))
               ("emacs" (or (name . "^\\*scratch\\*$")
                            (name . "^\\*Messages\\*$")
                            (name . "^\\*Completions\\*$")))
               ("configs" (or (mode . emacs-lisp-mode)
                              (mode . org-mode)
                              (mode . conf-mode)))
               ("Magit" (name . "magit"))
               ("Help" (or (name . "\*Help\*")
                           (name . "\*Apropos\*")
                           (name . "\*info\*")))
               ("tmp" (or (mode . dired-mode)
                          (name ."^\\*")))))))

(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-switch-to-saved-filter-groups "default")))

(setq ibuffer-show-empty-filter-groups nil)

(use-package exec-path-from-shell
  :config (exec-path-from-shell-initialize))

(use-package ruby-mode)

(use-package haml-mode)

(use-package slim-mode)

(use-package evil
  :init
  (setq evil-want-fine-undo t)

  :config
  (evil-mode t)

  (evil-add-hjkl-bindings package-menu-mode-map 'emacs)
  (evil-add-hjkl-bindings ibuffer-mode-map 'emacs)

  (keys
    "C-h" 'evil-window-left
    "C-j" 'evil-window-down
    "C-k" 'evil-window-up
    "C-l" 'evil-window-right
    "j"   'evil-next-visual-line
    "k"   'evil-previous-visual-line))

(use-package evil-nerd-commenter
  :init
  (keys "gc" 'evilnc-comment-operator))

(use-package evil-cleverparens
  :init
  ;; Don't use crazy bindings for {, [, } and ] from evil-cleverparens
  (setq evil-cleverparens-use-additional-movement-keys nil))

(use-package magit
  :defer t
  :init
  (keys-l "g s" 'magit-status)

  :config
  (use-package evil-magit)
  ;; Go into insert mode when starting a commit message
  (add-hook 'git-commit-mode-hook 'evil-insert-state)

  ;; Enable leader keys in revision buffers
  (general-def magit-revision-mode-map "SPC" nil)

  (keys 'magit-blame-mode-map "q" 'magit-blame-quit)
  (keys 'git-rebase-mode-map "q" 'magit-rebase-abort)
  (keys 'magit-status-mode-map "K" 'magit-discard))

(use-package company
  :init (global-company-mode)
  :config
  (setq company-idle-delay 0.1)
  (keys :states 'insert
    "<tab>" 'company-complete-common-or-cycle)
  (general-def 'company-active-map
    "C-s" 'company-filter-candidates
    "<tab>" 'company-complete-common-or-cycle
    "S-<tab>" 'company-select-previous-or-abort))

(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode +1)
  (setq which-key-idle-delay 0.5)
  (which-key-setup-side-window-bottom))

(load "sass-mode")

(use-package clojure-mode
  :defer t
  :init
  (defun parainbow-mode ()
    (interactive)
    (paredit-mode)
    (evil-cleverparens-mode)
    (rainbow-delimiters-mode)
    (eldoc-mode))
  (add-hook 'clojure-mode-hook 'parainbow-mode)
  (add-hook 'scheme-mode-hook 'parainbow-mode)
  (add-hook 'clojurescript-mode-hook 'parainbow-mode)
  (add-hook 'cider-repl-mode-hook 'parainbow-mode)
  (add-hook 'emacs-lisp-mode-hook 'parainbow-mode)

  :config
  (setq clojure-indent-style :always-align)
  (put-clojure-indent 'assoc 1))

(use-package cider
  :defer t
  :init
  (defvar cider-mode-maps
    '(cider-repl-mode-map
      clojure-mode-map
      clojurescript-mode-map))

  (keys-l :keymaps cider-mode-maps
          "c" (build-keymap
               "c" 'cider-connect
               "d" 'cider-doc
               "i" 'cider-inspect-last-result
               "k" 'cider-repl-clear-buffer
               "q" 'cider-quit)
          "e" 'cider-eval-last-sexp
          "E" 'cider-eval-buffer)
  (keys :keymaps cider-mode-maps "g f" 'cider-find-var)
  :config
  (setq cider-repl-display-help-banner nil
        cider-repl-pop-to-buffer-on-connect 'display-only))

(use-package clj-refactor
  :defer t
  :init
  (add-hook 'clojure-mode-hook 'clj-refactor-mode)
  (add-hook 'clojurescript-mode-hook 'clj-refactor-mode)

  ;; Copy over all mnemonic cljr functions into a keymap and bind it to <leader>r
  :config
  (let ((cljr-map (make-sparse-keymap)))
    (dolist (details cljr--all-helpers)
      (define-key cljr-map (car details) (cadr details)))
    (keys-l :keymaps 'clojure-mode-map
      "r" cljr-map)))

(use-package rainbow-delimiters :defer t)

(use-package paredit :defer t)

(use-package aggressive-indent
  :defer t
  :diminish aggressive-indent-mode
  :init
  (add-hook 'clojure-mode-hook 'aggressive-indent-mode)
  (add-hook 'emacs-lisp-mode-hook 'aggressive-indent-mode)
  (add-hook 'clojurescript-mode-hook 'aggressive-indent-mode))

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-global-mode)
  (keys-l "p" 'projectile-command-map)

  ;; Projectile-ag
  (use-package ag :defer t :init (setq ag-reuse-buffers t)))

(defun neotree-project-root ()
  "Open NeoTree using the git root."
  (interactive)
  (let ((project-dir (projectile-project-root))
        (file-name (buffer-file-name)))
    (neotree-toggle)
    (when project-dir
      (neotree-dir project-dir)
      (neotree-find file-name))))

(use-package neotree
  :defer t
  :init (keys-l "n" 'neotree-project-root)
  :config
  ;; (evil-make-overriding-map neotree-mode-map 'normal t)
  (keys 'neotree-mode-map
    "d" 'neotree-delete-node
    "J" 'neotree-select-down-node
    "K" 'neotree-select-up-node
    "q" 'neotree-hide
    "m" 'neotree-rename-node
    "n" 'neotree-create-node
    "c" 'neotree-copy-node
    "o" 'neotree-enter
    "x" (lambda () (interactive) (neotree-select-up-node) (neotree-enter))
    "<tab>" 'neotree-quick-look))

(use-package ivy
  :init
  ;; better scoring / result sorting
  (use-package flx)
  :diminish ivy-mode
  :config
  (ivy-mode)

  ;; Default to fuzzy matching
  (setq ivy-re-builders-alist '((t . ivy--regex-fuzzy)))

  (general-def ivy-minibuffer-map
    "<escape>" 'minibuffer-keyboard-quit
    "<tab>" 'ivy-alt-done
    "S-<tab>" 'ivy-insert-current
    "S-<return>" '(lambda () (interactive) (ivy-alt-done t))))

(use-package counsel-projectile
  :init
  ;; Currently there is a breaking change in projectile. Until the fix is merged, this patches it:
  ;; https://github.com/ericdanan/counsel-projectile/pull/92
  (setq projectile-keymap-prefix (where-is-internal 'projectile-command-map nil t))
  :config
  (keys-l
    "f" 'counsel-projectile-find-file
    "p p" 'counsel-projectile-switch-project))

(use-package org
  :config
  (setq org-log-done 'time)
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" 'org-agenda))

;; sets rjsx-mode for .js files in a /components folder
(use-package rjsx-mode)
(add-to-list 'auto-mode-alist '("components\\|selectors\\|connectors\\|reducers\\|store\\|actions\\/.*\\.js\\'" . rjsx-mode))

(use-package gruvbox-theme :init (load-theme 'gruvbox-dark-medium t))
(set-face-attribute 'default nil :font "Fantasque Sans Mono" :height 120)

(global-hl-line-mode t)

(show-paren-mode 1)

(menu-bar-mode 0)

(if window-system
    (progn (scroll-bar-mode -1)
           (tool-bar-mode -1)
           (fringe-mode 10)))
