;; Include other source code
__includes []

;; Declaration section of extensions, breeds, and globals

extensions [gis]

breed [regions region]

globals [
  fep-dataset
  region-dataset
  land-patches
  water-patches
  economies-init
  farming-init
  technology-init
  density-init
  birth-rate ; gammab in original code
  death-rate
  literate-technology
  technology-flexibility
  farming-flexibility
  economies-flexibility
  time-start
  time-end
  time
  eps
  plot-region-set
]

patches-own [
  pregion
  pfep
]

regions-own [
  rpatches 
  npatches 
  id
  fep
  farming
  technology
  economies
  timing
  density
  area
  temperature-limitation
  natural-fertility
  neighbor-regions
  migration-rate
  
  ; tendencies
  dfarming
  dtechnology
  deconomies
  ddensity
  event-list
]

;; Implementation section ------------------------------------

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  setup-init
  setup-gis
  set-default-shape regions "circle"
  read-events
  update-view
  reset-ticks
  set time time-start
  movie-start "glues-edu.mov" 
end

to make-movie
  setup 
  movie-start "glues-edu.mov" repeat 5000 [
    movie-grab-view go
  ]
  movie-close
end

to go
  calc-adaptation-tendencies
  calc-exchange-tendencies
  update-tendencies
  
  if mouse-down? [ handle-mouse ]
  
  if ( random 1000 ) < 2 [
    ask regions [set economies 2]
    print "ask regions [set economies 2]; economic downturn"  
  ]; economic downturn
  if ( random 1000 ) < 2 [
    ask regions [set technology .9]; government overthrow
    print "ask regions [set technology .9]]; government overthrow"  
  ]
  if ( random 1000 ) < 2 [
    ask regions with [id > 270] [set farming .1]; partial immigration
    print "ask regions with [id > 270] [set farming .1]]; partial immigration"
  ]
  
  if (ticks mod 10 = 0 ) [movie-grab-interface]
  
  tick
  set time time + 1
  update-view
  update-plot
end

to handle-mouse
  let mypatch patch mouse-xcor mouse-ycor
  ask mypatch [ set pcolor red ]
  let pid [pregion] of mypatch 
  ifelse  pid > 0 [
    set plot-region-set regions with [id = pid]  
  ][
    set plot-region-set regions 
  ]
  
end


to calc-adaptation-tendencies
  ask regions [
    set dfarming farming * (1 - farming) * drdfarming          ; dQ/dt = Q (1-Q) * drdQ
    set dtechnology technology-flexibility * drdtechnology     ; dT/dt = deltaT * drdT
    set deconomies economies-flexibility * drdeconomies        ; dN/dt = deltaN * drdN
    set ddensity rgr * density                                 ; dP/dt = rgr * P
  ]
end

to update-tendencies
  ask regions [
    set farming farming + dfarming
    set technology technology + dtechnology
    set economies economies + deconomies
    set density density + ddensity + migration-rate
    if ( timing > .1 / eps ) and ( farming >= 0.5 ) [ set timing ticks ]
  ]
end

to update-plot
  set-current-plot "Trajectories"
  set-current-plot-pen "Farming"
  plotxy ticks ( mean [farming] of plot-region-set )
  set-current-plot-pen "Technology"
  plotxy ticks ( mean [technology] of plot-region-set )
  set-current-plot-pen "Density"
  plotxy ticks ( mean [density] of plot-region-set )
  set-current-plot-pen "Economies"
  plotxy ticks ( mean [economies] of plot-region-set )
  
  set-current-plot-pen "Actual fertility"
  plotxy ticks ( mean [actual-fertility] of plot-region-set )


  set-current-plot "Histograms"
  set-current-plot-pen "Farming"
  set-plot-pen-mode 1
  set-histogram-num-bars 21
  histogram [farming] of regions

  set-current-plot-pen "Density"
  set-plot-pen-mode 1
  set-histogram-num-bars 21
  histogram [density] of regions
 
  set-current-plot-pen "Technology"
  set-plot-pen-mode 1
  set-histogram-num-bars 21
  histogram [technology] of regions
  
end

