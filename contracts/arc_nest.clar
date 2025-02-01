;; ArcNest Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101)) 
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-relationship (err u103))

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

(define-map character-relationships
  { relationship-id: uint, project-id: uint }
  {
    character1-id: uint,
    character2-id: uint,
    relationship-type: (string-ascii 32),
    description: (string-utf8 500),
    created-by: principal
  }
)

(define-data-var project-id-nonce uint u0)
(define-data-var character-id-nonce uint u0)
(define-data-var event-id-nonce uint u0)
(define-data-var relationship-id-nonce uint u0)

;; Private functions
(define-private (is-project-owner (project-id uint) (caller principal))
  (match (map-get? projects { project-id: project-id })
    project (is-eq (get owner project) caller)
    false
  )
)

(define-private (character-exists (character-id uint) (project-id uint))
  (is-some (map-get? characters { character-id: character-id, project-id: project-id }))
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

(define-public (add-character-relationship
    (project-id uint)
    (character1-id uint)
    (character2-id uint) 
    (relationship-type (string-ascii 32))
    (description (string-utf8 500)))
  (let
    (
      (new-id (+ (var-get relationship-id-nonce) u1))
    )
    (if (is-project-owner project-id tx-sender)
      (if (and 
          (character-exists character1-id project-id)
          (character-exists character2-id project-id))
        (begin
          (map-set character-relationships
            { relationship-id: new-id, project-id: project-id }
            {
              character1-id: character1-id,
              character2-id: character2-id,
              relationship-type: relationship-type,
              description: description,
              created-by: tx-sender
            }
          )
          (var-set relationship-id-nonce new-id)
          (ok new-id)
        )
        err-invalid-relationship
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

(define-read-only (get-character-relationship (relationship-id uint) (project-id uint))
  (ok (map-get? character-relationships { relationship-id: relationship-id, project-id: project-id }))
)
