extensions [array table]

globals [ 

  ;;; "iteration": An integer stating the current iteration of the model.
  iteration 

  ;;; "simulation-actions": A list of lists of actions. Each list represents an iteration and each element of each list is an action performed by a turtle at the iteration.
  simulation-actions

  ;;; "iteration-actions": At each iteration, each turtle pushes the chosen action to this list. After all turtles push the chosen actions, the system will iterate through this list and evaluate each action and its impact in the model. This list allows fair model execution due to the fact that Netlogo does not use a true asynchronous and parallel execution of the turtles. This list is used as a "barrier" at the end of each model cycle.
  iteration-actions   
]

breed [ divers diver ]
breed [ gambuzinos gambuzino ]
breed [ urchins urchin ]
breed [ bubbles bubble ]

turtles-own [ 
  ;;; An integer denoting how many iterations have passed since the birth of this turtle.
  iterations
  
  ;;; A list with the turtle IDs of each turtle that, in the previous iteration, successfully attacked and hit this turtle.
  hit-by 
  
  ;;; A list with the turtle IDs of each turtle that, in the previous iteration, attacked this turtle.
  attacked-by 
  
  ;;; A list of lists where each element describes how another turtle helped this turtle.
  helped-by
  
  ;;; An integer stating how many gambuzinos were captured in the previous iteration.
  captured-in-previous-iteration
  
  ;;; E.g. Diver fired/killed at Urchin/Gambuzino. A Diver died.
  observed-actions
  
  ;;; A list for the message inbox. Each message is a list.
  incoming-queue 
  
  agent-max-speed
]
divers-own [ 

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;General fields for all architectures;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;  A real number in the interval [0,100] denoting how healthy the diver is.
  health 
  
  ;;;  A real number in the interval [0,100] denoting how much oxygen the diver has.
  oxygen 
  
  ;;;  How many gambuzinos did the diver capture through out the simulation. 
  ;;;  Even if a diver offers a gambuzino to another diver, this number does not decrease.
  captured 
  
  ;;;  The current number of gambuzinos that the diver has. 
  ;;;  Unlike the "captured" field, this one decreases each time the diver offers 
  ;;; a gambuzino to another diver.
  stored
  
  ;;; A list with the turtle IDs of each gambuzino captured in the previous iteration by this turtle.
  got
  
  ;;;  The list of actions that the diver selected to perform, in a given model iteration. 
  ;;; The system will execute the first N actions.
  actions-box 
  
  ;;;  A boolean stating that this agent can send and receive messages from other agents.
  can-communicate? 
  
  ;;;  TODO
  use-emotions?
  
  ;;;  Accepted values: "reactive", "bdi"
  agent-architecture 

  ;;;  Agentsets for the turtle contained in the "vision cone" of this turtle.
  visible-urchins 
  visible-divers 
  visible-bubbles 
  visible-gambuzinos 
  
  ;;;  Agentsets containing the agents which are (1) visible or 
  ;;; (2) were perceived through other means (e.g.: a message stating their position).
  known-urchins 
  known-divers 
  known-bubbles 
  known-gambuzinos 
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BDI Architecture fields ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;; Percepts
  P 
  
  ;;; Beliefs
  B 
  
  ;;; Desires
  active-desire 
  
  ;;; Intention(s)
  active-intention 
  
  ;;; A list of actions.
  current-plan

  current-bdi-phase
  

  
  ; -> N/A -> Percepts
  get-percepts-fn
  
  ; Beliefs x Percepts -> Beliefs
  beliefs-revision-fn
  
  ; Beliefs x Intention x Desire -> Intention
  filter-fn
  
  ; Beliefs x Intention -> (list Desire ... Desire)
  options-fn
  
  ; Action -> (list Boolean (list Action ... Action))
  execute-action-fn
  
  ; Beliefs x Intention -> (list Action ... Action)
  build-plan-fn
  
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;Emotion-based Architecture fields;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;;;  A "list" with the supported emotions. 
  ;;;  Each element is a list has the following structure: 
  ;;;   (1) The name of the emotion.
  ;;;   (2) The intensity value, a real number in the interval [0,1].
  ;;;   (3) The object of the emotion.
  emotions
  
  ;;;  A real number, in the interval [0,1], stating how high...TODO
  emotional-contagion-factor
  
  ;;; TODO
  affective-beliefs-revision-fn
]
gambuzinos-own [ ]
urchins-own [ ]