to-report drdfarming
  ; rgr =  mu * FEP * overexp * exp(-wT) * SI - rho P exp T/Tlit
  ; SI = (1-Q) sqrt T + Q T N tlim
  let dSIdQ  ( - sqrt technology + technology * economies * temperature-limitation )
  report ( birth-rate * actual-fertility * artisans * dSIdQ )
end


to-report drdtechnology
  ; rgr =  mu * FEP overexp * exp(-wT) * SI - rho P exp T/Tlit
  ; SI = (1-Q) sqrt T + Q T N tlim

  let dSIdT ( ( 1 - farming ) * 0.5 / sqrt technology + temperature-limitation * farming * economies )
  let dartdT ( - artisan-factor ) * artisans
  ;let dexpdT ( - 0.5 * exploitation-factor * density / sqrt technology )
  let dexpdT ( - 0.5 * exploitation-factor * density / sqrt technology  * exploitation )
  let dmdT ( density * death-rate / literate-technology * exp ( - technology / literate-technology )  )

  report birth-rate * ( - dartdT * actual-fertility * subsistence-intensity + artisans * dexpdT * subsistence-intensity  + artisans * actual-fertility * dSIdT ) - dmdT
end

to-report drdeconomies
  let dSIdN ( temperature-limitation * technology * farming )
  report  ( birth-rate * actual-fertility * artisans * dSIdN )
end

to-report subsistence-intensity
    report sqrt technology * ( 1 - farming ) + temperature-limitation * technology * economies * farming
end

to-report rgr
  let literacy technology / literate-technology
  report birth-rate * actual-fertility * artisans * subsistence-intensity - death-rate * density * exp ( - literacy)
end


to-report artisans
  report exp ( - artisan-factor * technology ) 
end

to-report exploitation
  report exp ( - exploitation-factor * density * sqrt technology )
end

to-report actual-fertility
  ;let actfert ( natural-fertility - exploitation-factor * sqrt technology * density )
  let actfert ( natural-fertility * exploitation * fluctuation)
  if actfert < 0 [ set actfert 0 ]
  report actfert
end

to-report fluctuation
  let fluc 0
  let maxfluc 0
  if fluctuation-factor > 0 [
    foreach event-list [ 
      set fluc exp ( - ((( time - ?1 ) / 175 ) ^ 2)) 
      if fluc > maxfluc [ set maxfluc fluc ]
      ifelse fluc > 0.9 [ 
        ;print (word "Event in " id " at " time " (Event " ?1 ")" ) 
        set color yellow 
      ] [set color red]
    ]
  ]
  ;print (word id maxfluc )
  report 1 - maxfluc * fluctuation-factor
end


to default-values
  set exploitation-factor 0.01
  set artisan-factor 0.04
  set spread-factor 0.03
  set trade-factor 1.0
  set fluctuation-factor 0.4
end

to update-view
  if View =  "Natural fertility" [ ask land-patches [ set pcolor scale-color green pfep 1 0 ]] 
  if View =  "Region" [ ask land-patches [ set pcolor pregion ]] 
  if View = "Farming" [ ask regions [
    let pvalue farming 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color red pvalue 1 0 
  ]]]]
  if View = "Technology" [ ask regions [
    let pvalue technology 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color pink pvalue 10 0 
  ]]]]
  if View = "Economies" [ ask regions [
    let pvalue economies 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color yellow pvalue 10 0
  ]]]]
  if View = "Timing" [ ask regions [
    let pvalue timing 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color orange pvalue ticks 0
  ]]]]
  if View = "Density" [ ask regions [
    let pvalue density 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color cyan pvalue 10 0
  ]]]]
  if View = "Actual fertility" [ ask regions [
    let pvalue actual-fertility 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color green pvalue 1 0
  ]]]]
  if View = "Migration rate" [ ask regions [
    let pvalue migration-rate 
    if any? rpatches [ ask rpatches [
    set pcolor scale-color magenta pvalue 1E-3 -1E-3
  ]]]]
end


