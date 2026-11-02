;; .myemacs  -*- lexical-binding: nil; -*-

;; configure colors for a terminal with dark background
(setq frame-background-mode 'dark)

;; configure indentation settings
;;;; define custom variables
(setq default-tab-width 2)
(setq show-tab-as-width 4)
(setq python-tab-width 4)
;;;; configure default settings
;;;;;; do not use \t character, so implicitly tells to use spaces
(setq-default indent-tabs-mode nil)
;;;;;; indent with `tab-width` spaces
(setq-default tab-width default-tab-width)
;;;;;; use the size of `tab-width` spaces to represent 1 \t
(setq tab-stop-list (number-sequence show-tab-as-width 200 show-tab-as-width))
;;;; configure settings per language/mode
;;;; NOTE: Unfortunately emacs does not allow force configuring a global setting
(add-hook 'c-mode-common-hook '(lambda () (setq c-basic-offset default-tab-width))) ; c, c++, java, objective-c, idl, pike, awk
(add-hook 'sh-mode-hook '(lambda () (setq sh-basic-offset default-tab-width))) ; sh, bash, etc
(add-hook 'python-mode-hook '(lambda () (setq python-indent python-tab-width))) ; python

(add-to-list 'load-path "~/.emacs.d/s")
(add-to-list 'load-path "~/.emacs.d/ocaml")
(add-to-list 'load-path "~/.emacs.d/sym-lock")
(add-to-list 'load-path "~/.emacs.d/whitespace")
(add-to-list 'load-path "~/.emacs.d/qml")
(add-to-list 'load-path "~/.emacs.d/php")
(add-to-list 'load-path "~/.emacs.d/debug")
(add-to-list 'load-path "~/.emacs.d/arduino-mode")
(add-to-list 'load-path "~/.emacs.d/dockerfile-mode")
;; (load-file "~/.emacs.d/arduino-mode/arduino-mode.el")

(autoload 'php-mode "php-mode" "Major mode for editing php code." t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

(add-to-list 'auto-mode-alist '("\\.phtml" . html-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . html-mode))
;; (add-to-list 'auto-mode-alist '("\\.php[34]?\\'" . html-mode))
;; (add-to-list 'auto-mode-alist '("\\.[sj]?html?\\'" . html-mode))
;; (add-to-list 'auto-mode-alist '("\\.jsp\\'" . html-mode))
;; (add-to-list 'auto-mode-alist '("\\.inc\\'" . html-mode))

;; Blank end-of-line auto removal with ("~/.emacs.d/whitespace")
(setq show-trailing-whitespace t)
(setq-default show-trailing-whitespace t)

;; Select + up
(define-key input-decode-map "\e[1;2A" [S-up])

;; Enable QML
(require 'qml-mode)

;; Enable Docker
;; https://domeide.github.io/
;; https://github.com/spotify/dockerfile-mode
;(require 'dockerfile-mode)
;(add-to-list 'auto-mode-alist '("Dockerfile" . dockerfile-mode))

;; Enable upper/lower case functionalities
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Case.html
;; https://kb.iu.edu/d/abis
;;;; NOTES:
;;;; - Select region and convert it
;;;;   To upper case: M-x upcase-region OR C-x C-u
;;;;   To lower case: M-x downcase-region OR C-x C-l
;;;;   Capitalize: M-x capitalize-region
;;;; - Convert the following word
;;;;   To upper case: M-u
;;;;   To lower case: M-l
;;;;   Capitalize: M-c
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