__includes[
  ;"init-agents.nls" 
  "extensions/communication.nls" 
  "find_path.nls" 
  "find_path_.nls" 
  "beliefs-management.nls" 
  ;"CYCLE-URCHINS.nls" 
  ;"CYCLE-GAMBUZINOS.nls" 
  ;"CYCLE-BUBBLES.nls" 
  ;"percepts.nls" 
]


to setup 
  
  clear-turtles
  
  clear-all
  
  ;ask patches [set pcolor blue]
  
  random-seed rseed
  
  set iteration 0
  
  set iteration-actions (list)
  
  set simulation-actions (list)
  
  set-default-shape bubbles "circle"
  set-default-shape gambuzinos "fish"
  set-default-shape urchins "fish"
  set-default-shape divers "person"
  
  init-bubbles initial-bubbles
  
  init-gambuzinos initial-gambuzinos
  
  init-urchins initial-urchins
  
  init-divers initial-divers "reactive" 0
  
  reset-ticks
end

to go
  
  tick
  
  ;ask patches [set pcolor blue]
  
  ;print (word "ITERATION " iteration)
  
  ask turtles [
   
   ifelse is-gambuzino? turtle who [
     CYCLE-GAMBUZINOS
   ] [
     ifelse is-urchin? turtle who [
       CYCLE-URCHINS
     ] [
       ifelse is-bubble? turtle who [
          CYCLE-BUBBLES
       ][
         if is-diver? turtle who [ ;;; just to lock to this set of breeds
           CYCLE-DIVERS
           
           ;;; Reduce the oxygen for each diver.
           set oxygen (oxygen - oxygen-loss-per-iteration)
         ]
       ]
     ]
   ]
   
   set iterations iterations + 1 
   
  ]
  
  
  ;;; EXECUTE ITERATION ACTIONS.
  foreach iteration-actions [
    run ?1
  ]
  set iteration-actions (list)
  
  ;;; CHECK WHICH TURTLES SHOULD BE ALIVE IN THE NEXT ITERATION.
  let to-die (list)
  ask turtles [
    
    ifelse is-bubble? turtle who [
      if iterations > max-iterations / 5 [
        die
      ]
    ] [
      ifelse is-diver? turtle who [
        if health <= 0 or oxygen <= 0 [ 
          set to-die lput who to-die 
        ]
      ] [
        if ((is-gambuzino? turtle who) or (is-urchin? turtle who)) and (not empty? hit-by) [
          let attacker (diver (item 0 hit-by))
          if attacker != nobody [
            ask diver (item 0 hit-by) [
              set stored (stored + 1)
              set captured (captured + 1)
            ]
            set to-die lput who to-die
          ]
          set hit-by (list)
        ]
      ]
    ]  
  ]
  
  foreach to-die [
    ask turtle ?1 [
      die
      print (word ?1 " is now dead.")
    ]
  ]
  
  ;;; CREATE NEW TURTLES
  ;;;; Create a new bubble.
  if random-float 1 < bubbles-creation-probability [
    init-bubbles 1
  ]
  ;;;; Create a new bubble.
  if random-float 1 < urchins-creation-probability [
    init-urchins 1
  ]
  ;;;; Create a new bubble.
  if random-float 1 < gambuzinos-creation-probability [
    init-gambuzinos 1
  ]
  
  ifelse (count divers) = 0 or iteration >= max-iterations [ 
    stop 
  ] [
    set iteration iteration + 1  
  ]
  
end

;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------
;;;-----------------------------------ACTIONS---------------------------------
;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------

to act-rotate [ agent-id angle ]
  ask turtle agent-id [rt angle]
end

to act-face-to [ agent-id target]
  ifelse is-agent? target [
    ask turtle agent-id [face turtle other-agent-id]
  ][
    let x (item 0 target)
    let y (item 1 target)
    ask turtle agent-id [facexy x y]
  ]
end

to act-move-forward [ agent-id dist ]
  ask turtle agent-id [fd (min (list dist agent-max-speed))]
end

