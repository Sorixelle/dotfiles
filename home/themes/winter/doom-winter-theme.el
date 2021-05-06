;;; winter-theme.el --- modified version of doom-themes' Nord light theme -*- no-byte-compile: t; -*-
(require 'doom-themes)

(defgroup doom-winter-theme nil
  "Options for doom-themes"
  :group 'doom-themes)

(defcustom doom-winter-brighter-modeline nil
  "If non-nil, more vivid colors will be used to style the mode-line."
  :group 'doom-winter-theme
  :type 'boolean)

(defcustom doom-winter-brighter-comments nil
  "If non-nil, comments will be highlighted in more vivid colors."
  :group 'doom-winter-theme
  :type 'boolean)

(defcustom doom-winter-comment-bg doom-winter-brighter-comments
  "If non-nil, comments will have a subtle, darker background. Enhancing their
legibility."
  :group 'doom-winter-theme
  :type 'boolean)

(defcustom doom-winter-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line. Can be an integer to
determine the exact padding."
  :group 'doom-winter-theme
  :type '(choice integer boolean))

(defcustom doom-winter-region-highlight t
  "Determines the selection highlight style. Can be 'frost, 'snowstorm or t
(default)."
  :group 'doom-winter-theme
  :type 'symbol)

;;
(def-doom-theme doom-winter
  "A light theme based on my Nixos Winter theme."

  ;; name        default   256       16
  ((bg         '("#f8f8ff" nil       nil))
   (bg-alt     '("#e6e6ed" nil       nil))
   (base0      '("#d5d5dc" "black"   "black"))
   (base1      '("#c4c4ca" "#1e1e1e" "brightblack"))
   (base2      '("#b3b3b9" "#2e2e2e" "brightblack"))
   (base3      '("#a7a7a7" "#262626" "brightblack"))
   (base4      '("#959595" "#3f3f3f" "brightblack"))
   (base5      '("#848484" "#525252" "brightblack"))
   (base6      '("#727272" "#6b6b6b" "brightblack"))
   (base7      '("#616160" "#979797" "brightblack"))
   (base8      '("#4f4f4e" "#dfdfdf" "white"))
   (fg         '("#3e3e3d" "#2d2d2d" "white"))
   (fg-alt     '("#2c2c2b" "#bfbfbf" "brightwhite"))

   (grey base1)
   (red       '("#d07d81" "#ff6655" "red"))
   (orange    '("#c68871" "#dd8844" "brightred"))
   (green     '("#55787e" "#99bb66" "green"))
   (teal      '("#72a1a6" "#44b9b1" "brightgreen"))
   (yellow    '("#c6b2b3" "#ECBE7B" "yellow"))
   (blue      '("#6280a8" "#51afef" "brightblue"))
   (dark-blue '("#35465c" "#2257A0" "blue"))
   (magenta   '("#948586" "#c678dd" "magenta"))
   (violet    '("#cc8f99" "#a9a1e1" "brightmagenta"))
   (cyan      '("#c6d2e1" "#46D9FF" "brightcyan"))
   (dark-cyan '("#7fa8dc" "#5699AF" "cyan"))

   ;; face categories -- required for all themes
   (highlight (doom-blend blue bg 0.8))
   (vertical-bar (doom-darken bg 0.15))
   (selection (doom-blend blue bg 0.5))
   (builtin teal)
   (comments (if doom-winter-brighter-comments dark-cyan (doom-darken base5 0.2)))
   (doc-comments (doom-darken (if doom-winter-brighter-comments dark-cyan base5) 0.25))
   (constants magenta)
   (functions teal)
   (keywords blue)
   (methods teal)
   (operators blue)
   (type yellow)
   (strings green)
   (variables violet)
   (numbers magenta)
   (region (pcase doom-winter-region-highlight
             ((\` frost) (doom-lighten teal 0.5))
             ((\` snowstorm) base0)
             (_ base4)))
   (error red)
   (warning yellow)
   (success green)
   (vc-modified orange)
   (vc-added green)
   (vc-deleted red)

   ;; custom categories
   (hidden `(,(car bg) "black" "black"))
   (-modeline-bright doom-winter-brighter-modeline)
   (-modeline-pad
    (when doom-winter-padded-modeline
      (if (integerp doom-winter-padded-modeline) doom-winter-padded-modeline 4)))

   (modeline-fg nil)
   (modeline-fg-alt base6)

   (modeline-bg
    (if -modeline-bright
        (doom-blend bg blue 0.7)
      `(,(doom-darken (car bg) 0.03) ,@(cdr base0))))
   (modeline-bg-l
    (if -modeline-bright
        (doom-blend bg blue 0.7)
      `(,(doom-darken (car bg) 0.02) ,@(cdr base0))))
   (modeline-bg-inactive (doom-darken bg 0.01))
   (modeline-bg-inactive-l `(,(car bg) ,@(cdr base1))))


  ;; --- extra faces ------------------------
  (((region &override)
    :foreground
    (when (memq doom-winter-region-highlight '(frost snowstorm))
      bg-alt))

   ((lazy-highlight &override) :background (doom-blend teal bg 0.8))
   ((line-number &override) :foreground (doom-lighten 'base5 0.2))
   ((line-number-current-line &override) :foreground base7)
   ((paren-face-match &override) :foreground red :background base0 :weight 'ultra-bold)
   ((paren-face-mismatch &override) :foreground base3 :background red :weight 'ultra-bold)
   ((vimish-fold-overlay &override) :inherit 'font-lock-comment-face :background base3 :weight 'light)
   ((vimish-fold-fringe &override) :foreground teal)
   (font-lock-comment-face
    :foreground comments
    :background (if doom-winter-comment-bg (doom-lighten bg 0.05)))
   (font-lock-doc-face
    :inherit 'font-lock-comment-face
    :foreground doc-comments)

   (doom-modeline-bar :background (if -modeline-bright modeline-bg highlight))

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis
    :foreground (if -modeline-bright base8 highlight))

   (doom-modeline-project-root-dir :foreground base6)
   (solaire-mode-line-face
    :inherit 'mode-line
    :background modeline-bg-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-l)))
   (solaire-mode-line-inactive-face
    :inherit 'mode-line-inactive
    :background modeline-bg-inactive-l
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive-l)))

   ;; elscreen
   (elscreen-tab-other-screen-face :background "#353a42" :foreground "#1e2022")

   (magit-diff-hunk-heading-highlight :foreground bg :background blue :weight 'bold)
   (magit-diff-hunk-heading :foreground bg :background (doom-blend blue bg 0.3))
   (ivy-posframe :background (doom-blend blue bg 0.2))
   (ivy-virtual :foreground (doom-blend blue bg 0.8))
   (ivy-minibuffer-match-face-1 :background nil :foreground (doom-blend fg bg 0.5) :weight 'light)
   (ivy-minibuffer-match-face-2 :background nil :foreground blue)
   (ivy-current-match :background cyan)
   (internal-border :foreground (doom-blend blue bg 0.2) :background (doom-blend blue bg 0.2))
   (company-tooltip :foreground fg :background bg)
   (company-tooltip-search :foreground blue :background bg)
   (company-tooltop-search-selection :foreground dark-cyan)
   (company-preview-common :foreground fg :background cyan)
   (sp-pair-overlay-face :background cyan)
   (diff-removed :background bg-alt)
   ;; --- major-mode faces -------------------
   ;; css-mode / scss-mode
   (css-proprietary-property :foreground orange)
   (css-property :foreground green)
   (css-selector :foreground blue)

   ;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground red)
   ((markdown-code-face &override) :background (doom-lighten base3 0.05))

   (nav-flash-face :background region :foreground base8 :weight 'bold)
   ;; org-mode
   (org-hide :foreground hidden)
   (org-block :background bg-alt)
   (org-block-begin-line :background bg-alt)
   (org-block-end-line :background bg-alt)
   (org-meta-line :foreground dark-cyan)
   (solaire-org-hide-face :foreground hidden))


  ;; --- extra variables ---------------------
  ()
  )

;;; winter-theme.el ends here
