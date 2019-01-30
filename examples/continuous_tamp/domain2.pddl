(define (domain continuous-tamp)
  (:requirements :strips :equality)
  (:predicates
    ; Static predicates
    (Block ?b)
    (Region ?r)
    (Pose ?b ?p)
    (Conf ?q)
    (Traj ?t)
    (Contained ?b ?p ?r)
    (Kin ?b ?q ?p)
    (Motion ?q1 ?t ?q2)
    (CFree ?b1 ?p1 ?b2 ?p2)
    (Placeable ?b ?r)
    (PoseCollision ?b1 ?p1 ?b2 ?p2)
    (TrajCollision ?t ?b2 ?p2)

    ; Fluent predicates
    (AtPose ?b ?p)
    (AtConf ?q)
    (Holding ?b)
    (HandEmpty)
    (CanMove)
    (Safe) ; Unsafe

    ; Derived predicates
    (In ?b ?r)
  )
  (:functions
    (Distance ?q1 ?q2)
  )
  (:action move
    :parameters (?q1 ?t ?q2)
    :precondition (and (Motion ?q1 ?t ?q2)
                       (AtConf ?q1) (Safe) (CanMove))
    :effect (and (AtConf ?q2)
                 (not (AtConf ?q1)) (not (CanMove))
                 (increase (total-cost) (Distance ?q1 ?q2))))
  (:action pick
    :parameters (?b ?p ?q)
    :precondition (and (Kin ?b ?q ?p)
                       (AtConf ?q) (AtPose ?b ?p) (HandEmpty) (Safe))
    :effect (and (Holding ?b) (CanMove)
                 (not (AtPose ?b ?p)) (not (HandEmpty))
                 (increase (total-cost) 10))
  )
  (:action place
    :parameters (?b ?p ?q)
    :precondition (and (Kin ?b ?q ?p)
                       (AtConf ?q) (Holding ?b) (Safe)
                       (forall (?b2 ?p2)
                         (imply (AtPose ?b2 ?p2) (CFree ?b ?p ?b2 ?p2)))
                  )
    :effect (and (AtPose ?b ?p) (HandEmpty) (CanMove)
                 (not (Holding ?b))
                 ;(forall (?b2 ?p2)
                 ;   ; Semantically Collision Predicate makes more sense
                 ;   (when (and (AtPose ?b2 ?p2)
                 ;               ; (PoseCollision ?b ?p ?b2 ?p2))
                 ;               (not (CFree ?b ?p ?b2 ?p2))) ; TODO: requires negate=True
                 ;         ; (not (Safe)))) ; Terminal, dead-end, failure
                 (increase (total-cost) 10))
  )

  (:derived (In ?b ?r)
    (exists (?p) (and (Contained ?b ?p ?r)
                      (AtPose ?b ?p))))
)