to act-move-to [ agent-id target dist allowed-heading-divergence]
  let heading-towards-target 0
  ifelse is-agent? target [
    set heading-val (heading (towards target))
  ][
    let x (item 0 target)
    let y (item 1 target)
    set heading-val (heading (towardsxy x y))
  ]
  ifelse (subtract-headings heading heading-towards-target) > allowed-heading-divergence [
    act-face-to agent-id target dist
  ]
end

to act-rotate-randomly [ agent-id ]
  let sig random 2
  ask turtle agent-id [rt random-float 90 * (-1 ^ sig)]
end

to act-move-randomly [ agent-id ]
  ifelse random 2 = 1 [ 
    act-move-forward agent-id agent-max-speed 
  ][ 
    act-rotate-randomly agent-id 
  ]
end

to act-fire-harpoon [ attacker-id target-id ]
  ask turtle target-id [
      set attacked-by lput attacker-id attacked-by
      if random-float 1 < hit-probability [
        set hit-by lput attacker-id hit-by
      ]
    ] 
end

to act-sting [ urchin-id diver-id ]
  ask diver diver-id [
    set attacked-by lput urchin-id attacked-by
    set hit-by lput urchin-id hit-by
    set health (health - 10)
  ]
end

to act-offer-oxygen [ source-id receiver-id quant ]
  ;print "offering oxygen"
  ask turtle source-id [set oxygen oxygen - quant]
  ask turtle receiver-id [
    set oxygen oxygen + quant
    set helped-by lput (list "offered" "oxygen" quant) helped-by
  ]
end

to act-offer-gambuzinos [ source-id receiver-id quant ]
  ;print "offering gambuzinos"
  ask turtle source-id [set stored stored - quant]
  ask turtle receiver-id [
    set stored stored + quant
    set helped-by lput (list "offered" "gambuzinos" quant) helped-by
  ]
end














;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------
;;;-----------------------------------CYCLES----------------------------------
;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------

to CYCLE-DIVERS
  
  ;;; COLLECT VISIBLE ENTITIES
  set visible-urchins (perc-visible-agents visibility-distance 180 urchins)
  set visible-divers (perc-visible-agents visibility-distance 180 divers)
  set visible-bubbles (perc-visible-agents visibility-distance 180 bubbles)
  set visible-gambuzinos (perc-visible-agents visibility-distance 180 gambuzinos)
  set actions-box lput (list 0 (word "act-move-randomly " who) "default") actions-box
  
  listen-to-messages
  ;;; FIRE RULES
  rule-seek-oxygen
  rule-seek-gambuzinos
  rule-deal-with-urchins
  rule-team-work
  rule-share-visible-data
  
  ;;; RANK & SELECT
  let selected-action (item 0 (sort-by [(item 0 ?1) > (item 0 ?2)] actions-box))
  
  ;;; RUN SELECTED ACTION
  ;run (item 1 selected-action)
  set iteration-actions lput (item 1 selected-action) iteration-actions
  
  ;print actions-box
  set actions-box []
  
  ;mark-areas
  
  set label (word health " | " precision oxygen 5)
  
end

to CYCLE-GAMBUZINOS
  
  ;;; Rotate randomly & Move forward
  let sig random 2
  rt random-float 20 * (-1 ^ sig)
  fd agent-max-speed
    
end

to CYCLE-URCHINS
  
  ;;; Rotate randomly & Move forward
  let sig random 2
  let urchin-id who
  rt random-float 20 * (-1 ^ sig)
  fd agent-max-speed
  
  ;;; Sting nearby divers
  ask divers [
    let diver-id who
    if distance myself <= 1 [ 
      act-sting urchin-id diver-id 
    ]
  ]
  
end

to CYCLE-BUBBLES
  
  ;;; Replenish the oxygen of divers that are "touching" a bubble.
  ask divers [
    if distance myself < 1.5 [ 
      ;;print (word "Diver " who " replenished its oxygen supply")
      set oxygen 100
    ]
  ]
  
end










;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------
;;;-----------------------------------RULES-----------------------------------
;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------

