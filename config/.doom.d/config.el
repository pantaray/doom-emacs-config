;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Stefan Fuertinger"
      user-mail-address "stefan.fuertinger@esi-frankfurt.de")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-opera-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; For GWDG CoCo AI configuration, see:
;; https://docs.hpc.gwdg.de/services/ai-services/coco/index.html#emacs
(after! doom
  (cua-mode +1)
  (global-display-fill-column-indicator-mode +1)
  (setq doom-leader-alt-key "M-,"
        doom-localleader-alt-key "M-, m"
        kill-whole-line t
        gptel-model 'qwen3-coder-30b-a3b-instruct
        gptel-backend
        (gptel-make-openai "gwdg"
          :host "chat-ai.academiccloud.de"
          :endpoint "/v1/chat/completions"
          :stream t
          :key gptel-api-key
          :models '(qwen3-coder-30b-a3b-instruct
                    meta-llama-3.1-8b-instruct
                    openai-gpt-oss-120b
                    gemma-3-27b-it
                    qwen3-30b-a3b-thinking-2507
                    qwen3-30b-a3b-instruct-2507
                    qwen3-32b
                    qwen3-235b-a22b
                    llama-3.3-70b-instruct
                    qwen2.5-vl-72b-instruct
                    medgemma-27b-it
                    qwq-32b
                    deepseek-r1
                    deepseek-r1-distill-llama-70b
                    mistral-large-instruct
                    qwen2.5-coder-32b-instruct
                    internvl2.5-8b
                    teuken-7b-instruct-research
                    codestral-22b
                    llama-3.1-sauerkrautlm-70b-instruct
                    meta-llama-3.1-8b-rag
                    qwen2.5-omni-7
                    )
          )
        ;; gptel-model 'gemini-2.5-flash
        ;; gptel-backend (gptel-make-gemini "Gemini" :stream t :key gptel-api-key)
        doom-font (font-spec :size 11.0 )))