to setup-init
  set farming-init 0.04
  set technology-init 1.0
  set economies-init 0.25
  set density-init 0.03
  ;set exploitation-factor 0.01 ; via GUI
  ;set artisan-factor 0.04; via GUI
  set birth-rate 0.0040
  set death-rate 0.05; birth-rate / 10 (init-germs)
  set literate-technology 12
  set economies-flexibility 1.0
  set technology-flexibility 0.15
  set farming-flexibility 1.0
  set eps 1E-12
  set time-start -9500
  set time-end -1000
end

to setup-gis
  set region-dataset gis:load-dataset "euroclim_0.0_0.5x0.5_region_-5000.asc"
  set fep-dataset gis:load-dataset "euroclim_0.0_0.5x0.5_natural_fertility_-5000.asc"
  
  gis:set-world-envelope (gis:envelope-union-of
    (gis:envelope-of region-dataset)
    (gis:envelope-of fep-dataset)
  )
  
  gis:apply-raster region-dataset pregion
  gis:apply-raster fep-dataset pfep
  
  set water-patches ( patches with [ pregion < 0 ] )
  set land-patches  ( patches with [ pregion > 0 ] )
  
  ask water-patches [ set pcolor blue ]
  
  ;; Loop over all patches to find unique list of region ids
  let region-list []  
  let remaining-patches land-patches

  while [ count remaining-patches > 0 ] [
    let mypatch max-one-of remaining-patches [pregion]
    let myregion  [pregion] of mypatch
    set region-list fput myregion region-list
    set remaining-patches land-patches with [pregion < myregion]
  ]

  ;; Loop over all regions and assign patches  
  foreach region-list [
    let mypatches (land-patches with  [pregion = ?])
    let myxcors [ pxcor ] of mypatches
    let myycors [ pycor ] of mypatches
    let myfeps  [ pfep  ] of mypatches
 
    create-regions 1 [
      set color red
      set xcor mean myxcors
      set ycor mean myycors
      set natural-fertility mean myfeps
      set rpatches mypatches
      set npatches count mypatches
      set id  ?
      set farming farming-init
      set technology technology-init
      set economies economies-init
      set density density-init
      set temperature-limitation 1
      set timing 1 / eps
      set area npatches * 10000 ; TODO refine calculation
      set event-list []
    ]
  ]  
  
  ask regions [
    let pid id
    let mylist []
    ask rpatches [
      let neighpatches neighbors with [ pregion != pid  and pregion > 0]
      let pnlist ( [pregion] of neighpatches )
      foreach pnlist [
         ifelse ( member? ? mylist ) [] [
           set mylist lput ? mylist
         ]
      ]
    ]   
    set neighbor-regions regions with [ member? id mylist ]  
    create-links-with neighbor-regions
  ]   
  
  set plot-region-set regions
end


to calc-exchange-tendencies
  ask regions [
    let iid id
    let iinfl ( technology * density )
    let irgr rgr
    let iarea area
    let idensity density
    let dp0 0
    let itechnology technology
    let ieconomies economies
    
    let technology-migration 0
    let technology-trade 0
    let economies-migration 0
    let economies-trade 0
    let force 0
    
    ask link-neighbors with [id > iid] [
      let jinfl ( technology * density )
      let exch ( spread-factor / sqrt ( area * iarea ) ) ; * boundary-length
      let ijpop ( iinfl * iarea + jinfl * area ) / (iarea + area)
      set force ( exch * ( ijpop - iinfl ) )
      set dp0  force
      let dp1  ( - iarea * dp0 / area )
      set migration-rate (migration-rate + dp1 * density)   
      
      ifelse ( force < 0 ) [
        ; outward pressure (from i to j), i exports to j
        set technology-migration ( dp1 * itechnology * idensity / density )          ; spread with people 
        set technology-trade     ( trade-factor * (itechnology - technology) * dp1 ) ; information spread
        set economies-migration  ( dp1 * ieconomies  * idensity / density ) 
        set economies-trade      ( trade-factor * (ieconomies  - economies) * dp1 )  
        
        set dtechnology ( dtechnology +  technology-migration + technology-trade ) 
        set deconomies  ( deconomies  +  economies-migration   + economies-trade  )
      ] [
        ; inward pressure (from j to i)
        set technology-migration ( dp0 * technology * density / idensity )          ; spread with people 
        set technology-trade     ( trade-factor * (technology - itechnology) * dp0 ) ; information spread
        set economies-migration  ( dp0 * economies  * density / idensity ) 
        set economies-trade      ( trade-factor * (economies  - ieconomies) * dp0 )  
      ]
      
    ]
    
    set migration-rate (ddensity + dp0 * density )
    if ( force > 0 ) [
      set dtechnology ( dtechnology +  technology-migration + technology-trade ) 
      set deconomies  ( deconomies  +  economies-migration   + economies-trade  )    
    ]
  ]