to rule-seek-oxygen
  
  let rule-name "rule-seek-oxygen"
  
  ifelse oxygen < 30 and (count visible-bubbles) > 0 [
    ;;print (word "Diver " who "needs oxygen, is turning to the nearest bubble and moving towards it")
    let nearest-bubble min-one-of visible-bubbles [distance myself]
    
    ifelse (subtract-headings heading (towards nearest-bubble)) != 0 [
      let command-to-add (word "act-face-to " who " " ([who] of nearest-bubble))
      add-to-act-box (min (list (100 - oxygen) 50)) command-to-add rule-name
      ;act-face-to who ([who] of nearest-bubble)
    ] [
      let command-to-add (word "act-move-forward " who " " (min (list agent-max-speed (distance nearest-bubble))))
      add-to-act-box (min (list (100 - oxygen) 50)) command-to-add rule-name
      ;act-move-forward who agent-max-speed
    ]
  ] [
    ifelse oxygen < 30 [
      ; ;;print (word "Diver " who " needs oxygen and is broadcasting a message requesting bubble locations.")
      ; TODO: broadcast message requesting the locations of visible bubbles
      ; Meanwhile, just move randomly.
      ;act-move-randomly who
    ] [
      ;act-move-randomly who
    ]
  ]
  
end

to rule-seek-gambuzinos
  
  let diver-id who
  let rule-name "rule-seek-gambuzinos"
    
  ifelse count visible-gambuzinos > 0 [
    ;;print (word "Diver " diver-id " sees " (count visible-gambuzinos) " gambuzinos")
    
    let nearest-gambuzino min-one-of visible-gambuzinos [distance myself]
    let gambuzino-id ([who] of nearest-gambuzino)
    
    ifelse (distance nearest-gambuzino) <= fire-distance [
      
      if (([xcor] of nearest-gambuzino) = xcor) and (([ycor] of nearest-gambuzino) = ycor) [
        let command-to-add (word "act-fire-harpoon " diver-id " " gambuzino-id)
        add-to-act-box (100) command-to-add rule-name
        stop
      ]
      
      ifelse (subtract-headings (heading) (towards nearest-gambuzino)) > 70 
        [ 
          let command-to-add (word "act-face-to " who " " ([who] of nearest-gambuzino))
          add-to-act-box (100 / (max (list 0.5 (distance nearest-gambuzino)))) command-to-add rule-name
          ;act-face-to who ([who] of nearest-gambuzino)
          stop
        ] [ 
          let command-to-add (word "act-fire-harpoon " diver-id " " gambuzino-id)
          add-to-act-box (100 / (max (list 0.5 (distance nearest-gambuzino)))) command-to-add rule-name
          ;act-fire-harpoon diver-id gambuzino-id 
          stop
        ]
    ] [
      ;;print (word "Diver " who " is moving to capture gambuzino "  gambuzino-id)
      ifelse (subtract-headings (heading) (towards nearest-gambuzino)) > 45 
        [ 
          let command-to-add (word "act-face-to " who " " ([who] of nearest-gambuzino))
          add-to-act-box (100 / (max (list 0.5 (distance nearest-gambuzino)))) command-to-add rule-name
          ;act-face-to who ([who] of nearest-gambuzino)
          stop
        ] [ 
          let command-to-add (word "act-move-forward " who " " agent-max-speed)
          add-to-act-box (100 / (max (list 0.5 (distance nearest-gambuzino)))) command-to-add rule-name
          ;act-move-forward who agent-max-speed 
          stop
        ]
    ]
  ] [
    ;;;TODO: broadcast message requesting gambuzinos locations
  ]
end

