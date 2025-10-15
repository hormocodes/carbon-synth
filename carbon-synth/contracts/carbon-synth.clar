;; Carbon-Synth - Synthetic Carbon Credits Trading Platform
;; A decentralized platform for trading synthetic carbon credits and environmental assets

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-already-verified (err u105))
(define-constant err-not-verified (err u106))
(define-constant err-invalid-price (err u107))

;; Data Variables
(define-data-var platform-fee-percent uint u2) ;; 2% platform fee
(define-data-var total-credits-issued uint u0)
(define-data-var total-credits-retired uint u0)
(define-data-var project-id-nonce uint u0)

;; Data Maps
(define-map credit-balances principal uint)
(define-map credit-projects 
    uint 
    {
        owner: principal,
        name: (string-ascii 50),
        total-credits: uint,
        retired-credits: uint,
        verified: bool,
        price-per-credit: uint
    }
)

(define-map project-counter principal uint)
(define-map verified-issuers principal bool)
(define-map credit-listings
    uint
    {
        seller: principal,
        amount: uint,
        price: uint,
        active: bool
    }
)

(define-data-var listing-nonce uint u0)

;; Read-only functions
(define-read-only (get-balance (account principal))
    (default-to u0 (map-get? credit-balances account))
)

(define-read-only (get-project (project-id uint))
    (map-get? credit-projects project-id)
)

(define-read-only (get-listing (listing-id uint))
    (map-get? credit-listings listing-id)
)

(define-read-only (is-verified-issuer (issuer principal))
    (default-to false (map-get? verified-issuers issuer))
)

(define-read-only (get-platform-fee)
    (var-get platform-fee-percent)
)

(define-read-only (get-total-credits-issued)
    (var-get total-credits-issued)
)

(define-read-only (get-total-credits-retired)
    (var-get total-credits-retired)
)

;; Private functions
(define-private (calculate-fee (amount uint))
    (/ (* amount (var-get platform-fee-percent)) u100)
)

;; Public functions

;; Admin: Add verified issuer
(define-public (add-verified-issuer (issuer principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set verified-issuers issuer true))
    )
)

;; Admin: Update platform fee
(define-public (update-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (var-set platform-fee-percent new-fee))
    )
)

;; Issue new carbon credits (only verified issuers)
(define-public (issue-credits (project-name (string-ascii 50)) (amount uint) (price uint))
    (let
        (
            (issuer tx-sender)
            (project-id (var-get project-id-nonce))
        )
        (asserts! (get-verified-status issuer) err-unauthorized)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (> price u0) err-invalid-price)
        
        (map-set credit-projects project-id
            {
                owner: issuer,
                name: project-name,
                total-credits: amount,
                retired-credits: u0,
                verified: true,
                price-per-credit: price
            }
        )
        
        (var-set project-id-nonce (+ project-id u1))
        (map-set credit-balances issuer (+ (get-balance issuer) amount))
        (var-set total-credits-issued (+ (var-get total-credits-issued) amount))
        
        (ok project-id)
    )
)

;; Helper function for verified status
(define-private (get-verified-status (issuer principal))
    (default-to false (map-get? verified-issuers issuer))
)

;; Create a listing to sell credits
(define-public (create-listing (amount uint) (price uint))
    (let
        (
            (seller tx-sender)
            (listing-id (var-get listing-nonce))
            (seller-balance (get-balance seller))
        )
        (asserts! (>= seller-balance amount) err-insufficient-balance)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (> price u0) err-invalid-price)
        
        (map-set credit-listings listing-id
            {
                seller: seller,
                amount: amount,
                price: price,
                active: true
            }
        )
        
        (var-set listing-nonce (+ listing-id u1))
        (ok listing-id)
    )
)

;; Buy credits from a listing
(define-public (buy-credits (listing-id uint) (amount uint))
    (let
        (
            (listing (unwrap! (map-get? credit-listings listing-id) err-not-found))
            (seller (get seller listing))
            (buyer tx-sender)
            (total-price (* (get price listing) amount))
            (fee (calculate-fee total-price))
            (seller-amount (- total-price fee))
        )
        (asserts! (get active listing) err-not-found)
        (asserts! (<= amount (get amount listing)) err-invalid-amount)
        (asserts! (>= (get-balance seller) amount) err-insufficient-balance)
        
        ;; Transfer credits
        (map-set credit-balances seller (- (get-balance seller) amount))
        (map-set credit-balances buyer (+ (get-balance buyer) amount))
        
        ;; Update or close listing
        (if (is-eq amount (get amount listing))
            (map-set credit-listings listing-id (merge listing { active: false }))
            (map-set credit-listings listing-id 
                (merge listing { amount: (- (get amount listing) amount) })
            )
        )
        
        (ok true)
    )
)

;; Transfer credits between accounts
(define-public (transfer (amount uint) (recipient principal))
    (let
        (
            (sender tx-sender)
            (sender-balance (get-balance sender))
        )
        (asserts! (>= sender-balance amount) err-insufficient-balance)
        (asserts! (> amount u0) err-invalid-amount)
        
        (map-set credit-balances sender (- sender-balance amount))
        (map-set credit-balances recipient (+ (get-balance recipient) amount))
        
        (ok true)
    )
)

;; Retire carbon credits (permanently remove from circulation)
(define-public (retire-credits (amount uint))
    (let
        (
            (account tx-sender)
            (balance (get-balance account))
        )
        (asserts! (>= balance amount) err-insufficient-balance)
        (asserts! (> amount u0) err-invalid-amount)
        
        (map-set credit-balances account (- balance amount))
        (var-set total-credits-retired (+ (var-get total-credits-retired) amount))
        
        (ok true)
    )
)

;; Cancel a listing
(define-public (cancel-listing (listing-id uint))
    (let
        (
            (listing (unwrap! (map-get? credit-listings listing-id) err-not-found))
        )
        (asserts! (is-eq tx-sender (get seller listing)) err-unauthorized)
        (asserts! (get active listing) err-not-found)
        
        (ok (map-set credit-listings listing-id (merge listing { active: false })))
    )
)