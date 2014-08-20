;;; flycheck-ocaml.el --- checker for Ocaml


(require 'flycheck)

(defun flycheck-parse-ocamlc (output _checker _buffer)
  "Parse OCaml compiler errors errors from OUTPUT.

Parse error and warning output from the ocamlc compiler.

_CHECKER and _BUFFER are ignored."
  (let* ((lines (s-split "File " output t))
         (file-message-pairs
          (mapcar #'(lambda (line) (s-split "\"" line t)) lines)))
    (mapcar
     #'(lambda (message)
         (let* ((message-no-line (s-chop-prefix ", line " (second message)))
                (line (car (s-match "^[0-9]+" message-no-line)))
                (message-char (s-chop-prefix line message-no-line))
                (message-no-char (s-chop-prefix ", characters " message-char))
                (column (car (s-match "^[0-9]+" message-no-char)))
                (begin (car (s-match "^[0-9]+-[0-9]+:\n" message-no-char)))
                (message-warning (s-chop-prefix begin message-no-char)))
           (flycheck-error-new
            :filename (first message)
            :line (string-to-number line)
            :column (string-to-number column)
            :message message-warning
            :level (if (s-match "^Error" message-warning)
                       'error
                     'warning))))
     file-message-pairs)))

(flycheck-define-checker ocaml-ocamlc
  "An OCaml syntax checker using the ocamlc compiler.

See URL `http://caml.inria.fr/ocaml/index.en.html'."
  :command ("ocamlc" "-w" "+A" source)
  :error-parser flycheck-parse-ocamlc
  :modes (tuareg-mode))

(add-to-list 'flycheck-checkers 'ocaml-ocamlc)

(add-hook 'tuareg-mode (lambda () (flycheck-select-checker 'ocaml-ocamlc)))
