;; -*- lexical-binding: t -*-
;;
;; Run this file with `make check-emacs`.

(require 'ert)

(ert-deftest strager-test-evil-enabled-for-files ()
  "Evil mode should be enabled for most files."
  (let ((dir (make-temp-file "strager-evil-test-" t)))
    (unwind-protect
        (dolist (filename strager-test-evil-files)
          (let ((path (expand-file-name filename dir))
                buffer)
            (unwind-protect
                (progn
                  (write-region "" nil path nil 'silent)
                  (setq buffer (find-file-noselect path))
                  (with-current-buffer buffer

                    (unless (bound-and-true-p evil-local-mode)
                      (ert-fail (format "Evil mode was not enabled for file '%s' (major-mode=%s)"
                                        filename major-mode)))))

              (when (buffer-live-p buffer)
                (with-current-buffer buffer
                  (set-buffer-modified-p nil))
                (kill-buffer buffer)))))

      (delete-directory dir t))))

(defvar strager-test-evil-files
  '(".clang-format"
    ".gitignore"
    "002-lips.caddy.j2"
    "005-devtunnel.app.fire-lingo.com.caddy"
    "Caddyfile"
    "LICENSE"
    "README.md"
    "ZCCLink.proto"
    "alertmanager.yml.j2"
    "config.dev.toml"
    "config.devtunnel.toml"
    "devices.csv"
    "go.mod"
    "go.sum"
    "hello.c"
    "iucu.csv"
    "main.go"
    "project.pbxproj"
    "pyproject.toml"
    "traduality-beedo-delete-data.service.j2"
    "traduality-sharepoint.timer")
  "Filenames that should activate `evil-local-mode' when visited.")
