;;; lookup-vars.el --- Lookup variable list
;; Copyright (C) 1999 Lookup Development Team <lookup@ring.gr.jp>

;; Author: Keisuke Nishida <kei@psn.net>
;; Version: $Id: lookup-vars.el.in,v 1.4 2002/10/01 17:05:01 satomi Exp $

;; This file is part of Lookup.

;; Lookup is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; Lookup is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Lookup; if not, write to the Free Software Foundation,
;; Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

;;; Code:

(require 'evi)

(defconst lookup-version "1.4.1"
  "Lookup $B$N%P!<%8%g%sHV9f!#(B")

;;;
;:: Customizable variables
;;;

(defgroup lookup nil
  "Search interface to electronic dictionaries."
  :group 'applications)

(defgroup lookup-agents nil
  "Search agents."
  :group 'lookup)

;; setup variables

(defgroup lookup-setup-variables nil
  "Setup variables."
  :group 'lookup)

(defcustom lookup-enable-splash t
  "*Non-nil $B$r;XDj$9$k$H!"5/F0;~$K%m%4I=<($9$k(B"
  :type 'boolean
  :group 'lookup-general-options)

(defcustom lookup-init-file (concat "~" init-file-user "/.lookup")
  "*Lookup $B$N=i4|2=%U%!%$%kL>!#(B
$B$3$N%U%!%$%k$O(B lookup.el $B$N%m!<%ID>8e$KFI$_9~$^$l$k!#(B"
  :type 'file
  :group 'lookup-setup-variables)

(defcustom lookup-data-directory "/usr/local/share/emacs/lookup"
  "*Lookup $B$K4X$9$k%W%m%0%i%`0J30$N%G!<%?$,<}$a$i$l$k%G%#%l%/%H%j!#(B"
  :type 'directory
  :group 'lookup-setup-variables)

(defcustom lookup-search-agents nil
  "*$B8!:w%(!<%8%'%s%H$N@_Dj$N%j%9%H!#(B
$B%j%9%H$N3FMWAG$O<!$N7A<0$r<h$k(B:

  (CLASS LOCATION [KEY1 VALUE1 [KEY2 VALUE2 [...]]])

CLASS $B$K$O!"%(!<%8%'%s%H$N<oN`$r%7%s%\%k$G;XDj$9$k!#(B
LOCATION $B$K$O!"%(!<%8%'%s%H$N=j:_$rJ8;zNs$G;XDj$9$k!#(B
KEY $B5Z$S(B VALUE $B$O>JN,2DG=$G!"%(!<%8%'%s%H$KBP$9$k%*%W%7%g%s$r;XDj$9$k!#(B

$BNc(B: (setq lookup-search-agents
          '((ndtp \"dserver\" :port 2010)
            (ndeb \"/cdrom\" :enable (\"EIWA\")))))"
  :type '(repeat (sexp :tag "agent"))	; type $B$O$A$g$C$H$d$d$3$7$9$.!&!&(B
  :group 'lookup-setup-variables)

(defcustom lookup-search-modules nil
  "*$B8!:w%b%8%e!<%k$N@_Dj$N%j%9%H!#(B"
  :type '(repeat (cons :tag "Module" (string :tag "name")
		       (repeat :tag "Dictionary" (string :tag "ID"))))
  :group 'lookup-setup-variables)

(defcustom lookup-default-agent-options nil
  "*$B8!:w%(!<%8%'%s%H$K%G%U%)%k%H$GM?$($k%*%W%7%g%s$N%j%9%H!#(B
$B3F%*%W%7%g%s$O!"%?%0$H$J$k%7%s%\%k$H!"CM$H$J$kG$0U$N%*%V%8%'%/%H$H$N(B
cons $B$K$h$C$FI=$o$9!#(B"
  :type '(repeat (cons :tag "option" (symbol :tag "tag") (sexp :tag "value")))
  :group 'lookup-setup-variables)

(defcustom lookup-agent-options-alist nil
  "*$B8!:w%(!<%8%'%s%H$N%*%W%7%g%s$r@_Dj$9$kO"A[%j%9%H!#(B
$B3FMWAG$N(B car $B$K$O%(!<%8%'%s%H(BID(\"CLASS+LOCATION\")$B$r;XDj$7!"(B
cdr $B$K$O%*%W%7%g%s$N%j%9%H$r;XDj$9$k!#(B"
  :type '(repeat (cons :tag "Agent"
		       (string :tag "ID")
		       (repeat :tag "options" (cons :tag "option"
						    (symbol :tag "tag")
						    (sexp :tag "value")))))
  :group 'lookup-setup-variables)

(defcustom lookup-default-dictionary-options nil
  "*$B<-=q$K%G%U%)%k%H$GM?$($k%*%W%7%g%s$N%j%9%H!#(B
$B3F%*%W%7%g%s$O!"%?%0$H$J$k%7%s%\%k$H!"CM$H$J$kG$0U$N%*%V%8%'%/%H$H$N(B
cons $B$K$h$C$FI=$o$9!#(B"
  :type '(repeat (cons :tag "option" (symbol :tag "tag") (sexp :tag "value")))
  :group 'lookup-setup-variables)

(defcustom lookup-dictionary-options-alist nil
  "*$B<-=q$N%*%W%7%g%s$r@_Dj$9$kO"A[%j%9%H!#(B
$B3FMWAG$N(B car $B$K$O<-=q(BID(\"CLASS+LOCATION:NAME\")$B$r;XDj$7!"(B
cdr $B$K$O%*%W%7%g%s$N%j%9%H$r;XDj$9$k!#(B"
  :type '(repeat (cons :tag "Dictionary"
		       (string :tag "ID")
		       (repeat :tag "options" (cons :tag "option"
						    (symbol :tag "tag")
						    (sexp :tag "value")))))
  :group 'lookup-setup-variables)

;; general options

(defgroup lookup-general-options nil
  "General customizable variables."
  :group 'lookup)

(defcustom lookup-default-method 'exact
  "*\\[lookup-pattern] $B$G<B9T$5$l$kI8=`$N8!:wJ}<0!#(B
$BJQ?t(B `lookup-word-search-methods' $B$N$$$:$l$+$NCM$r;XDj2DG=!#(B"
  :type 'symbol
  :group 'lookup-general-options)

(defcustom lookup-frame-alist
  '((title . "Lookup") (menu-bar-lines . 0) (width . 48) (height . 32)
    (lookup-fill-column . 45))
  "*Lookup $B@lMQ%U%l!<%`$N%Q%i%a!<%?$N%j%9%H!#(B
$B@_Dj$9$Y$-CM$K$D$$$F$O!"(B`default-frame-alist' $B$r;2>H!#(B"
  :type '(repeat (cons :tag "Parameter"
		       (symbol :tag "tag")
		       (sexp :tag "value")))
  :group 'lookup-general-options)

(defcustom lookup-fill-column .9
  "*$B%(%s%H%jFbMF$r(B fill $B$9$k$H$-$N7e?t!#(B
$B>.?t$r;XDj$7$?>l9g$O!"%&%#%s%I%&$NI}$KBP$9$k3d9g$H$7$FMQ$$$i$l$k!#(B"
  :type 'number
  :group 'lookup-general-options)

(defcustom lookup-window-height 4
  "*Entry $B%P%C%U%!Ey$N%&%#%s%I%&$N9b$5!#(B
$B>.?t$r;XDj$7$?>l9g$O!"(BLookup $BA4BN$N%&%#%s%I%&$N9b$5$KBP$9$k3d9g$H$7$F(B
$BMQ$$$i$l$k!#(B"
  :type 'number
  :group 'lookup-general-options)

(make-variable-frame-local 'lookup-fill-column)
(make-variable-frame-local 'lookup-window-height)

(defcustom lookup-save-configuration t
  "*Non-nil $B$r;XDj$9$k$H!"(BLookup $B$rH4$1$?$H$-$K%&%#%s%I%&>uBV$r2sI|$9$k!#(B"
  :type 'boolean
  :group 'lookup-general-options)

(defcustom lookup-use-bitmap 
  (and (featurep 'bitmap)
       (or (not (featurep 'image))
	   (not (image-type-available-p 'xbm))))
  "*Non-nil $B$r;XDj$9$k$H!"(Bbitmap-mule $B%Q%C%1!<%8$rMxMQ$7$?30;zI=<($r9T$J$&!#(B"
  :type 'boolean
  :group 'lookup-general-options)

(defcustom lookup-use-kakasi (or (locate-library "kakasi" nil exec-path)
				 (locate-library "kakasi.exe" nil exec-path))
  "*Non-nil $B$r;XDj$9$k$H!"$$$/$D$+$N6ILL$G(B KAKASI $B$,MxMQ$5$l$k!#(B
$B$3$l$O8=:_!"6qBNE*$K$OF|K\8l$N%G%U%)%k%H$N8!:w8l$N@Z$j=P$7$KMQ$$$F$$$k!#(B"
  :type 'boolean
  :group 'lookup-general-options)

(defcustom lookup-enable-gaiji t
  "*Non-nil $B$r;XDj$9$k$H!"30;zI=<($,M-8z$H$J$k!#(B"
  :type 'boolean
  :group 'lookup-general-options)

(defcustom lookup-max-hits 50
  "*$B8!:w;~$KI=<($9$k%(%s%H%j$N:GBg?t!#(B
0 $B$r;XDj$9$k$H!"8+$D$+$C$?A4$F$N%(%s%H%j$rI=<($9$k!#(B"
  :type 'integer
  :group 'lookup-general-options)

(defcustom lookup-max-text 100000
  "*$B8!:w;~$KI=<($9$k%(%s%H%jK\J8$N:GBgD9!#(B
0 $B$r;XDj$9$k$H!"A4J8$rI=<($9$k!#(B"
  :type 'integer
  :group 'lookup-general-options)

(defcustom lookup-cite-header nil
  "*$B%(%s%H%jK\J8$r0zMQ$9$k$H$-$N%X%C%@!#(B
$B%3%^%s%I(B `lookup-entry-cite-content' $B5Z$S(B `lookup-content-cite-region'
$B$K$h$jFbMF$r<h$j9~$`$H$-!"$=$N@hF,$K;XDj$7$?J8;zNs$,IU$12C$($i$l$k!#(B
$BJ8;zNs$,(B \"%T\" $B$r4^$`>l9g!"<-=q$N%?%$%H%k$KCV$-49$($i$l$k!#(B
$B<-=q%*%W%7%g%s(B `cite-header' $B$,;XDj$5$l$F$$$k>l9g!"$=$A$i$,M%@h$5$l$k!#(B"
  :type 'string
  :group 'lookup-general-options)

(defcustom lookup-cite-prefix nil
  "*$B%(%s%H%jK\J8$r0zMQ$9$k$H$-$N%W%l%U%#%/%9!#(B
$B%3%^%s%I(B `lookup-entry-cite-content' $B5Z$S(B `lookup-content-cite-region'
$B$K$h$jFbMF$r<h$j9~$`$H$-!"3F9T$N@hF,$K;XDj$7$?J8;zNs$,IU$12C$($i$l$k!#(B
$B<-=q%*%W%7%g%s(B `cite-preifx' $B$,;XDj$5$l$F$$$k>l9g!"$=$A$i$,M%@h$5$l$k!#(B"
  :type 'string
  :group 'lookup-general-options)

(defcustom lookup-gaiji-alternate "_"
  "*$B30;z$NBeBXJ8;zNs$H$7$FMQ$$$i$l$k%G%U%)%k%H$NJ8;zNs!#(B"
  :type 'string
  :group 'lookup-general-options)

(defcustom lookup-process-coding-system
  (when (featurep 'evi-mule)
    (if (memq system-type '(ms-dos windows-nt OS/2 emx))
	(evi-coding-system 'sjis)
      (evi-coding-system 'euc-jp)))
  "*$B30It%W%m%;%9$H$N%G%U%)%k%H$NJ8;z%3!<%I!#(B"
  :type 'symbol
  :group 'lookup-general-options)

(defcustom lookup-kakasi-coding-system lookup-process-coding-system
  "*KAKASI $B$N8F$S=P$7$KMQ$$$kJ8;z%3!<%I!#(B"
  :type 'symbol
  :group 'lookup-general-options)

(defcustom lookup-inline-image t
  "t $B$J$i$P(B ($B2DG=$J>l9g$K(B) $B2hA|$rI=<($9$k!#(B"
  :type 'boolean
  :group 'lookup-general-options)

;; faces

(defgroup lookup-faces nil
  "Faces."
  :group 'lookup)

(defface lookup-splash-face
    '((((class color) (background light)) (:foreground "Red"))
      (((class color) (background dark)) (:foreground "Yellow")))
  "Splash face."
  :group 'lookup-faces)

(defface lookup-heading-1-face
    '((((class color) (background light)) (:foreground "SlateBlue" :bold t))
      (((class color) (background dark)) (:foreground "LightBlue" :bold t)))
  "Level 1 heading face."
  :group 'lookup-faces)

(defface lookup-heading-2-face
  '((((class color) (background light)) (:foreground "Red" :bold t))
    (((class color) (background dark)) (:foreground "Pink" :bold t)))
  "Level 2 heading face."
  :group 'lookup-faces)

(defface lookup-heading-3-face
  '((((class color) (background light)) (:foreground "Orange" :bold t))
    (((class color) (background dark)) (:foreground "LightSalmon" :bold t)))
  "Level 3 heading face."
  :group 'lookup-faces)

(defface lookup-heading-4-face
  '((t (:bold t)))
  "Level 4 heading face."
  :group 'lookup-faces)

(defface lookup-heading-5-face
  '((t nil))
  "Level 5 heading face."
  :group 'lookup-faces)

(defface lookup-heading-low-face
  '((((class color) (background light)) (:foreground "Grey" :bold t))
    (((class color) (background dark)) (:foreground "LightGrey" :bold t)))
  "Low level heading face."
  :group 'lookup-faces)

(defface lookup-reference-face
  '((((class color) (background light)) (:foreground "Blue" :bold t))
    (((class color) (background dark)) (:foreground "Cyan" :bold t)))
  "Face used to highlight reference."
  :group 'lookup-faces)

(defface lookup-refered-face
  '((((class color) (background light)) (:foreground "DarkViolet" :bold t))
    (((class color) (background dark)) (:foreground "Plum" :bold t)))
  "Face used to highlight refered reference."
  :group 'lookup-faces)

;;;
;:: Module variables
;;;

(defvar lookup-search-method nil
  "$B8!:wJ}<0$r;XDj$9$k$H!"F~NO$r%Q!<%9$;$:$=$l$r$=$N$^$^MQ$$$k!#(B")

(defvar lookup-enable-format t
  "Non-nil $B$r;XDj$9$k$H!"%F%-%9%H$r@07A$7$F=PNO$9$k!#(B")

(defvar lookup-force-update nil
  "Non-nil $B$r;XDj$9$k$H!"%-%c%C%7%e$rMQ$$$:6/@)E*$K:F8!:w$r9T$J$&!#(B")

(defvar lookup-open-function 'lookup-other-window
  "Lookup $B$N%&%#%s%I%&$rI=<($9$k$?$a$NI8=`$N4X?t!#(B
$B<!$N;0$D$N$$$:$l$+$r;XDj2DG=!#(B

`lookup-full-screen'  - $B8!:w7k2L$r2hLLA4BN$GI=<($9$k(B
`lookup-other-window' - $B8!:w7k2L$rJL$N%&%#%s%I%&$GI=<($9$k(B
`lookup-other-frame'  - $B8!:w7k2L$rJL$N%U%l!<%`$GI=<($9$k(B")

;;;
;:: Hooks
;;;

(defvar lookup-load-hook nil
  "*Lookup $B$N%m!<%I40N;D>8e$K<B9T$5$l$k(B hook$B!#(B
`lookup-init-file' $B$NFI$_9~$_D>8e$K<B9T$5$l$k!#(B")

;;;
;:: Debug option
;;;

;; Lookup $B$r%G%P%C%0$KE,$7$?7A$G<B9T$9$k$K$O!"JQ?t(B `lookup-debug-mode' $B$r(B
;; non-nil $B$K@_Dj$9$k!#$3$N>l9g!"<!$N5!G=$,F/$/!#(B
;; 
;; * $B%W%m%;%9$N<B9T2aDx$,%P%C%U%!$KJ]B8$5$l$k!#Nc$($P(B ndtp $B$N>l9g!"A4$F$N(B
;; $B$d$j$H$j$,%P%C%U%!(B " *ndtp*" $B$K5-O?$5$l$k!#(B
;; 
;; * $B3F<o%G!<%?9=B$$NB0@-%j%9%H$NI=<($,M^@)$5$l$k!#$3$l$K$h$j!"JQ?t$NCM$N(B
;; $B=PNO$,M^$($i$l!">pJs$,8+$d$9$/$J$k!#(B`lookup-new-plist' $B$r;2>H!#$3$l$r(B
;; $BM-8z$H$9$k$K$O(B `lookup-debug-mode' $B$r(B ~/.emacs $B$G@_Dj$7$J$1$l$P$J$i$J$$!#(B

(defvar lookup-debug-mode nil)

;;;
;:: Internal variables
;;;

(defvar lookup-agent-list nil)
(defvar lookup-agent-alist nil)
(defvar lookup-module-list nil)
(defvar lookup-module-alist nil)
(defvar lookup-dictionary-alist nil)

(defvar lookup-default-module nil)
(defvar lookup-current-session nil)
(defvar lookup-last-session nil)

(defvar lookup-buffer-list nil)
(defvar lookup-search-pattern nil)
(defvar lookup-search-found nil)
(defvar lookup-dynamic-display nil)
(defvar lookup-proceeding-message nil)
(defvar lookup-window-configuration nil)
(defvar lookup-byte-compile nil)

(defvar lookup-gaiji-compose-function nil)
(defvar lookup-gaiji-paste-function nil)

(defun lookup-init-gaiji-functions ()
  (cond (lookup-use-bitmap
	 (setq lookup-gaiji-compose-function 'lookup-bitmap-compose
	       lookup-gaiji-paste-function 'lookup-bitmap-paste))
	((or (featurep 'xemacs)
	     (and (featurep 'image)
		  (image-type-available-p 'xbm)))
	 (setq lookup-gaiji-compose-function 'lookup-glyph-compose
	       lookup-gaiji-paste-function 'lookup-glyph-paste))
	(t
	 (setq lookup-gaiji-compose-function nil
	       lookup-gaiji-paste-function 'lookup-bitmap-paste))))

(provide 'lookup-vars)

;;; lookup-vars.el ends here

;;; Local variables:
;;; mode:emacs-lisp
;;; End:
