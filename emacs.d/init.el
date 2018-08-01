;;; init.el --- Yi Zhenfei's emacs configuration
;;; Commentary;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap package system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Setup local package load path
(add-to-list 'load-path "~/.emacs.d/site-lisp")

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
;; (load-theme 'tango-dark t)
;; (load-theme 'dracula t)
(use-package monokai-theme
  :ensure t
  :config (load-theme 'monokai t))

;; Basic UI setup
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(blink-cursor-mode -1)
;; In graphic mode, disable the tool-bar and scroll-bar
(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-bar-mode -1)))

;; UTF-8
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Text Editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indentation
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(global-set-key (kbd "RET") 'newline-and-indent)

;;
;; linum-mode is too slow and laggy, so I tried the nlinum -mode
;; Line number
;; (global-linum-mode t)
;; (unless window-system
;;   (add-hook 'linum-before-numbering-hook
;;             (lambda ()
;;               (setq-local linum-format-fmt
;;                           (let ((w (length (number-to-string
;;                                             (count-lines (point-min) (point-max))))))
;;                             (concat "%" (number-to-string w) "d"))))))

;; (defun linum-format-func (line)
;;   (concat
;;    (propertize (format linum-format-fmt line) 'face 'linum)
;;    (propertize " " 'face 'mode-line)))

;; (unless window-system
;;   (setq linum-format 'linum-format-func))

(use-package nlinum
  :ensure t
  :config
  (global-nlinum-mode t))

;; Column indicator
(use-package fill-column-indicator
  :ensure t
  :config
  (setq fci-rule-width 1)
  (setq fci-rule-color "white")
  (setq-default fci-rule-column 80)
  :hook
  (prog-mode . fci-mode))

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
  (yas-global-mode 1))

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
  :bind (("C-c l" . org-store-link)
	 ("C-c a" . org-agenda)
	 ("C-c c" . org-capture)
	 ("C-c b" . org-iswitchb)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package helm
  :ensure t
  :bind
  (
   ;; Enable Helm for various scenarios
   ("M-x" . helm-M-x)
   ("C-x b" . helm-mini)
   ("C-x C-f" . helm-find-files))
  :bind (:map helm-map
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package projectile
  :ensure t
  :config
  (projectile-mode)
  (setq projectile-completion-system 'helm))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helm Projectile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on)
  (setq projectile-switch-project-action 'helm-projectile))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Company
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  ;; Set backends for company
  (setq-default company-backends '(company-capf company-keywords))
  ;; Immediately auto compelete (no delay)
  (setq company-idle-delay 0.5)
  ;; Auto complete after 1 char is entered
  (setq company-minimum-prefix-length 1)
  (setq company-show-numbers t))

;;
;; Turn off fci-mode temporarily when company is completing.
;; For that fci-mode can make company tooltip mis-positioned.
;;
(defvar-local company-fci-mode-on-p nil)

(defun company-turn-off-fci (&rest ignore)
  (when (boundp 'fci-mode)
    (setq company-fci-mode-on-p fci-mode)
    (when fci-mode (fci-mode -1))))

(defun company-maybe-turn-on-fci (&rest ignore)
  (when company-fci-mode-on-p (fci-mode 1)))

(add-hook 'company-completion-started-hook 'company-turn-off-fci)
(add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
(add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flycheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flycheck
  :ensure t
  :hook (prog-mode . flycheck-mode))

(use-package flycheck-rtags
  :ensure t
  :config
  (defun flycheck-rtags-setup ()
    (flycheck-select-checker 'rtags)
    ;; RTags creates more accurate overlays.
    (setq-local flycheck-highlighting-mode nil)
    (setq-local flycheck-check-syntax-automatically nil))
  (add-hook 'c-mode-hook #'flycheck-rtags-setup)
  (add-hook 'c++-mode-hook #'flycheck-rtags-setup))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++ Basic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-default c-basic-offset 4)
(defun my-c++-setup () (c-set-offset 'innamespace [0]))
(add-hook 'c++-mode-hook 'my-c++-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RTags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package rtags
  :ensure t
  :config
  (setq rtags-completions-enabled t)
  (setq rtags-autostart-diagnostics t)
  :bind (:map c-mode-base-map
              ("M-." . rtags-find-symbol-at-point)
              ("M-," . rtags-find-references-at-point)))

(use-package helm-rtags
  :ensure t
  :config
  (setq rtags-display-result-backend 'helm))

;; Using sandbox of rtags
(defun get-sbroot-for-dir (dir)
  "Find sandbox root of file for rtags"
  (if (or (not dir) (not (file-accessible-directory-p dir)) (string= dir "/"))
      nil
    (if (file-accessible-directory-p (concat dir ".rtags"))
        dir
      (get-sbroot-for-dir (file-name-directory (directory-file-name dir)))))
  )

(defun get-sbroot-for-buffer ()
  "Find sandbox root of buffer for rtags"
  (let ((f (buffer-file-name (current-buffer))))
    (if (stringp f)
        (get-sbroot-for-dir
         (file-name-directory
          (directory-file-name f)))
      nil)))

(add-hook 'find-file-hook
          (lambda ()
            (if (= (length rtags-socket-file) 0)
                (let ((sbroot (if (buffer-file-name) (get-sbroot-for-buffer) nil))
                      (socket-file nil))
                  (when sbroot
                    (setq socket-file (concat sbroot ".rtags/rdm.socket"))
                    (if (file-exists-p socket-file)
                        (setq rtags-socket-file socket-file)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ycmd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ycmd
  :ensure t
  :hook
  (c-mode . ycmd-mode)
  (c++-mode . ycmd-mode)
  :config
  (set-variable 'ycmd-server-command
                `("python", (file-truename "~/.emacs.d/ycmd/ycmd/")))
  (setq ycmd-extra-conf-handler 'load))

(use-package company-ycmd
  :ensure t
  :config (company-ycmd-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KRM: Keep Rolling Meeting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: Support reading base-time from document attributes
(setq krm-base-time 1530460800) ;; 2018-07-02 00:00:00
(defun krm-calc-timestamp (week day)
  (seconds-to-time (+ krm-base-time (* (+ (* (- week 1) 7) (- day 1)) 86400))))
(defun krm-weektime (week day)
  (concat "W" (number-to-string week) "." (number-to-string day)))
(defun krm-weektime-range (week1 day1 week2 day2)
  (concat (krm-weektime week1 day1) "-" (krm-weektime week2 day2)))
(defun krm-time (week day)
  (concat "<"
          (format-time-string "%Y-%m-%d %a" (krm-calc-timestamp week day))
          ">"))
(defun krm-time-range (week1 day1 week2 day2)
  (concat (krm-time week1 day1) "--" (krm-time week2 day2)))
(defun krm-set-time (week day)
  (interactive "nWeek: \nnDay: ")
  (progn
    (org-entry-put (point) "WEEKTIME" (krm-weektime week day))
    (org-entry-put (point) "TIME" (krm-time week day))))
(defun krm-set-time-range (week1 day1 week2 day2)
  (interactive "nWeek1: \nnDay1: \nnWeek2: \nnDay2: ")
  (progn
    (org-entry-put (point) "WEEKTIME" (krm-weektime-range week1 day1 week2 day2))
    (org-entry-put (point) "TIME" (krm-time-range week1 day1 week2 day2))))

(defun krm-set-owner (owner)
  (interactive "sOwner: ")
  (org-entry-put (point) "OWNER" owner))

(add-hook 'org-mode-hook
  (lambda ()
    (define-key org-mode-map (kbd "C-c C-h t") 'krm-set-time)
    (define-key org-mode-map (kbd "C-c C-h r") 'krm-set-time-range)
    (define-key org-mode-map (kbd "C-c C-h o") 'krm-set-owner)))

(defun krm-headline-append-properties (backend)
  "Append properties into each headline in KRM."
  (org-map-entries
   (lambda () (progn (end-of-line)
                     (insert " ")
                     (insert (or (org-entry-get (point) "WEEKTIME") ""))
                     (insert " ")
                     (insert (or (org-entry-get (point) "OWNER") ""))))))
(add-hook 'org-export-before-parsing-hook 'krm-headline-append-properties)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;; Cellar
;; Stuffs I don't use currently, but maybe valuable in the future.
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
