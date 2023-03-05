#lang racket

(require racket/gui/base)
(require racket/draw)
;vector
(define (make-vect x y) (cons x y))
(define (xcor vect) (car vect))
(define (ycor vect) (cdr vect))
;curves
(define (make-curve p1 p2 p3 p4) (list p1 p2 p3 p4))
(define (start-curve cur) (car cur))
(define (control-curve cur) (cadr cur))
(define (2nd-control-curve cur) (caddr cur))
(define (end-curve cur) (cadddr cur))
;rect
(define make-rectangle list)
( define origin ( make-vect 0 0) )
( define x-axis ( make-vect 730 0) )
( define y-axis ( make-vect  0 730) )
( define frame1 ( make-rectangle origin x-axis y-axis ) )
(define (first frame) (car frame))
(define (second frame) (car (cdr frame)))
(define (third frame) (car (cdr (cdr frame))))
;segment
(define (make-segment p1 p2) (cons p1 p2))
(define (start-segment seg) (car seg))
(define (end-segment seg) (cdr seg))

;operation
(define (+vect v1 v2)
(make-vect (+ (xcor v1) (xcor v2))
(+ (ycor v1) (ycor v2))))
(define (-vect v1 v2)
(+vect v1 (scale-vect v2 -1 )))
(define (rotate-vect v angle)
  (let ((c (cos angle))
        (s (sin angle)))
    (make-vect (- (* c (xcor v))
              (* s (ycor v)))
               (+ (* c (ycor v))
                  (* s (xcor v))))))
(define (scale-vect vect factor)
  (make-vect (* factor (xcor vect))
(* factor (ycor vect))))
(define (coord-map rect)(lambda(p)(+vect (first rect)(+vect (scale-vect (second rect)(xcor p)) (scale-vect (third rect)(ycor p))))))
(define (repeat func n x)(
if(= n 0)
  x
  (func (repeat func (- n 1) x))))
;(define (rotate90 pict)(lambda(rect)(pict (make-rectangle (+vect (first rect) (second rect)) (third rect)(scale-vect (second rect) -1)))))
(define (draw-line f)(lambda(lst)
                       (let* ((x (start-segment lst)) (y (end-segment  lst)) (c (make-rectangle (f x) (f y))) )
                         (send dc draw-line (xcor (xcor c)) (ycor (xcor c)) (xcor (xcor (cdr c))) (ycor(xcor (cdr c)))))))
(define (make-picture seglist)
(lambda (rect)(let*((z(coord-map rect)) (f(draw-line z)) )
           (for-each f seglist))))
(define (vect-eq? vect n)(if(and (= (car vect) (car n)) (= (cdr vect) (cdr n)) )
                            #f
                            #t
                            ))

;fish
(define p1 (make-vect 0 0))
(define p2 (make-vect 0 1))
(define p3 (make-vect 1 0))


(define fish-curves
	(list(make-segment p1 p2)
             (make-segment p2 p3)
              (make-segment p3 p1)))
;-----------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------
(define (rotate-helper rect angle)(
                                   cond ((< angle 0) rect) 
                                        ((= angle 0) rect)
                                        ((> (* pi 0.5) angle)
                                         (make-rectangle
                                          (+vect (first rect) (scale-vect(+vect(second rect) (third rect)) 0.5))
                                          (scale-vect(+vect(second rect) (third rect) )0.5)
                                          (scale-vect(+vect(third rect) (scale-vect  (second rect) -1 )) 0.5)
                                          ))
                                    (else (rotate-helper (make-rectangle (+vect (first rect) (second rect)) (third rect)(scale-vect (second rect) -1)) (- angle (* pi 0.5))))))
