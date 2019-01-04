;;; init.el --- Yi Zhenfei's emacs configuration
;;; Commentary;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap package system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Setup local package load path
(add-to-list 'load-path "~/.emacs.d/site-lisp")
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/")

(require 'package)
;; Setup package repositories
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("elpy" . "https://jorgenschaefer.github.io/packages/")
        ))
;; Initialize package system but don't load all packages
(package-initialize nil)
(setq package-enable-at-startup nil)
(unless package-archive-contents (package-refresh-contents))
;; Install use-package if necessary
(unless (package-installed-p 'use-package) (package-install 'use-package))
;; Gathering use-package statistics
;; M-x use-package-report to see the results
(require 'use-package)
(setq use-package-compute-statistics t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Common setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; PATH for shell
;; exec-path-from-shell can copy enviroment variables for us.
(use-package exec-path-from-shell
  :ensure t)

;; Custom file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Font
;; TODO: It is better if we can detect what font is available on current system,
;; and have a priority list of fonts to use.
(set-frame-font "Inconsolata 18" nil t)

;; Theme
;; (use-package monokai-theme
;;   :ensure t
;;   :config (load-theme 'monokai t))

;; Basic UI setup
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(blink-cursor-mode -1)
;; In graphic mode, disable the tool-bar and scroll-bar
(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-bar-mode -1)))

;; Use UTF-8 everywhere
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq current-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(setenv "LC_CTYPE" "UTF-8")

;; Backup file settings
(setq
 backup-by-coping t
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)
;; Save directory
(push (cons "." "~/.emacs.d/backup") backup-directory-alist)

;; Enlarge GC threashold
(setq gc-cons-threshold 20971520) ;; gc after 20MB is allocated.

;; Defer font-lock (otherwise it would be laggy for large files).
(setq jit-lock-defer-time 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Text Editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indentation
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(global-set-key (kbd "RET") 'newline-and-indent)

;; Line number
;; linum-mode is slow and laggy, use nlinum-mode instead.
(use-package nlinum
  :ensure t
  :config
  (global-nlinum-mode t))

;; Temporray disable fci-mode for it is conflicting with company-mode,
;; and I don't want to the hack currently.
;;
;; Column indicator
;; (use-package fill-column-indicator
;;   :ensure t
;;   :config
;;   (setq fci-rule-width 1)
;;   (setq fci-rule-color "white")
;;   (setq-default fci-rule-column 80)
;;   :hook
;;   (prog-mode . fci-mode))

;; Ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

;; Hungry delete white spaces.
(use-package hungry-delete
  :ensure t
  :hook
  (prog-mode . hungry-delete-mode))

;; Yasnippet
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.yasnippets"))
  :hook
  (prog-mode . yas-minor-mode))

;; Mark Ring
;; C-SPC immediately after C-u C-SPC cycles the mark ring.
(setq set-mark-command-repeat-pop t)
(setq mark-ring-max 32)
(setq global-mark-ring-max 64)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filesystem Manipulating
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR."
  (interactive "DNew directory: ")
  (let* ((name (buffer-name))
	     (filename (buffer-file-name))
	     (dir
	      (if (string-match dir "\\(?:/\\|\\\\)$")
	          (substring dir 0 -1) dir))
	     (newname (concat dir "/" name)))

    (if (not filename)
	    (message "Buffer '%s' is not visiting a file!" name)
      (progn
        (copy-file filename newname 1)
        (delete-file filename)
        (set-visited-file-name newname)
        (set-buffer-modified-p nil)
        t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package helm
  :ensure t
  :bind
  (;; Enable Helm for various scenarios
   ("M-x" . helm-M-x)
   ("C-x b" . helm-mini)
   ("C-x C-f" . helm-find-files)
   ("C-x i" . helm-imenu))
  :bind
  (:map helm-map
        ;; rebind tab to run persistent action
        ("<tab>" . helm-execute-persistent-action)
        ;; make TAB work in terminal
        ("C-i" . helm-execute-persistent-action)
        ;; list actions using C-z
        ("C-z" . helm-select-action))
  :config
  ;; Enable fuzzy matching
  (setq helm-M-x-fuzzy-match t)
  (setq helm-recentf-fuzzy-match t)
  (setq helm-buffers-fuzzy-matching t))

(use-package helm-xref
  :ensure t
  :config
  (setq xref-show-xrefs-function 'helm-xref-show-xrefs))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Magit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package projectile
  :ensure t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (setq projectile-completion-system 'helm))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helm Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package helm-projectile
  :ensure t
  :defer t
  :config
  (helm-projectile-on)
  (setq projectile-switch-project-action 'helm-projectile))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CMake
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cmake-mode
  :ensure t
  :defer t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Company
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  ;; Set backends for company
  (setq-default company-backends '(company-capf company-keywords))
  ;; Adjust the param to balance between fast and smooth.
  (setq company-idle-delay 0.1)
  ;; Auto complete after n char is entered
  (setq company-minimum-prefix-length 1)
  (setq company-show-numbers t))

;;
;; Turn off fci-mode temporarily when company is completing.
;; For that fci-mode can make company tooltip mis-positioned.
;;
;; (defvar-local company-fci-mode-on-p nil)

;; (defun company-turn-off-fci (&rest ignore)
;;   (when (boundp 'fci-mode)
;;     (setq company-fci-mode-on-p fci-mode)
;;     (when fci-mode (fci-mode -1))))

;; (defun company-maybe-turn-on-fci (&rest ignore)
;;   (when company-fci-mode-on-p (fci-mode 1)))

;; (add-hook 'company-completion-started-hook 'company-turn-off-fci)
;; (add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
;; (add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci)

(use-package company-lsp
  :ensure t
  :config
  (push 'company-lsp company-backends))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flycheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package flycheck
;;   :ensure t
;;   :hook (prog-mode . flycheck-mode))

;; (use-package flycheck-rtags
;;   :ensure t
;;   :config
;;   (defun flycheck-rtags-setup ()
;;     (flycheck-select-checker 'rtags)
;;     ;; RTags creates more accurate overlays.
;;     (setq-local flycheck-highlighting-mode nil)
;;     (setq-local flycheck-check-syntax-automatically nil))
;;   (add-hook 'c-mode-hook #'flycheck-rtags-setup)
;;   (add-hook 'c++-mode-hook #'flycheck-rtags-setup))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++ Basic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-default c-basic-offset 4)
(defun my-c++-setup ()
  (c-set-offset 'innamespace [0])
  (c-set-offset 'brace-list-intro '+))
(add-hook 'c++-mode-hook 'my-c++-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs-cquery
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cquery
  :ensure t
  :config
  (setq cquery-extra-args '("--log-file=~/.cquery/cquery.log"))
  ;; On Centos7, we need to compile the cquery with devtoolset-7, which has
  ;; different system includes with the project we are developing, thus
  ;; using discovered system includes would cause problem for cquery.
  (setq cquery-extra-init-params '(:discoverSystemIncludes :json-false))
  (setq cquery-sem-highlight-method 'font-lock)
  (setq cquery-cache-dir "~/.cquery/.cquery_cached_index"))

(use-package lsp-mode
  :ensure t
  :config
  (add-hook 'c-mode-hook #'lsp)
  (add-hook 'c++-mode-hook #'lsp))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;; Cellar
;; Stuffs I don't use currently, but maybe valuable in the future.
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rust
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package rust-mode
;;   :ensure t
;;   :config
;;   (add-hook 'rust-mode-hook #'lsp-rust-enable))

;; (use-package lsp-mode
;;   :ensure t
;;   :config
;;   (setq lsp-rust-rls-command '("rustup" "run" "nightly" "rls")))

;; (use-package lsp-rust
;;   :ensure t)

;;
;; rtags seems not very good at completion. (always missing symbols)
;;
;; (use-package company-rtags
;;   :ensure t
;;   :config
;;   (add-to-list 'company-backends 'company-rtags))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Irony
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; Irony is good enough generally, but too slow to load cdb in huge project.
;;

;; (use-package irony
;;   :ensure t
;;   :hook
;;   (c++-mode . irony-mode)
;;   (c-mode . irony-mode)
;;   (irony-mode . irony-cdb-autosetup-compile-options))

;; (use-package company-irony
;;   :ensure t
;;   :config
;;   (add-to-list 'company-backends 'company-irony))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RTags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package rtags
;;   :ensure t
;;   :config
;;   ;; (setq rtags-completions-enabled t)
;;   ;; (setq rtags-autostart-diagnostics t)
;;   :bind (:map c-mode-base-map
;;               ("M-." . rtags-find-symbol-at-point)
;;               ("M-," . rtags-find-references-at-point)))

;; (use-package helm-rtags
;;   :ensure t
;;   :config
;;   (setq rtags-display-result-backend 'helm))

;; Using sandbox of rtags
;; (defun get-sbroot-for-dir (dir)
;;   "Find sandbox root of file for rtags"
;;   (if (or (not dir) (not (file-accessible-directory-p dir)) (string= dir "/"))
;;       nil
;;     (if (file-accessible-directory-p (concat dir ".rtags"))
;;         dir
;;       (get-sbroot-for-dir (file-name-directory (directory-file-name dir)))))
;;   )

;; (defun get-sbroot-for-buffer ()
;;   "Find sandbox root of buffer for rtags"
;;   (let ((f (buffer-file-name (current-buffer))))
;;     (if (stringp f)
;;         (get-sbroot-for-dir
;;          (file-name-directory
;;           (directory-file-name f)))
;;       nil)))

;; (add-hook 'find-file-hook
;;           (lambda ()
;;             (if (= (length rtags-socket-file) 0)
;;                 (let ((sbroot (if (buffer-file-name) (get-sbroot-for-buffer) nil))
;;                       (socket-file nil))
;;                   (when sbroot
;;                     (setq socket-file (concat sbroot ".rtags/rdm.socket"))
;;                     (if (file-exists-p socket-file)
;;                         (setq rtags-socket-file socket-file)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ycmd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package ycmd
;;   :ensure t
;;   :hook
;;   (c-mode . ycmd-mode)
;;   (c++-mode . ycmd-mode)
;;   :config
;;   (set-variable 'ycmd-server-command
;;                 `("python", (file-truename "~/.emacs.d/ycmd/ycmd/")))
;;   (setq ycmd-extra-conf-handler 'load))

;; (use-package company-ycmd
;;   :ensure t
;;   :config (company-ycmd-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; Flx maybe useful, but not now(too many other stuffs need to be configured).
;;

;; (use-package flx
;;   :ensure t)

;; (use-package company-flx
;;   :ensure t
;;   :hook (company-mode . company-flx-mode))
;; (with-eval-after-load 'company
;;   (company-flx-mode +1))

;;  :config (add-to-list 'company-backends 'company-flx))

;; (use-package helm-flx
;;   :ensure t
;;   :config
;;   (helm-flx-mode))

;;; init.el ends here