to rule-deal-with-urchins
  
  let rule-name "rule-deal-with-urchins"
  let nearest-gambuzino min-one-of visible-gambuzinos [distance myself]
  let priority 0
  ifelse nearest-gambuzino = nobody [
    let nearest-urchin min-one-of visible-urchins [distance myself]
    if nearest-urchin != nobody [
      set priority (100 / (distance nearest-urchin))
    ]
  ] [
    set priority (100 * (max (list 0.5 (distance nearest-gambuzino))))
  ]
  
  if health < (count visible-urchins) and (count visible-divers) = 0 [
    let command-to-add (word "act-rotate " who " " 90)
    add-to-act-box priority command-to-add rule-name
    ;act-rotate who 90
    stop
  ]
  if health < (count visible-urchins) and (count visible-divers) >= (count visible-urchins) [
    let nearest-urchin min-one-of visible-urchins [distance myself]
    let command-to-add (word "act-fire-harpoon " who " " ([who] of nearest-urchin))
    add-to-act-box priority command-to-add rule-name
    ;act-fire-harpoon who ([who] of nearest-urchin)
    stop
  ]
  if health > (count visible-urchins) and (count visible-urchins) > 0 [
    let nearest-urchin min-one-of visible-urchins [distance myself]
    let command-to-add (word "act-fire-harpoon " who " " ([who] of nearest-urchin))
    add-to-act-box priority command-to-add rule-name
    ;act-fire-harpoon who ([who] of nearest-urchin)
    stop
  ]
  
end

to rule-survive 
  ;;; IF there is a "low survival rate"
  ;;;  AND the agent knows an agent
  ;;; THEN follow that agent
  ;;; TODO
end

to rule-team-work
  let rule-name "rule-team-work"

  ;;; IF the agent has very low health level (e.g. 10) AND has a neighbor with higher health level THEN
  ;;;  OFFER A CAPTURED GAMBUZINOS TO THE OTHER AGENT
  if (health < 30 or oxygen < 30) and (count visible-divers) > 0 and stored > 0 [
    let nearest-diver min-one-of visible-divers [distance myself]
    if (distance nearest-diver) <= comm-distance [
      let gambuzinos-to-give ((30 / (min (list health oxygen))) * (max (list stored 10)))
      let command-to-add (word "act-offer-gambuzinos " who " " ([who] of nearest-diver) " " gambuzinos-to-give)
      add-to-act-box (100 + (min (list health oxygen))) command-to-add rule-name
      stop
    ]
  ]
  
  ;;; IF there is a "low survival rate" 
  ;;;  AND no bubbles are available 
  ;;; THEN send "all" gambuzinos to agents within comm-distance
  if health < 20 and oxygen < 10 and (count visible-divers) > 0 and (visible-bubbles) = 0 and stored > 0 [
    ;; I cannot use this rule, according to the project description (i.e. only one action per iteration).
    ifelse stored > (count visible-divers) [
      ;; TODO
    ] [
      ;; TODO
    ]
  ]
  
  
end

to rule-share-visible-data
  let rule-name "rule-broadcast-visible-data"
  ;;; IF the agent sees bubbles or urchins
  ;;; THEN broadcast their locations, IDs and types
  let bubbles-to-report (list "bubbles" [(list who xcor ycor heading)] of visible-bubbles)
  let urchins-to-report (list "urchins" [(list who xcor ycor heading)] of visible-urchins)
  
  broadcast-to visible-divers 
    add-content 
      (list 
        (list "my data" 
          (list "location" xcor ycor) 
          (list "heading" heading) 
          (list "health" health) 
          (list "oxygen" oxygen))
        (list "bubbles" 
          bubbles-to-report)
        (list "urchins"
          urchins-to-report))
    create-message "inform"
  
  ;;; IF the agent sees other divers
  ;;; THEN broadcast their locations, IDs and types
end








to add-to-act-box [ priority command rule-name ]
  set actions-box lput (list priority command rule-name) actions-box
end

to-report best-loc-near-target [ targetx targety positions ]
  ;;; TODO
end

to-report perc-current-oxygen [ agent-id ]
  report [oxygen] of diver agent-id
end

to-report perc-current-health [ agent-id ]
  report [health] of diver agent-id
end

to-report perc-stored-gambuzinos [ agent-id ]
  report [stored] of diver agent-id
end

to-report perc-captured-gambuzinos [ agent-id ]
  report [captured] of diver agent-id
end

to-report perc-visible-agents [ max-distance max-angle agent-type ]
  let myID who
  report (agent-type in-cone max-distance max-angle) with [who != myID]
end

to-report perc-emotional-state [ agent-id ]
  ;;; TODO
end

to-report perc-stinged-by [ agent-id ]
  ;;; TODO
end

to-report perc-received-help [ ]
  ;;; TODO
end

to-report perc-current-iteration
  report iteration
end


to init-bubbles [ n ]
  create-bubbles n [
        set color white
        setxy random-pxcor random-pycor
        set agent-max-speed 0
    ]
