#lang racket/base
(require racket/list)

(define (ls path)
  (if (directory-exists? path)
      (directory-list path #:build? path)
      '()))

(define (descendants path)
  (append* (list path)
           (map descendants (ls path))))

(module+ main
  (define path (current-directory))
  (for ([el (sort (map path->string (descendants path)))])
    (displayln "asd")))
