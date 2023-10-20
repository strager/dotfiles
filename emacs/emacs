;; -*- lexical-binding: t -*-

(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Appearance:
(load-theme 'solarized-dark t)
(blink-cursor-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(whitespace-mode)
(fringe-mode 0)

;; Navigation:
(require 'view)
(keymap-global-set "C-v" 'View-scroll-half-page-forward)
(keymap-global-set "M-v" 'View-scroll-half-page-backward)
(add-hook 'vterm-mode-hook 'goto-address-mode)

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
 '(default-frame-alist
   '((tab-bar-lines . 1)
     (left-fringe . 200)
     (right-fringe . 200)))
 '(echo-keystrokes 0.001)
 '(flymake-quicklintjs-args '("--language=experimental-default"))
 '(flymake-quicklintjs-experimental-typescript t)
 '(flymake-quicklintjs-program
   "/home/strager/Projects/quick-lint-js-sl/build/quick-lint-js")
 '(global-auto-revert-mode t)
 '(ido-enable-flex-matching t)
 '(ido-show-dot-for-dired t)
 '(indent-tabs-mode nil)
 '(lazy-highlight-no-delay-length 1)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount '(3 ((shift) . hscroll)))
 '(package-selected-packages
   '(cmake-mode nix-mode go-mode xclip yaml-mode editorconfig solarized-theme markdown-mode typescript-mode vterm google-c-style))
 '(project-vc-extra-root-markers '(".sl"))
 '(scroll-bar-mode nil)
 '(scroll-conservatively 1)
 '(scroll-preserve-screen-position 1)
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
   '(trailing tabs newline missing-newline-at-eof empty indentation space-after-tab space-before-tab tab-mark)))
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
(ido-mode)
(savehist-mode 1)

;; Compilation:
(defun strager-build ()
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (compile "./make")))
(global-set-key [f1] 'strager-build)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

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
(defun strager-show-scroll-bar-in-vterm (window-or-frame)
  "Show vertical scroll bars iff a VTerm window is active."
  (interactive)
  (scroll-bar-mode (if (equal major-mode 'vterm-mode)
                       'right
                     -1)))
(add-hook 'window-selection-change-functions 'strager-show-scroll-bar-in-vterm)