end

to init-gambuzinos [ n ]
    create-gambuzinos n [
        set hit-by (list)
        set attacked-by (list)
        set agent-max-speed gambuzino-speed
        set color cyan
        setxy random-pxcor random-pycor
        ;;set label (word "g" who)
    ]
end

to init-urchins [ n ]
  create-urchins n [
        set hit-by (list)
        set attacked-by (list)
        set agent-max-speed urchin-speed
        set color red
        setxy random-pxcor random-pycor
        ;;set label (word "u" who)
    ]
end

to init-divers [ n diver-type emot-contagion ]
  
  if diver-type = "reactive" [
    create-divers n [
      set agent-max-speed diver-speed
      set health 100
      set oxygen 100
      set captured 0
      set stored 0
      set actions-box (list)
      set hit-by (list)
      set attacked-by (list)
      set got (list)
      set visible-urchins (turtle-set)
      set visible-divers (turtle-set)
      set visible-bubbles (turtle-set)
      set visible-gambuzinos (turtle-set)
      set incoming-queue (list)
      
      set color green
      setxy random-pxcor random-pycor
      set label (word health " | " precision oxygen 5)
    ]
  ]
  if diver-type = "deliberative" [
    ; TODO
  ]
  if diver-type = "emotional" [
    ; TODO
  ]
end


to listen-to-messages
  let msg 0
  let performative 0
  while [not empty? incoming-queue] [
    set msg get-message
    set performative get-performative msg
    if performative = "inform" [
      ;; TODO
    ]
  ]
end







;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------
;;;------------------------DELIBERATIVE AGENT CODE----------------------------
;;;---------------------------------------------------------------------------
;;;---------------------------------------------------------------------------





to-report beliefs-revision-function [ beliefs percepts ]

  ;TODO: Remove expired (TTL=0) beliefs.
  clean-expired-beliefs 
  
  foreach incoming-queue [ process-message ?1 ]
  
  let THRESHOLD_OXYGEN 20
  let THRESHOLD_HEALTH 20
  
  add-belief "health" 1 (list health)
  add-belief "oxygen" 1 (list oxygen)

  if oxygen < THRESHOLD_OXYGEN [ add-belief  "low_oxygen" 1 (list) ]

  if health < THRESHOLD_HEALTH [ add-belief  "low_health" 1 (list) ]
  
  if oxygen < THRESHOLD_OXYGEN and health < THRESHOLD_HEALTH [ add-belief  "low_survival_rate" 1  (list) ]

  if captured-in-previous-iteration > 0 [ add-belief  "got_new_gambuzinos" 1 (list captured-in-previous-iteration) ]

  if (count hit-by) > 0 or (count attacked-by) > 0 [ add-belief  "under_attack" 1 (list) ]

  if (count hit-by) > 0 [ add-belief  "damage_suffered" 1 (list ((count hit-by) * 10) ) ]

  if (count known-bubbles) = 0 [ add-belief  "no_bubbles" 1 (list) ]

  if (count known-gambuzinos) = 0 [ add-belief  "no_gambuzinos" 1 (list) ]

  if (count known-urchins) = 0 [ add-belief  "no_enemies" 1 (list) ]

  ifelse health < THRESHOLD_HEALTH [ 
    if (count visible-divers) >= (count visible-urchins) [
      ; TODO: adicionar a crença que consegue derrotar os ouriços que conseguir ver.
    ]
    ; TODO: adicionar a crença que não consegue derrotar os ouriços que conseguir ver.
  ] [
    ; TODO: caso o número de ouriços 
  ]

  ask visible-divers [
    let diver-id who
    foreach emotions [
      let name (item 0 ?1)
      let intensity (item 1 ?1)
      let object (item 2 ?1) 
      let TTL 3
      add-belief "emotion" TTL (list name intensity object)
    ] 
  ]
  
  if use-emotions? = true [
    affective-beliefs-revision-fn
  ]

end


to process-message [ M ]
  let performative (get-performative M)
  let content    (get-content M)

  ifelse performative = "inform" [
    process-inform-content content
  ] [
    ifelse performative = "ask" [
      process-ask-content content
    ][
      if performative = "request" [
        process-request-content content
      ]
    ]
  ]
