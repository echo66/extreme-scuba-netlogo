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
  ;P 
  
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
  ;execute-action-fn
  
  ; Beliefs x Intention -> (list Action ... Action)
  build-plan-fn
  
  intention-done-fn?
  
  intention-impossible-fn?
  
  reconsider-fn?
  
  sound-fn?
  
  
  
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
  
  ;;; TODO
  affective-options-fn
]
gambuzinos-own [ ]
urchins-own [ ]


__includes[
  
  ;;; INITIALIZATION CODE
  "code-initialization/init-divers.nls" 
  "code-initialization/init-gambuzinos.nls" 
  "code-initialization/init-bubbles.nls" 
  "code-initialization/init-urchins.nls" 
  "code-actions-and-percepts/percepts.nls"
  
  ;;; ACTION & PERCEPTION
  "code-actions-and-percepts/actions.nls"
  
  ;;; AGENT CYCLES
  "code-agent-cycles/cycle-bubbles.nls" 
  "code-agent-cycles/cycle-divers.nls" 
  "code-agent-cycles/cycle-gambuzinos.nls" 
  "code-agent-cycles/cycle-urchins.nls" 
  
  ;;; REACTIVE CODE
  "code-reactive/diver-reactive-cycle.nls"
  "code-reactive/rule-deal-with-urchins.nls"
  "code-reactive/rule-seek-gambuzinos.nls"
  "code-reactive/rule-seek-oxygen.nls"
  "code-reactive/rule-share-visible-data.nls"
  "code-reactive/rule-team-work.nls"
  
  ;;; DELIBERATIVE CODE 
  "code-deliberative/beliefs-management.nls"
  "code-deliberative/bdi-cycle.nls" 
  "code-deliberative/plans-management.nls" 
  "code-deliberative/find-path.nls" 
  "code-deliberative/custom-code/bdi-beliefs-revision-function.nls" 
  "code-deliberative/custom-code/bdi-build-plan-function.nls" 
  "code-deliberative/custom-code/bdi-filter-function.nls" 
  "code-deliberative/custom-code/bdi-intention-complete-function.nls" 
  "code-deliberative/custom-code/bdi-intention-impossible-function.nls" 
  "code-deliberative/custom-code/bdi-options-function.nls" 
  "code-deliberative/custom-code/custom-find-path-functions.nls" 
  "code-deliberative/custom-code/code-plans/gather-oxygen-plan.nls"
  "code-deliberative/custom-code/code-plans/hunt-gambuzino-plan.nls"
  "code-deliberative/custom-code/code-plans/attack-urchin-plan.nls"
  "code-deliberative/custom-code/code-plans/escape-urchin-plan.nls"
  
  ;;; EMOTIONS CODE
  "code-emotions/affective-beliefs-revision-function.nls"
  
  
  ;;; MESSAGING CODE
  "extensions/communication.nls" 
  "code-message-processing/process-message-function.nls"
  "code-message-processing/process-inform-content-function.nls"
  "code-message-processing/process-ask-content-function.nls"
  "code-message-processing/process-request-content-function.nls"
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
  ;set-default-shape divers "person"
  
  init-bubbles initial-bubbles
  
  init-gambuzinos initial-gambuzinos
  
  init-urchins initial-urchins
  
  init-divers initial-divers "deliberative" false -1 
  
  reset-ticks
end

to go  
  
  ask patches [ set pcolor black ]
  
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


to add-to-act-box [ priority command rule-name ]
  set actions-box lput (list priority command rule-name) actions-box
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


to add-attack-link [ attacker-id target-id ]
  ask turtle attacker-id [
    create-link-to turtle target-id [ 
      set color red 
      set tie-mode "free"
      tie 
    ]
  ]
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
6
413
79
446
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
30
1
0
Number

INPUTBOX
109
37
208
97
initial-divers
20
1
0
Number

INPUTBOX
8
37
107
97
initial-gambuzinos
80
1
0
Number

INPUTBOX
210
37
309
97
initial-urchins
20
1
0
Number

INPUTBOX
162
409
323
469
rseed
400
1
0
Number

INPUTBOX
104
137
199
197
visibility-distance
5
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
0.2
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