( define ( rotate pict angle )
( lambda ( rect )(pict (rotate-helper rect angle))))
( define ( rotate90 pict )( rotate pict (* pi 0.5)))
(define (flip pic)(lambda(rect) (pic (make-rectangle (+vect (first rect) (second rect)) (scale-vect (second rect) -1) (third rect)))))
( define ( above-rotate45 pict )
( lambda ( rect )((rotate pict (* pi 0.25))rect)))
;------------------------------------------------------------------------------------------------------------------------------------------------------------------
( define ( make-picture-from-curve curvelist )(make-picture curvelist))
( define ( together4 pict1 pict2 pict3 pict4 ) ( lambda ( rect )
( pict1 rect ) ( pict2 rect ) ( pict3 rect ) ( pict4 rect ) ) )
( define fish ( make-picture-from-curve fish-curves ) )
( define fish2 ( flip ( above-rotate45 fish ) ) )
( define fish3 ( rotate fish2 (* 0.5 pi ) ) )
( define fish4 ( rotate fish2 (* 1.0 pi ) ) )
( define fish5 ( rotate fish2 (* 1.5 pi ) ) )
( define fish-tile ( together4 fish2 fish3 fish4 fish5 ) )
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
(define (beside pic1 pic2 x )(lambda(rect)(pic1 (make-rectangle (first rect)(scale-vect (second rect) x) (third rect)))
                               (pic2 (make-rectangle (+vect (first rect) (scale-vect (second rect) x)) (scale-vect (second rect) (- 1 x)) (third rect)))))
(define (above pic1 pic2 x )(lambda(rect)((repeat rotate90 3 (beside (rotate90 pic1)  (rotate90 pic2) x))rect)))
( define ( quardtet p q r s )(above (beside p q 0.5) (beside r s 0.5) 0.5))
( define ( nonet p q r s t u v w x ) (above (above (beside (beside v w 0.5) x (/ 2 3)) (beside (beside s t 0.5) u (/ 2 3)) (/ 1.5 3))
                                            (beside (beside p q 0.5) r (/ 2 3)) (/ 2 3)))
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
( define empty-picture ( make-picture-from-curve (list (make-vect (make-vect 0 0) (make-vect 0 0)) ) ))
( define ( side-push pict n )
   (if (<= n 0) empty-picture
       (quardtet ( side-push pict (- n 1) ) ( side-push pict (- n 1) )  (rotate90  pict) pict)))
( define ( corner-push pict n ) (if (<= n 0) empty-picture
                                    (quardtet  (side-push pict (- n 1)) ( corner-push pict (- n 1) ) pict (repeat rotate90 3 (side-push pict (- n 1))))))
( define fish-side-push ( side-push fish-tile 2) )
( define fish-corner-push ( corner-push fish-tile 2) )
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
(define (square-limit pict n)
(let* ((x (corner-push pict n)) (y (side-push pict n)))
  (nonet
   (repeat rotate90 2 x) (repeat rotate90 2 y) (repeat rotate90 3 x)
   (rotate90 y) pict (repeat rotate90 3 y)
   (rotate90 x) y x)))
( define fish-square-limit ( square-limit fish-tile 2) )
;----------------------------------------------------------------------------------------------------------------------------------------------------
;========================= Picture ==============================(rotate pict (* pi 0.25)) (+vect (first rect) (-vect (third rect) (scale-vect (third rect) (/ 1 (sqrt 2)))))
; DEFINE CALLBACK PAINT PROCEDURE
(define fish-t(above-rotate45 fish))
;(define (on-paint) (fish  frame1))
;canvas

(define frame (new frame% [label "Paint George"]
                   [width 747]
                   [height 769]))
(define canvas (new canvas% [parent frame]
                    [paint-callback
                     (lambda(canvas dc)
                       (send dc set-pen red-pen)
                       (send dc set-brush no-brush)
                       (on-paint)
                       )]))
(define red-pen (make-object pen% "RED" 2 'solid))
(define no-brush (make-object brush% "BLACK" 'transparent))
(define dc (send canvas get-dc))

(define (on-paint)( fish-square-limit frame1))
;MAKING THE FRAME VISIBLE
(send frame show #t)