end

to process-inform-content [ message-content ]
  
  let content-type (first message-content)
  
  ifelse content-type = "positions" [
    ;;; ["positions" [ID,TYPE,X,Y,HEALTH,OXYGEN,EMOTIONS] ... [ID,TYPE,X,Y,HEALTH,OXYGEN,EMOTIONS]]
    foreach (bf message-content) [
      let agent-id   (item 0 ?1)
      let agent-type (item 1 ?1)
      let agent-x    (item 2 ?1)
      let agent-y    (item 3 ?1)
      ifelse agent-type = "diver" [
        set known-divers lput ?1 known-divers
      ] [
        ifelse agent-type = "bubble" [
          set known-bubbles lput ?1 known-bubbles
        ] [
          ifelse agent-type = "gambuzino" [
            set known-gambuzinos lput ?1 known-gambuzinos
          ] [
            ; N/A
          ]
        ]
      ]
      ;add-belief  "known_position" 1 (list agent-id agent-type agent-x agent-y)
    ]
  ] [
    if content-type = "status" [
      ;;; ["status" [ID,HEALTH,OXYGEN] ... [ID,HEALTH,OXYGEN]]
      foreach (bf message-content) [
        let agent-id (item 0 ?1)
        let agent-health  (item 1 ?1)
        let agent-oxygen  (item 2 ?1)
        ;TODO: isto tem de ser feito de outra forma
        ;add-belief "health" 1 (list agent-id agent-health)
        ;add-belief "oxygen" 1 (list agent-id agent-oxygen)
      ]
    ]
  ]
  
end

to process-ask-content [ message-content ]
  ;TODO
  ;("gambuzinos-locations")
  ;("bubbles-location")
  ;("urchins-location")
end

to process-request-content [ message-content ]
  ;TODO
  ;("follow-me")
  ;("trade" REQUESTED OFFERED)
  ;REQUESTED/OFFERED: (list "gambuzinos" quantity), 
  ;                   (list "oxygen" quantity), 
  ;                   (list "follow" iterations), 
  ;                   (list "location" "bubbles"|"gambuzinos"|"urchins" POSITIONS)
end








to-report options-function [ beliefs intention ]
  
  let candidate-desires (list)
  
  ifelse use-emotions? = false [
    set candidate-desires lput (list "survive" (max (list (100 - health) (100 - oxygen) ))) candidate-desires
    set candidate-desires lput (list "hunt" ((count known-gambuzinos) * 10) ) candidate-desires
    set candidate-desires lput (list "help" ((length (get-beliefs "request" (task [true]) )) * 1.5)) candidate-desires
  ] [
    affective-options-fn beliefs intention
  ]
  
  report candidate-desires
  
end

to-report filter-function [ Beliefs Intention Desires ]
  let sorted-desires (sort-by [ (last ?1) > (last ?2) ] Desires)
  let best-desire (item 0 sorted-desires)
  let candidate-intentions (list)
  
  if (first best-desire) = "survive" [
    set candidate-intentions lput (list "gather-oxygen" (100 - oxygen)) candidate-intentions
      
    ask visible-urchins [
      set candidate-intentions lput (list "attack-urchin" (list who) (health + (10 / (distance myself)))) candidate-intentions
      set candidate-intentions lput (list "escape-urchin" (list who) ((100 - health) + (10 / (distance myself)))) candidate-intentions
    ]
  ]
  if (first best-desire) = "hunt" [
    ask known-gambuzinos [
      set candidate-intentions (list "hunt" (list who) (distance myself)) candidate-intentions
    ]
  ]
  if (first best-desire) = "help" [
    let requests (get-beliefs "request")
    foreach requests [
      
    ]
  ]
end

to-report execute-action [ A ]
  
end

to-report intention-complete? [ beliefs intention ]
  let name (item 0 intention)
  
  if name = "gather-oxygen" [
    ;TODO
  ]
  
  if name = "attack-urchin" [
    ;TODO
  ]
  
  if name = "escape-urchin" [ 
    ;TODO
  ]
  
  if name = "hunt" [
    ;TODO
  ]
  
  if name = "follow" [
    ;TODO
  ]
  
  if name = "give" [
    ;TODO
  ]
