;; -*- lexical-binding: t -*-

(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

; strager's custom package loader:
(setq strager-packages-directory (expand-file-name "strager-packages" user-emacs-directory))
(defun strager-package-ensure (package-name ensure-args state)
  (if ensure-args
      (let* ((package-directory (strager-package-root-directory package-name))
             (scripts-relative-directory (cond
                                          ((eq package-name 'cmake-mode) "Auxiliary")
                                          ((eq package-name 'magit) "lisp")
                                          ((eq package-name 'php-mode) "lisp")
                                          ((eq package-name 'with-editor) "lisp")
                                          (t ".")))
             (scripts-directory (expand-file-name scripts-relative-directory package-directory))
             (package-autoload-file (strager-package-generate-autoload package-name scripts-directory)))
        (load package-autoload-file))))
(defun strager-package-generate-autoload (package-name scripts-directory)
  "Create the PACKAGE-autoload.el file given a directory containing .el scripts.

scripts-directory must be an absolute path.

Returns the path to the autoload file."
  (let* ((autoload-temp (expand-file-name "strager-autoload-temp.el" scripts-directory))
         (autoload-file (strager-package-autoload-file package-name)))
    (loaddefs-generate
     scripts-directory
     autoload-temp
     nil
     (prin1-to-string
      `(progn
         (push ,scripts-directory load-path)
         ; HACK(strager): Trick the autoload script into thinking it's
         ; running inside scripts-directory. This is needed to make
         ; solarized-theme's theme hooks work.
         (setq load-file-name ,autoload-temp)))
     nil
     t)
    (rename-file autoload-temp autoload-file t)
    autoload-file))
(defun strager-package-root-directory (package-name)
  (expand-file-name (symbol-name package-name) strager-packages-directory))
(defun strager-package-autoload-file (package-name)
  "Return the path to the PACKAGE-autoload.el file, even if it doesn't exist."
  (expand-file-name (format "%s-autoload.el" package-name) strager-packages-directory))

(require 'use-package-ensure)
(setq use-package-ensure-function 'strager-package-ensure)
(setq use-package-always-defer t)
(setq use-package-always-ensure t)
(use-package cmake-mode)
(use-package editorconfig)
(use-package evil)
(use-package go-mode)
(use-package magit)
(use-package markdown-mode)
(use-package nix-mode)
(use-package php-mode)
(use-package solarized-theme)
(use-package typescript-mode)
(use-package with-editor)
(use-package xclip)
(use-package yaml-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-interval 1)
 '(auto-save-timeout 1)
 '(compilation-ask-about-save nil)
 '(compilation-auto-jump-to-first-error 'if-location-known)
 '(compilation-scroll-output 'first-error)
 '(compilation-skip-threshold 0)
 '(custom-safe-themes
   '("7f1d414afda803f3244c6fb4c2c64bea44dac040ed3731ec9d75275b9e831fe5" "fee7287586b17efbfda432f05539b58e86e059e78006ce9237b8732fde991b4c" "524fa911b70d6b94d71585c9f0c5966fe85fb3a9ddd635362bfabd1a7981a307" default))
 '(dabbrev-case-distinction 'case-replace)
 '(dabbrev-case-fold-search nil)
 '(default-frame-alist '((tab-bar-lines . 1)))
 '(dired-auto-revert-buffer t)
 '(dired-isearch-filenames t)
 '(dired-listing-switches "-al --group-directories-first")
 '(echo-keystrokes 0.001)
 '(evil-kill-on-visual-paste t)
 '(evil-repeat-move-cursor t)
 '(evil-search-module 'evil-search)
 '(evil-split-window-below t)
 '(evil-symbol-word-search t)
 '(evil-vsplit-window-right t)
 '(evil-want-C-d-scroll t)
 '(evil-want-C-u-scroll t)
 '(evil-want-Y-yank-to-eol t)
 '(fill-column 80)
 '(flymake-quicklintjs-args '("--language=experimental-default"))
 '(flymake-quicklintjs-experimental-typescript t)
 '(flymake-quicklintjs-program "quick-lint-js")
 '(global-auto-revert-mode t)
 '(icomplete-compute-delay 0)
 '(ido-enable-flex-matching nil)
 '(ido-show-dot-for-dired nil)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(lazy-highlight-no-delay-length 1)
 '(max-mini-window-height 0.5)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount '(3 ((shift) . hscroll)))
 '(package-selected-packages
   '(magit-section cmake-mode nix-mode go-mode xclip yaml-mode editorconfig solarized-theme markdown-mode typescript-mode vterm google-c-style))
 '(project-vc-extra-root-markers '(".sl"))
 '(scroll-bar-mode nil)
 '(scroll-conservatively 1)
 '(scroll-preserve-screen-position 1)
 '(sentence-end-double-space nil)
 '(tab-bar-auto-width nil)
 '(tab-bar-close-button-show nil)
 '(tab-bar-close-last-tab-choice 'delete-frame)
 '(tab-bar-close-tab-select 'right)
 '(tab-bar-format '(tab-bar-format-tabs))
 '(tab-bar-select-tab-modifiers '(meta))
 '(tab-bar-tab-hints t)
 '(truncate-lines t)
 '(vterm-keymap-exceptions
   '("C-c" "C-x" "C-u" "C-g" "C-h" "C-l" "M-x" "M-o" "C-y" "M-y" "M-1" "M-2" "M-3" "M-4" "M-5" "M-6" "M-7" "M-8" "M-9"))
 '(vterm-max-scrollback 100000)
 '(whitespace-style
   '(face trailing tabs newline missing-newline-at-eof empty indentation space-after-tab space-before-tab tab-mark)))

;; Modes:
(add-to-list 'auto-mode-alist '("\\.cjs\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . javascript-mode))

;; Evil mode:
(evil-mode -1)
; Instead of enabling evil-mode globally then opting buffers out,
; disable evil-mode globally then opt buffers in. This seems to be
; more reliable.
(add-hook 'prog-mode-hook 'evil-local-mode)
(add-hook 'text-mode-hook 'evil-local-mode)
(add-hook 'yaml-mode-hook 'evil-local-mode)

;; VCS commit messages:
(setq-default global-git-commit-mode nil)
(defun strager-vcs-edit-mode ()
  "Enable modes for editing VCS commit messages."
  (interactive)
  (load-library "git-commit")
  (text-mode)
  (git-commit-setup)
  (git-commit-setup-font-lock-in-buffer))
(add-to-list 'auto-mode-alist '("/COMMIT_EDITMSG" . strager-vcs-edit-mode))

;; Appearance:
(load-theme 'solarized-dark t)
(blink-cursor-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(global-whitespace-mode)
(fringe-mode 0)
(column-number-mode)
(line-number-mode)

; Try to improve syntax highlighting. I don't remember if these
; settings do anything.
(setq jit-lock-stealth-time 1)
(setq jit-lock-contextually t)

;; Navigation:
(require 'view)
(keymap-global-set "C-v" 'View-scroll-half-page-forward)
(keymap-global-set "M-v" 'View-scroll-half-page-backward)
(add-hook 'vterm-mode-hook 'goto-address-mode)

; Based on: https://stackoverflow.com/a/36707038
(define-key isearch-mode-map [remap isearch-delete-char] 'isearch-del-char)
(defun strager-isearch-search ()
  "Replacement for isearch-search which wraps if search yielded no results without wrapping."
  (unless isearch-success
    (advice-remove 'isearch-search #'strager-isearch-search)
    (unwind-protect
        (isearch-repeat (if isearch-forward 'forward)))
    (advice-add 'isearch-search :after #'strager-isearch-search)))
(advice-add 'isearch-search :after #'strager-isearch-search)

;; Shortcuts:
(define-key evil-normal-state-map (kbd "\\ a") 'project-find-regexp)
(define-key evil-normal-state-map (kbd "\\ b") 'project-switch-to-buffer)
(define-key evil-normal-state-map (kbd "\\ f") 'project-find-file)
(define-key evil-normal-state-map (kbd "\\ w") 'evil-write-all)
(define-key evil-normal-state-map (kbd "<tab>") 'evil-jump-item)
(defun strager-clear-highlights ()
  (interactive)
  (evil-ex-delete-hl 'evil-ex-search))
(define-key evil-normal-state-map (kbd "\\ l") 'strager-clear-highlights)
(defun strager-sort-lines-visual ()
  (interactive)
  (let ((range (evil-ex-range (evil-ex-marker "<") (evil-ex-marker ">"))))
    (evil-ex-sort (nth 0 range) (nth 1 range) "u")))
(define-key evil-visual-state-map (kbd "\\ s") 'strager-sort-lines-visual)

;; Handy functions:
(defun strager-copy-buffer-file-name ()
  (interactive)
  (kill-new buffer-file-name))

;; Window management:
(defun strager-split-window-below ()
  "Like split-window-below, but moves the cursor into the new window (like Vim)."
  (interactive)
  (select-window (split-window-below)))
(keymap-global-set "C-x 2" 'strager-split-window-below)
(keymap-global-unset "C-x t 1")

(defun strager-make-emacs-directory (name)
  "Return ~/.emacs.d/(name), creating it as a directory if missing."
  (let ((dir (concat user-emacs-directory name)))
    (condition-case e
        (make-directory dir)
      (file-already-exists nil))
    dir))

;; Auto-saving, backups, and lock files:
(defvar strager-auto-save-directory (strager-make-emacs-directory "autosave"))
(defun strager-make-auto-save-file-name ()
  "Far simpler and more reliable than Emacs's built-in make-auto-save-file-name."
  (let* ((full-name (if buffer-file-name (expand-file-name buffer-file-name) (buffer-name)))
         (name (if buffer-file-name (file-name-nondirectory full-name) full-name))
         (sanitized-name (url-hexify-string name))
         (auto-save-name (format "#%s-%s#" sanitized-name (sha1 full-name))))
    (expand-file-name auto-save-name strager-auto-save-directory)))
(advice-add 'make-auto-save-file-name :override #'strager-make-auto-save-file-name)
(setq auto-save-interval 1)
(setq auto-save-timeout 1)
(setq auto-save-no-message t)
(setq make-backup-files nil)

;; Clipboard:
(xclip-mode 1)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#00141a" :foreground "#9cb0b3" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight medium :height 150 :width normal :foundry "TAB " :family "Comic Code")))))

;; Code style:
(editorconfig-mode nil)

;; C mode:
(c-set-offset 'arglist-intro '+)
(c-set-offset 'arglist-cont-nonempty '+)
(c-set-offset 'innamespace 0)

(tab-bar-mode)

;; Minibuffer:
(fido-vertical-mode)
(savehist-mode 1)

;; Compilation:
(defun strager-build (&rest args)
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (compile (combine-and-quote-strings (cons "./make" args)))))
(defun strager-build-f2 ()
  (interactive)
  (strager-build "f2"))
(global-set-key [f1] 'strager-build)
(global-set-key [f2] 'strager-build-f2)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(defun strager-disable-truncate-lines ()
  (interactive)
  (setq truncate-lines nil))
(add-hook 'compilation-mode-hook 'strager-disable-truncate-lines)

;; JavaScript mode:
(add-to-list 'load-path "~/Projects/quick-lint-js-sl/plugin/emacs")
(require 'flymake-quicklintjs)
(defun my-flymake-quicklintjs-setup ()
  "Configure flymake-quicklintjs for better experience."
  (unless (derived-mode-p 'js-json-mode)
    (unless (bound-and-true-p flymake-mode)
      (flymake-mode))
    (add-hook 'flymake-diagnostic-functions #'flymake-quicklintjs nil t)
    (setq-local flymake-no-changes-timeout 0)))
(add-hook 'js-mode-hook #'my-flymake-quicklintjs-setup)
(add-hook 'typescript-mode-hook #'my-flymake-quicklintjs-setup)

;; VTerm mode:
(require 'vterm)
; Allow interrupting programs.
(define-key vterm-mode-map (kbd "C-c C-c") 'vterm--self-insert)
; Allow copying text.
(define-key vterm-mode-map (kbd "M-w") 'kill-ring-save)
(define-key vterm-mode-map (kbd "C-q") 'vterm-send-next-key)
(defun strager-show-scroll-bar-in-vterm (window-or-frame)
  "Show vertical scroll bars iff a VTerm window is active."
  (interactive)
  (scroll-bar-mode (if (equal major-mode 'vterm-mode)
                       'right
                     -1)))
(add-hook 'window-selection-change-functions 'strager-show-scroll-bar-in-vterm)

;; Dired mode:
; Make left click open the file in the current window, not in the
; other window.
(require 'dired)
(define-key dired-mode-map (kbd "<mouse-1>") 'dired-find-file)
(define-key dired-mode-map (kbd "<mouse-2>") 'dired-find-file)