end

to read-events
  let filename "RegionEventTimes.tsv"
  let linecounter 0
  let itemcounter 0
  let event 0
  ifelse file-exists? filename [ 
    file-open filename
    while [not file-at-end?] [
      set linecounter ( linecounter + 1 )
      let myregion regions with [ id = linecounter ]
      ifelse any? myregion [
        set itemcounter 0
        while [itemcounter < 16 ] [
          set event file-read
          set itemcounter ( itemcounter + 1 )
          ifelse ( event > 0 ) [
            ask myregion [set event-list lput ( 1950 - event ) event-list]
          ][
            ; 
          ] 
        ]
      ][
        set event file-read-line
      ]
    ]
    ;print (word "Read " linecounter " lines with events from " filename )
    file-close
  ][
    print "Could not read file"
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
199
10
975
427
52
26
7.3
1
10
1
1
1
0
1
1
1
-52
52
-26
26
1
1
1
ticks
30.0

BUTTON
7
80
73
113
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

CHOOSER
6
117
147
162
View
View
"Region" "Natural fertility" "Actual fertility" "Farming" "Technology" "Economies" "Timing" "Density" "Migration rate"
7

BUTTON
81
80
144
113
NIL
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
17
437
503
686
Trajectories
Tick
NIL
0.0
10.0
0.0
0.1
true
true
"" ""
PENS
"Farming" 1.0 0 -2674135 true "" ""
"Technology" 1.0 0 -2064490 true "" ""
"Density" 1.0 0 -11221820 true "" ""
"Economies" 1.0 0 -1184463 true "" ""
"Actual fertility" 1.0 0 -10899396 true "" ""

SLIDER
10
213
182
246
exploitation-factor
exploitation-factor
0
0.99
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
10
250
182
283
artisan-factor
artisan-factor
0
0.99
0.04
0.01
1
NIL
HORIZONTAL

CHOOSER
7
18
145
63
Scenario
Scenario
"Europe"
0

SLIDER
13
292
185
325
spread-factor
spread-factor
0
1
0.03
0.01
1
NIL
HORIZONTAL

BUTTON
9
175
181
208
Default values
default-values
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
516
439
810
686
Histograms
NIL
NIL
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"Farming" 1.0 0 -2674135 true "" ""
"Technology" 1.0 0 -2064490 true "" ""
"Density" 1.0 0 -11221820 true "" ""
"Economies" 1.0 0 -1184463 true "" ""
"Actual fertility" 1.0 0 -10899396 true "" "histogram [actual-fertility] of regions"

SLIDER
12
330
184
363
trade-factor
trade-factor
0
2
2
0.1
1
NIL
HORIZONTAL

SLIDER
13
369
186
402
fluctuation-factor
fluctuation-factor
0
1
0.4
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

1. Press the button "setup" to load the map and initalize the simulation

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="vary spread" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>mean [farming]  of regions &gt; 0.9</exitCondition>
    <metric>count regions with [farming &gt; 0.5]</metric>
    <enumeratedValueSet variable="Scenario">
      <value value="&quot;Europe&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exploitation-factor">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="artisan-factor">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="View">
      <value value="&quot;Farming&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trade-factor">
      <value value="0.68"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spread-factor">
      <value value="0"/>
      <value value="0.01"/>
      <value value="0.03"/>
      <value value="0.08"/>
      <value value="0.15"/>
      <value value="0.4"/>
      <value value="1"/>
      <value value="4"/>
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
