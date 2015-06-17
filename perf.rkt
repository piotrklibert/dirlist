#lang racket
(require plot)

(define run-count 10)
(define runnables
  (list
   "/home/cji/projects/klibert_pl/walkfiles/main-cpp"
   "/home/cji/projects/klibert_pl/walkfiles/main-dylan"
   "/home/cji/projects/klibert_pl/walkfiles/main-haxe-cpp"
   "/home/cji/projects/klibert_pl/walkfiles/main-haxe-neko"
   "/home/cji/projects/klibert_pl/walkfiles/main-nim"
   "/home/cji/projects/klibert_pl/walkfiles/main-ocaml"
   "/home/cji/projects/klibert_pl/walkfiles/main-ocamlopt"
   "/home/cji/projects/klibert_pl/walkfiles/main-rkt"
   "/home/cji/projects/klibert_pl/walkfiles/main-py"))


(define-syntax-rule (fold1 fun lst)
  (foldl fun (car lst) (cdr lst)))

(define (basename string-path)
  (let-values ([(base name _) (split-path string-path)])
    (path->string name)))

(define (run-it r)
  (define-values
    (a b ms c)
    (time-apply system (list (string-append  r " >/dev/null"))))
  ms)

(define (get-data)
  (for/list ([r runnables])
    (define times (for/list ([_ run-count])
                    (run-it r)))
    (define avg (exact->inexact
                 (/ (fold1 + times) run-count)))
    (vector (basename r) avg)))



(define (pt-cmp x y)
  (< (vector-ref x 1)
     (vector-ref y 1)))

(define (plot-times data)
  (parameterize ([plot-x-tick-label-anchor 'top-right]
                 [plot-x-tick-label-angle 35])
    (plot (list
           (tick-grid)
           (discrete-histogram data #:y-min 10 #:y-max 400))
          #:y-label "time (milliseconds)" #:x-label #f
          #:out-file (build-path (current-directory)
                                 "perf.png"))))

;; (module+ main
;;   (plot-times (sort (get-data) pt-cmp))
;;   (displayln "Done!"))

(define a (list
           13 'main.rkt
           16 'main.py
           18 'main.tcl
           26 'main.io
           33 'main.nim
           45 'dylan/hello-dylan.dylan
           45 'main.ml
           53 'main.cpp
           77 'Main.hx))

(define (read-lines fname)
  (call-with-input-file fname port->lines))

(require srfi/26)

(define (plot-lines data)
  (parameterize ([plot-x-tick-label-anchor 'top-right]
                 [plot-x-tick-label-angle 35])
    (plot (list
           (tick-grid)
           (discrete-histogram data #:y-min 0 #:y-max 100))
          #:y-label "loc" #:x-label #f
          #:out-file (build-path (current-directory)
                                 "lines.png"))))

(define h (let loop ([lst a]
            [res '()])
   (let/ec return
     (when (< (length lst) 2)
       (return res))

     (let*
         ([fname (symbol->string (cadr lst))]
          [lines (filter (compose (curry < 0) string-length)
                         (read-lines fname))])
       (loop (cddr lst)
             (cons (vector fname (length lines))
                   res))))))

(plot-lines (sort h pt-cmp))
