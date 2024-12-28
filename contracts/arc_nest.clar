;; ArcNest Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data vars
(define-map projects 
  { project-id: uint } 
  { 
    owner: principal,
    title: (string-ascii 64),
    created-at: uint,
    updated-at: uint
  }
)

(define-map characters
  { character-id: uint, project-id: uint }
  {
    name: (string-ascii 64),
    description: (string-utf8 500),
    created-by: principal
  }
)

(define-map timeline-events
  { event-id: uint, project-id: uint }
  {
    title: (string-ascii 64),
    description: (string-utf8 500),
    timestamp: uint,
    created-by: principal
  }
)

(define-data-var project-id-nonce uint u0)
(define-data-var character-id-nonce uint u0)
(define-data-var event-id-nonce uint u0)

;; Private functions
(define-private (is-project-owner (project-id uint) (caller principal))
  (match (map-get? projects { project-id: project-id })
    project (is-eq (get owner project) caller)
    false
  )
)

;; Public functions
(define-public (create-project (title (string-ascii 64)))
  (let
    (
      (new-id (+ (var-get project-id-nonce) u1))
    )
    (map-set projects
      { project-id: new-id }
      {
        owner: tx-sender,
        title: title,
        created-at: block-height,
        updated-at: block-height
      }
    )
    (var-set project-id-nonce new-id)
    (ok new-id)
  )
)

(define-public (add-character 
    (project-id uint)
    (name (string-ascii 64))
    (description (string-utf8 500)))
  (let
    (
      (new-id (+ (var-get character-id-nonce) u1))
    )
    (if (is-project-owner project-id tx-sender)
      (begin
        (map-set characters
          { character-id: new-id, project-id: project-id }
          {
            name: name,
            description: description,
            created-by: tx-sender
          }
        )
        (var-set character-id-nonce new-id)
        (ok new-id)
      )
      err-unauthorized
    )
  )
)

(define-public (add-timeline-event
    (project-id uint)
    (title (string-ascii 64))
    (description (string-utf8 500))
    (timestamp uint))
  (let
    (
      (new-id (+ (var-get event-id-nonce) u1))
    )
    (if (is-project-owner project-id tx-sender)
      (begin
        (map-set timeline-events
          { event-id: new-id, project-id: project-id }
          {
            title: title,
            description: description,
            timestamp: timestamp,
            created-by: tx-sender
          }
        )
        (var-set event-id-nonce new-id)
        (ok new-id)
      )
      err-unauthorized
    )
  )
)

;; Read only functions
(define-read-only (get-project (project-id uint))
  (ok (map-get? projects { project-id: project-id }))
)

(define-read-only (get-character (character-id uint) (project-id uint))
  (ok (map-get? characters { character-id: character-id, project-id: project-id }))
)

(define-read-only (get-timeline-event (event-id uint) (project-id uint))
  (ok (map-get? timeline-events { event-id: event-id, project-id: project-id }))
)