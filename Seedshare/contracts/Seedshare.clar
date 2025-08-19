;; Community Garden Resource Allocation Contract
;; A tokenized community garden management system that distributes seeds and tools transparently, preventing double claims and ensuring fairness

;; Define errors
(define-constant GARDEN-COORDINATOR tx-sender)
(define-constant ERROR-NOT-GARDEN-COORDINATOR (err u100))
(define-constant ERROR-RESOURCES-ALREADY-CLAIMED (err u101))
(define-constant ERROR-GARDENER-NOT-APPROVED (err u102))
(define-constant ERROR-INSUFFICIENT-GARDEN-RESOURCES (err u103))
(define-constant ERROR-SEASON-NOT-ACTIVE (err u104))
(define-constant ERROR-INVALID-RESOURCE-ALLOCATION (err u105))
(define-constant ERROR-HARVEST-PERIOD-NOT-ENDED (err u106))
(define-constant ERROR-INVALID-GARDENER (err u107))
(define-constant ERROR-INVALID-GROWING-PERIOD (err u108))

;; Define data variables
(define-data-var is-season-active bool true)
(define-data-var total-resources-distributed uint u0)
(define-data-var resource-allocation-per-gardener uint u100)
(define-data-var season-start-block uint stacks-block-height)
(define-data-var harvest-season-length uint u10000) ;; Number of blocks after which unused resources can be reclaimed

;; Define data maps
(define-map approved-garden-members principal bool)
(define-map distributed-resource-amounts principal uint)

;; Define fungible token
(define-fungible-token garden-resource-token)

;; Define events
(define-data-var next-activity-id uint u0)
(define-map garden-activities uint {activity-type: (string-ascii 20), description: (string-ascii 256)})

;; Activity logging function
(define-private (log-garden-activity (activity-type (string-ascii 20)) (description (string-ascii 256)))
  (let ((activity-id (var-get next-activity-id)))
    (map-set garden-activities activity-id {activity-type: activity-type, description: description})
    (var-set next-activity-id (+ activity-id u1))
    activity-id))

;; Coordinator functions

(define-public (approve-gardener (gardener-address principal))
  (begin
    (asserts! (is-eq tx-sender GARDEN-COORDINATOR) ERROR-NOT-GARDEN-COORDINATOR)
    (asserts! (is-none (map-get? approved-garden-members gardener-address)) ERROR-INVALID-GARDENER)
    (log-garden-activity "gardener-approved" "new member approved for garden")
    (ok (map-set approved-garden-members gardener-address true))))

(define-public (revoke-gardener-approval (gardener-address principal))
  (begin
    (asserts! (is-eq tx-sender GARDEN-COORDINATOR) ERROR-NOT-GARDEN-COORDINATOR)
    (asserts! (is-some (map-get? approved-garden-members gardener-address)) ERROR-GARDENER-NOT-APPROVED)
    (log-garden-activity "approval-revoked" "gardener membership revoked")
    (ok (map-delete approved-garden-members gardener-address))))

(define-public (bulk-approve-gardeners (gardener-addresses (list 200 principal)))
  (begin
    (asserts! (is-eq tx-sender GARDEN-COORDINATOR) ERROR-NOT-GARDEN-COORDINATOR)
    (log-garden-activity "bulk-approval" "multiple gardeners approved")
    (ok (map approve-gardener gardener-addresses))))

(define-public (update-resource-allocation (new-allocation uint))
  (begin
    (asserts! (is-eq tx-sender GARDEN-COORDINATOR) ERROR-NOT-GARDEN-COORDINATOR)
    (asserts! (> new-allocation u0) ERROR-INVALID-RESOURCE-ALLOCATION)
    (var-set resource-allocation-per-gardener new-allocation)
    (log-garden-activity "allocation-updated" "resource allocation per gardener changed")
    (ok new-allocation)))

(define-public (update-harvest-period (new-period uint))
  (begin
    (asserts! (is-eq tx-sender GARDEN-COORDINATOR) ERROR-NOT-GARDEN-COORDINATOR)
    (asserts! (> new-period u0) ERROR-INVALID-GROWING-PERIOD)
    (var-set harvest-season-length new-period)
    (log-garden-activity "period-updated" "harvest period length changed")
    (ok new-period)))

;; Resource distribution function

(define-public (claim-garden-resources)
  (let (
    (gardener-address tx-sender)
    (allocation-amount (var-get resource-allocation-per-gardener))
  )
    (asserts! (var-get is-season-active) ERROR-SEASON-NOT-ACTIVE)
    (asserts! (is-some (map-get? approved-garden-members gardener-address)) ERROR-GARDENER-NOT-APPROVED)
    (asserts! (is-none (map-get? distributed-resource-amounts gardener-address)) ERROR-RESOURCES-ALREADY-CLAIMED)
    (asserts! (<= allocation-amount (ft-get-balance garden-resource-token GARDEN-COORDINATOR)) ERROR-INSUFFICIENT-GARDEN-RESOURCES)
    (try! (ft-transfer? garden-resource-token allocation-amount GARDEN-COORDINATOR gardener-address))
    (map-set distributed-resource-amounts gardener-address allocation-amount)
    (var-set total-resources-distributed (+ (var-get total-resources-distributed) allocation-amount))
    (log-garden-activity "resources-claimed" "garden resources distributed to member")
    (ok allocation-amount)))

;; Token reclaim function

(define-public (reclaim-unused-resources)
  (let (
    (current-block stacks-block-height)
    (reclaim-allowed-after (+ (var-get season-start-block) (var-get harvest-season-length)))
  )
    (asserts! (is-eq tx-sender GARDEN-COORDINATOR) ERROR-NOT-GARDEN-COORDINATOR)
    (asserts! (>= current-block reclaim-allowed-after) ERROR-HARVEST-PERIOD-NOT-ENDED)
    (let (
      (total-minted (ft-get-supply garden-resource-token))
      (total-distributed (var-get total-resources-distributed))
      (unused-amount (- total-minted total-distributed))
    )
      (try! (ft-burn? garden-resource-token unused-amount GARDEN-COORDINATOR))
      (log-garden-activity "resources-reclaimed" "unused garden resources burned")
      (ok unused-amount))))

;; Read-only functions

(define-read-only (get-season-active-status)
  (var-get is-season-active))

(define-read-only (is-gardener-approved (gardener-address principal))
  (default-to false (map-get? approved-garden-members gardener-address)))

(define-read-only (has-gardener-claimed-resources (gardener-address principal))
  (is-some (map-get? distributed-resource-amounts gardener-address)))

(define-read-only (get-gardener-allocated-amount (gardener-address principal))
  (default-to u0 (map-get? distributed-resource-amounts gardener-address)))

(define-read-only (get-total-resources-distributed)
  (var-get total-resources-distributed))

(define-read-only (get-resource-allocation-per-gardener)
  (var-get resource-allocation-per-gardener))

(define-read-only (get-harvest-period)
  (var-get harvest-season-length))

(define-read-only (get-season-start-block)
  (var-get season-start-block))

(define-read-only (get-garden-activity (activity-id uint))
  (map-get? garden-activities activity-id))

;; Contract initialization

(begin
  (ft-mint? garden-resource-token u1000000000 GARDEN-COORDINATOR))