end

to-report intention-impossible? [ beliefs intention ]
  let name (item 0 intention)
  
  if name = "gather-oxygen" [
    ;TODO
  ]
  
  if name = "attack-urchin" [
    ;TODO
  ]
  
  if name = "escape-urchin" [ 
    ;TODO
  ]
  
  if name = "hunt" [
    ;TODO
  ]
  
  if name = "follow" [
    ;TODO
  ]
  
  if name = "give" [
    ;TODO
  ]
end


to-report build-plan-function [ beliefs intention ]
  let name (item 0 intention)
  let actions (list)
  
  if name = "gather-oxygen" [
    ;TODO
  ]
  
  if name = "attack-urchin" [
    ;TODO
  ]
  
  if name = "escape-urchin" [ 
    ;TODO
  ]
  
  if name = "hunt" [
    ;TODO
  ]
  
  if name = "follow" [
    ;TODO
  ]
  
  if name = "give" [
    ;TODO
  ]
end

to-report execute-action [ action ]
  ;TODO
end
@#$#@#$#@
GRAPHICS-WINDOW
423
12
1122
654
26
23
13.0
1
10
1
1
1
0
1
1
1
-26
26
-23
23
0
0
1
ticks
30.0

SLIDER
1135
416
1381
449
hit-probability
hit-probability
0
1
0.1
0.01
1
NIL
HORIZONTAL

INPUTBOX
7
239
170
299
max-iterations
1000
1
0
Number

MONITOR
179
239
302
284
Current Iteration
perc-current-iteration
17
1
11

SLIDER
1135
527
1381
560
bubbles-creation-probability
bubbles-creation-probability
0
1
0.1
0.01
1
NIL
HORIZONTAL

BUTTON
5
411
78
444
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1135
454
1381
487
urchins-creation-probability
urchins-creation-probability
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
1135
491
1425
524
gambuzinos-creation-probability
gambuzinos-creation-probability
0
1
0.1
0.01
1
NIL
HORIZONTAL

INPUTBOX
311
37
410
97
initial-bubbles
20
1
0
Number

INPUTBOX
109
37
208
97
initial-divers
10
1
0
Number

INPUTBOX
8
37
107
97
initial-gambuzinos
10
1
0
Number

INPUTBOX
210
37
309
97
initial-urchins
100
1
0
Number

INPUTBOX
162
409
323
469
rseed
10
1
0
Number

INPUTBOX
104
137
199
197
visibility-distance
10
1
0
Number

INPUTBOX
201
137
296
197
comm-distance
6
1
0
Number

INPUTBOX
7
137
103
197
fire-distance
3
1
0
Number

TEXTBOX
1138
394
1229
412
Probabilities
12
0.0
1

TEXTBOX
10
10
160
28
Initial Quantities
12
0.0
1

TEXTBOX
8
112
158
130
Action/Event Distances
12
0.0
1

TEXTBOX
10
210
160
228
Iterations
12
0.0
1

TEXTBOX
7
309
157
327
Speeds
12
0.0
1

TEXTBOX
10
469
160
487
Other
12
0.0
1

INPUTBOX
7
329
108
389
diver-speed
0.1
1
0
Number

INPUTBOX
110
329
211
389
gambuzino-speed
0.05
1
0
Number

INPUTBOX
213
329
315
389
urchin-speed
0.05
1
0
Number

INPUTBOX
7
492
168
552
oxygen-loss-per-iteration
0.5
1
0
Number

BUTTON
83
411
146
444
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1129
12
1537
189
Number of turtles
iteration
nº
0.0
1000.0
0.0
100.0
true
true
"" ""
PENS
"divers" 1.0 0 -16777216 true "" "plot count divers"
"gambuzinos" 1.0 0 -7500403 true "" "plot count gambuzinos"
"urchins" 1.0 0 -2674135 true "" "plot count urchins"
"bubbles" 1.0 0 -955883 true "" "plot count bubbles"

PLOT
1129
193
1538
367
Captured / Killed
iteration
nº
0.0
1000.0
0.0
200.0
true
true
"" ""
PENS
"gambuzinos" 1.0 0 -16777216 true "" "plot reduce + [stored] of divers"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
