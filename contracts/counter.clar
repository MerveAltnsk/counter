;; Define a constant for the maximum allowed count
(define-constant MAX-COUNT u100)

;; Map to store each user's individual count
(define-map counters principal uint)

;; Data variable to track total number of operations
(define-data-var total-ops uint u0)

;; Read-only function to get the count for a specific user
(define-read-only (get-count (who principal))
  (default-to u0 (map-get? counters who))
)

;; Read-only function to get total number of operations performed
(define-read-only (get-total-operations)
  (var-get total-ops)
)

;; Private function to increment total operations counter
(define-private (update-total-ops)
  (var-set total-ops (+ (var-get total-ops) u1))
)

;; Public function to increment the caller's count
(define-public (count-up)
  (let ((current-count (get-count tx-sender)))
    (asserts! (< current-count MAX-COUNT) (err u1)) ;; Error u1: max count reached
    (update-total-ops)
    (map-set counters tx-sender (+ current-count u1))
    (ok (+ current-count u1))
  )
)

;; Public function to decrement the caller's count
(define-public (count-down)
  (let ((current-count (get-count tx-sender)))
    (asserts! (> current-count u0) (err u2)) ;; Error u2: already zero
    (update-total-ops)
    (map-set counters tx-sender (- current-count u1))
    (ok (- current-count u1))
  )
)

;; Public function to reset the caller's count to zero
(define-public (reset-count)
  (begin
    (update-total-ops)
    (map-set counters tx-sender u0)
    (ok u0)
  )
)
