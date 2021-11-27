    globals [rad speed-variation health robustness  closest_food vis_rand daytime starting_color current_color color_adjust color_range timer_reset  food_around_me  ] ;; creating a global variable called rad : speed-variation , health , robustness , closest-food ,vis_rand daytime starting_color current_color color_adjust color_range timer_reset  food_around_me
    breed [ peoples people]  ;; creating a population of humans to move around within the world and detect the zombies
    breed [zombies  zombie]  ;; creating a population of zombies that move around aimlessly and also detect humans
    breed [ food flowers]   ;; creating a population of plants for humans to feed from
    breed[ fire vpod ] ;; create a population of fire pods to defend the zombies
    turtles-own [ zombie_seen zombie_hit  ;;creating two variables used to count the total people seen and people hit
      per-vis-rad  per_vis_ang ;; two variables for personalised vision cones
      have_fire] ;; creating variables to store amount of fire held
    food-own [amount] ;; variable to store amount of food
    patches-own [ solid] ;;  creating a variable for the patches that are seen as solids


  to setup                                                                                    ;; creates a function called setup
      clear-all                                                                              ;; this clears the world
      reset-ticks                                                                            ;; this resets the tick counter
      set rad  5                                                                             ;; adding value to global variable rad
      set timer_reset 1000                                                                   ;; sets the global variable timer_reset  to 1000
      set daytime true                                                                       ;; sets global variable daytime to true
      set starting_color 80                                                                  ;; sets  starting_color to 80
      set current_color starting_color                                                       ;; sets global variable current_color to starting_color
      set color_range 10                                                                     ;; sets the global variable color_range to 10
      set color_adjust ( color_range / (timer_reset + 10 ))                                  ;; sets the global variable color_adjust to a range based on the variables above


      create-zombies number_of_zombies [                                                     ;;this creates new turtles created as zombies which are determined by the slider
        setxy random-xcor random-ycor                                                        ;; starting position set to a random location in the world
        set size 10                                                                          ;; sets the size of the zombie to 10
        set color red                                                                        ;; sets the color of the zombie to red
        set shape "person"                                                                   ;; sets the shape of the zombie to person
        set speed-variation  random 10                                                       ;; sets the speed-variation variable to a random value 10 (higher the value = faster the zombie)

      ]


    create-fire 20 [                                                                        ;; this creates an x amount of fire pods for the zombies to store and use
        make_fire]                                                                          ;; calls the make_fire function


      draw_buildings                                                                         ;; calls the draw_buildings function


      create-food 20  [grow_food]                                                            ;; creates an x amount of food and calls the grow_food function


      create-peoples number_of_peoples [                                                     ;; this creates new turtles created as peoples which are determined by the slider
        setxy random-xcor random-ycor                                                        ;; sets the starting position set to a random location in the world
        set size 10                                                                          ;; sets the size of the turtle to 10
        set shape "person"                                                                   ;; sets the shape of the turtle to person
        set color blue                                                                       ;; sets the color of the turtle to blue
        set health 50 + random 50                                                            ;;  sets the health of the turtle to 50 and adds a random allocation up to 50
        adjust_vision_cone                                                                   ;; calls the adjust_vision_cone function which sets up the vision cone
        set bravery 0 + random 100                                                        ;; sets the  bravery of the turtle to 0  and adds a random allocation up to 100
        set aggression 0 +  random  100                                                       ;;  sets the aggression of the turtle to 0 and adds a random allocation up to 100
        set vis_rand random 20                                                               ;; sets the global variable vis_rand and add a random allocation up to 20
        ; set heading 0                                                                      ;; sets the heading of the turtle to 0
        ;pen-down                                                                            ;; so the user can view where the turtle moves to
      ]
    end                                                                                      ;; end of the commands in the procedure

    to go                                                                                     ;; creates a function called go
      reset-ticks                                                                            ;; reset the tick counter
      make_zombie_move                                                                       ;; calls make_zombie_move function
      reset_patch_color                                                                      ;; calls reset_patch_color function
      make_peoples_move                                                                      ;; calls make_peoples_move function
      tick                                                                                   ;;  adds 1 to the tick counter
      grow_more_food                                                                         ;; calls grow_more_food function
    end                                                                                      ;; end of the commands in the procedure

    to adjust_vision_cone                                                                     ;; creates a function called adjust_vision_cone
      if ((vis_rad + random 20)*(health * 0.01)) > 0 [                                       ;; if the result is greater than 0
        set per-vis-rad ((vis_rad + vis_rand ) *(health * 0.01))                             ;;set the  personal vision radius has to factor randomness and health which means less health = less vision for the humans
      ]
      if ((vis_ang + random 20)*(health * 0.01)) > 0 [                                       ;; if the results is greater than 0
        set per_vis_ang ((vis_ang + vis_rand) * (health * 0.01))                             ;; set the personal vision angle to factor randomness and health
      ]
    end                                                                                      ;; end of the commands in the procedure

    to make_zombie_move                                                                       ;; creates a function called make_zombie_move
      ask zombies [                                                                          ;; asks all the zombies in the population to do what is in the bracket
        set color red                                                                        ;; sets the color of each zombie  to red
        detect_wall                                                                          ;; calls the detect_wall function
        forward zombie_speed +  (speed-variation * 0.2)                                      ;; moves the zombie forward due to the zombie speed variable
        if count peoples  = 0                                                                ;; if the counter for the humans reach 0 then display message.......
          [
            user-message (word "The zombies Win")                                            ;; display to the user "the zombies win"
        ]
      ]
      ask zombies[                                                                           ;; asks all the zombies in the population to do what is in the bracket
        ifelse health > 0 [                                                                  ;; if health is greater than 0 then ....
          let have_seen_person people_function                                               ;; this creates a local variable called have_seen_person the fills it with the return of the function people_function
          ifelse ( have_seen_person = true ) [                                               ;; if local variable have_seen_person is true...
            right 180                                                                        ;; set heading of the butterfly to 180 (turn around to avoid!)
          ][
              right (random bwr - (bwr / 2))                                                 ;; this turns the butterfly right relative to its current heading by a random degree number using the range set within bwr NOTE: if negative it will turn left
          ]]
          [
          set color gray                                                                      ;; set color to gray to indicate dead zombie
          die                                                                                 ;; this kills off the zombie
          ]
      ]


    end                                                                                       ;; end of the commands in the procedure

    to-report food_function [sensitivity]                                                     ;; creates a reporting function called food_function and expects a value for sensitivity
      set food_around_me other ( food in-radius sensitivity )                                 ;; this sets the food_around_me variable to the ID's of the food within the sensitivity radius
      set closest_food min-one-of food_around_me [distance myself]                            ;; this sets the closest_food variable to the ID of the closest food source
      let can_smell_food [false]                                                              ;; this creates a local variable called can_smell_food and sets it to false
      let eating_food [false]                                                                 ;; this creates a local variable called eating_food and sets it to false

      if health < 100 [                                                                       ;; if health is less than 100 then...
        ask food in-radius rad [                                                              ;; this sets up a radius around the food to the value of the global variable rad which we are using for collision detection with people
          ifelse amount > 0 [                                                                 ;; if amount (a food variable) is greater than 0...
            set eating_food true                                                              ;; set the local variable called eating_food to true indicating the butterfly is eating
            set amount amount - 5                                                             ;; reduces 5 from the amount variable in the food
            set color color - .25                                                             ;; reduce the color intensity of the food by .25
          ][
            die                                                                               ;; there is no food left so kill the good agent
          ]
        ]
      ]

      if eating_food = true [                                                                 ;; if eating_food is true then...
        set health health + 5                                                                 ;; add 5 to health of butterfly
        adjust_vision_cone                                                                    ;; calls the adjust_vision_cone
      ]

      if (closest_food != nobody) [                                                           ;; if closest_food is not empty (the butterfly can smell food in range) then...
        set can_smell_food true                                                               ;; set can_smell_food to true
      ]
      report can_smell_food                                                                   ;; return value of can_smell_food to location where function was called
    end                                                                                       ;; end of the commands in the procedure


    to-report people_function                                                                 ;; creates a reporting function called people_function
      let seen [false]                                                                        ;; this creates a local variable called seen
      let hit [false]                                                                         ;; this creates a local variable called hit
      if hit = true [                                                                     ;; if statement based on the local variable hit, if seen = true then...
        ifelse have_fire > 0 [                                                               ;; if have_fire is greater that 0 then...
          ask zombie zombie_hit [die]                                                         ;; kill off the person hit
          set have_fire have_fire - 1                                                        ;; remove 1 from the have_fire of the turtle
        ][
          set zombie_hit  zombie_hit + 1                                                      ;; add 1 to the people_hit count
          set color green                                                                     ;; set color of butterfly to green
          set health health - robustness                                                      ;; adjust health of butterfly to health - collision penalty (robustness)
        adjust_vision_cone                                                                    ;; adjust_vision_cone
         ]
      ]

      report seen                                                                             ;; return true or false based in local variable seen
    end                                                                                       ;; end of the commands in the procedure


    to reset_patch_color                                                                      ;; creates a function called reset_patch_color
      ifelse daytime = true [                                                                 ;; ifelse global variable daytime = true
        set current_color current_color - color_adjust                                        ;; set adjusts  the global variable current_color using the variable color_adjust
      ]
      [
        set current_color current_color + color_adjust                                        ;; set adjusts the global variable current_color using the variable color_adjust
      ]
      ask patches [                                                                           ;; asks all the patches in the population to do what is in the brackets
        if solid = false [                                                                    ;; if the patch variable is false
          set pcolor current_color                                                            ;; sets the color of each patch to the current_color
      ]]
    end                                                                                       ;; end of the commands in the procedure

    to make_fire                                                                              ;;  creates a function called make_fire
      setxy random-xcor random-ycor                                                            ;; sets the population of the fire to a random location in the world
      set color orange                                                                         ;; sets the color of the fire to green
      set size 10                                                                              ;; sets the size of the fire to 10
      set shape "fire"                                                                            ;; sets the shape of the fire to a x
    end                                                                                        ;; end of the commands in the procedure


    to pickup_fire                                                                            ;; creates a function called pickup_fire
      let pickup [false]                                                                       ;; let creates a local variable called pickup and sets it to false
      ask fire in-radius rad [                                                                ;; sets a radius around the fire which burns the zombies by collision detection with the fire allowing the humans to pick it up (global variable : rad)
        set pickup true                                                                        ;; sets the local variable pickup to true
        die ]                                                                                  ;; kills the fire from the world
      if pickup = true [                                                                       ;;  if pickup is true then
        set have_fire have_fire + 1                                                          ;; add 1 to have_fire count on the zombie
      ]
    end                                                                                        ;; end of the commands in the procedure



    to grow_food                                                                               ;; creates a function to grow_food
      setxy random-xcor random-ycor                                                            ;; sets the position of the food to a random location in the world
      set color yellow                                                                         ;; sets the color of the food to yellow
      set size 10                                                                              ;; sets the size of the food to 10
      set shape "plant"                                                                        ;; sets the shape of the food to a plant
      set amount random 100                                                                    ;; sets the amount of food per plant to a random value up to 100
    end                                                                                        ;; end of the commands in the procedure

    to grow_more_food                                                                          ;;  creates a function to grow_more_food
      if ticks > timer_reset                                                                   ;; sets the current number of ticks to greater than 1000
      [
        ask patch random-xcor random-ycor [                                                    ;; ask 1 patch in a random location to do set tasks
          sprout-food 2 [grow_food]                                                            ;; create new food (2 in this instance) then call the grow_food function which sets parameters for the food
        ]
        ifelse daytime = true [                                                                ;; ifelse the global variable daytime = true
          set daytime false                                                                    ;; set the global variable daytime to false
        ]
        [
          set daytime true                                                                     ;; set the global variable daytime to true
        ]
        reset-ticks                                                                            ;; resets the tick counter back to 0
      ]
  end                                                                                          ;; end of the commands in the procedure

    to make_peoples_move                                                                       ;; creates a function called make_peoples_move
      ask peoples [                                                                            ;; ask all the peoples in the population to do what is in the bracket

        let current_zombie  0                                                                  ;; let creates a local variable called current_zombie and assigns a value of 0 to it
        let seen [false]                                                                       ;; creates a local variable called seen
        let hit [false]                                                                        ;; creates a local variable called hit
        ask peoples in-cone per-vis-rad vis_ang [                                              ;; sets the vision cone with parameters to detect people
          set color blue                                                                       ;; set the color of the person detected within the cone to green
        ]
        if count zombies = 0                                                                   ;; if count zombies counter is equal to 0 then display message....
        [
          user-message (word "The humans Win")                                                 ;; "The Humans Win"
        ]

        show_visualisations                                                                    ;; calls function called show visualisations
        ask zombies in-cone per-vis-rad vis_ang [                                              ;; sets up all the zombies with parameters from per-vis-rad and vis_ang  that are detected to ....
          set seen true                                                                        ;; if detected
          set color green                                                                      ;; sets the color of the zombie to green

        ]
         pickup_fire                                                                          ;; calls the pickup_fire function
        if health > 0  [                                                                       ;; if health is greater than 0 then (still alive)
        let can_smell_food food_function 30                                                    ;; this creates a local variable called can_smell_food then  returns the function food_function whilst passing 30
      if ( can_smell_food = true ) and ( health < 100) [                                       ;; if local variable can_smell_food is true...
        set heading ( towards closest_food )                                                   ;; set heading towards closest food source
        ]]

        ask zombies in-radius rad [                                                            ;; asks sets up a radius for collision radius if the switch is set to true
         set hit true                                                                          ;; if hit = true .....
          set current_zombie who                                                               ;; sets the current_zombie to an int gt or eq to 0
          show zombie_hit ]                                                                    ;; sets the variable zombie_hit to true to indicate the person has collided with a zombie
        if show_col_rad = true [                                                               ;;  switch on the visualtion of the collision radius if the switch is set to true
          ask patches in-radius rad [                                                          ;;   this selects all the patches to follow  a command that sets up a radius around the person for collision detection with zombies
            set pcolor black]                                                                  ;; sets patch color to black
        ]

        if seen = true  [                                                                      ;; ;; sets the heading of the butterfly to 180if seen  is set to true
           ifelse (bravery < random 100) [                                                     ;; if bravery is lt than  random allocation of 100....
              set color blue                                                                   ;; set the color of the zombie to blue
              right 180                                                                        ;; sets the heading of the human to 180
            ][
          right (random pwr - ( pwr / 2 ) )                                                    ;;  this turns the zombie to its current heading by a random degree number
             ]
             ]
        if hit = true [                                                                        ;; if statement based on the local variable hit
          set zombie_hit zombie_hit + 1                                                        ;; add 1 to the people_hit count

         ifelse (aggression > random 100) [                                                    ;; if aggression is gt random allocation of 100 then ...
           set health health - 25                                                              ;; subtract 25 from the health of humans in the model
           ask zombie current_zombie[                                                          ;; ask all the zombies in the population to do what is in the bracket
              die                                                                              ;; kills the current zombie
          ]]  [
            set color green                                                                    ;;  set color of the zombie to green
            set breed zombies                                                                  ;; sets the breed to zombies
            set shape "person"]]                                                               ;; sets the shape of the zombie to person

        adjust_vision_cone                                                                     ;; calls the adjust_vision_cone function
        forward peoples_speed                                                                  ;; moves person forward
      ]
    end                                                                                        ;; end of commands in the procedure

    to draw_buildings                                                                          ;; creates a function to draw_buildings
      ask patches [                                                                            ;; this selects all the patches to follow  a command
        set solid false                                                                        ;; sets the patch variable solid to false for all patches
      ]
      ask patches with [ pxcor >= -20 and pxcor <= 20 and pycor >= -20 and pycor <= 20 ] [     ;; selects only patches that meet the parameters
        set pcolor magenta                                                                       ;; color of all patches selected to pink
        set solid true                                                                         ;; sets the variable solid to true for all patches that are selected
      ]
    end                                                                                        ;; end of commands in the procedure

    to detect_wall                                                                             ;; creates a function called detect_wall
      if [solid] of patch-ahead 1 = true [                                                     ;; if patch varible of 1 patch ahead is true then...
        right 180                                                                              ;; turn around to opposite direction
      ]
    end                                                                                        ;; end of commands in the procedure

    to show_visualisations                                                                     ;; creates a function called show_visulisations
      if show_col_rad = true [                                                                 ;; if switch is set to true then this will switch on the visulisation of the collision radius
        ask patches in-radius rad [                                                            ;; sets a radius around the zombie by the global variable rad
          if solid = false [                                                                   ;; if the patch is not solid....
            set pcolor orange]                                                                 ;; sets the patch color to orange
      ]]
      if show_vis_cone = true [                                                                ;; if the switch is set to true then this will switch on the visulisation of the vision_cone
        ask patches in-cone per-vis-rad per_vis_ang [                                          ;; sets up a vision_cone in front of the person set by the value per-vis-rad and per_vis_ang
          if solid = false [                                                                   ;; checks the patch is not solid
            set pcolor sky                                                                     ;; sets the patch color to pink
          ]
      ]]
    end                                                                                        ;; end of commands in the procedure
@#$#@#$#@
GRAPHICS-WINDOW
289
50
899
661
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-150
150
-150
150
1
1
1
ticks
160.0

BUTTON
68
86
132
119
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

BUTTON
139
84
239
117
go (forever)
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
1134
49
1319
82
number_of_zombies
number_of_zombies
0
100
56.5
.1
1
NIL
HORIZONTAL

SLIDER
929
49
1115
82
number_of_peoples
number_of_peoples
0
100
64.9
.1
1
NIL
HORIZONTAL

SLIDER
1134
135
1306
168
bwr
bwr
0
100
8.0
.1
1
NIL
HORIZONTAL

SLIDER
1135
88
1307
121
zombie_speed
zombie_speed
0
10
0.7
.1
1
NIL
HORIZONTAL

SLIDER
67
138
239
171
vis_rad
vis_rad
0
50
28.0
.1
1
NIL
HORIZONTAL

SLIDER
65
183
237
216
vis_ang
vis_ang
0
180
31.9
.1
1
NIL
HORIZONTAL

SLIDER
939
93
1111
126
peoples_speed
peoples_speed
0
10
2.4
.1
1
NIL
HORIZONTAL

SWITCH
315
10
455
43
show_vis_cone
show_vis_cone
1
1
-1000

SWITCH
468
10
600
43
show_col_rad
show_col_rad
1
1
-1000

SLIDER
939
136
1111
169
pwr
pwr
0
100
12.7
.1
1
NIL
HORIZONTAL

BUTTON
98
36
175
69
NIL
Clear-all
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
1045
357
1287
546
Human Infected Period 
duration
Quantity of Agents
0.0
52.0
0.0
100.0
true
true
"" ""
PENS
"Peoples" 1.0 0 -13791810 true "" "plot count peoples"
"zombies" 1.0 0 -2139308 true "" "plot count zombies"
"Total" 1.0 0 -955883 true "" "plot count turtles "
"Fire" 1.0 0 -5298144 true "" "plot count fire"
"Food" 1.0 0 -1184463 true "" "plot count food"

MONITOR
1039
302
1099
347
Humans 
count peoples
17
1
11

MONITOR
1107
303
1165
348
Zombies
count zombies
17
1
11

MONITOR
1176
302
1258
347
Total agents
count turtles
17
1
11

SLIDER
64
224
236
257
bravery
bravery
0
100
67.0
.1
1
NIL
HORIZONTAL

SLIDER
64
264
236
297
aggression
aggression
0
100
35.0
.1
1
NIL
HORIZONTAL

MONITOR
1108
256
1165
301
Fire
count fire
17
1
11

MONITOR
1186
255
1243
300
Food
count food
17
1
11

MONITOR
1028
254
1106
299
tick counter
ticks
17
1
11

@#$#@#$#@
## WHAT IS IT?
This is a model for a zombie epidemic created by Helitha and patrick. You, the user have the opportunity to display different survival rates for humans and zombies. The simulation requires the user to change variables displayed on sliders and the model begins upon clicking setup and Go which starts the model. The user can view changes in the model by looking at the plot on the right-hand side of the model which displays the Quanity of agents in the current model against a short period of time. 

## HOW IT WORKS

The user is able to determine the population,speed and heading of humans vs zombies in the model by changing the sliders number_of_peoples: peoples_speed, pwr, number_of_zombies, zombie_speed and bwr. Furthermore, the user can choose if they want to view the designated vision_cone and radius assigned to humans who have to detect zombies,food and venom in the model. Additional functionality, allows the user to change the radius and angle of the vison_cone given to humans in the model. The user can change the survival rate of the zombie epidemic by changing variables such as bravery and aggression which changes the outcome of the model for humans. Finally, the speed of the model can be changed by the user by clicking on the slider on the top of the model. 

## HOW TO USE IT

# Buttons: 
Clear-all: Sets up a button to clear the world. 
Setup: sets up a button called setup  and calls the function setup. 
Go(Forever): Sets up a button called go and calls the function go. 

# Sliders:
vis_rad: A slider between (0-50) which sets the radius of the vision_cone.
vis_ang: A slider between (0-180) which sets the angle of   the vision_cone. 
Bravery: A slider between (0-100) which sets the bravery for humans  in the simulation. (Decreasing the value decreases the chances of survival for humans). 
Aggression: A slider between (0-100) which sets the aggression for humans in the simulation ( changing the value of the slider increase the chances of survival for humans).
show_vis_cone: A switch (on-off) to display to the user the vision_cone given to humans. 
show_col_rad: A switch (on-off) to display to the user the color radius given to the humans in the simulation. 
number_of_peoples: A slider between ( 0-100) which creates a population of humans in the simulation. 
peoples_speed A slider between ( 0-10) which sets the peoples speed forward. 
pwr:A slider between ( 0-200) which turns the person to its current heading by a random degree number
number_of_zombies: A slider between (0-100) which creates a population of zombies in the simulation. 
zombie_speed: A slider between (0-10) which sets the zombie speed forward. 
bwr:  A slider between ( 0-200) which  the persons heading by a random degree number. 

# Monitors:
Fire: Count Fire displays all the fire in the simulation (preset to 20). 
Food: Count Food displays the total amount of food in the simulation (preset to 20). 
Humans: Count Peoples displays the total amount of humans in the model ( user choice). 
Zombies: Count Zombies displays the total amount of zombies in the model ( user choice). 
Total Agents: Count Turtles displays the total amount of agents in the model. 
Ticks: Shows the number of ticks from the time user clicked Go(forever) until last turtle has died in the humans vs zombie epidemic which prompts a user message to the user. 

## THINGS TO NOTICE

For each new run adjust sliders, switches and click on buttons (setup) and (go forever) which are buttons the user can click on to begin the simulation. 

         	  1. Do zombies get trapped within the wall or escape the wall on each new run of the model?
           	  2. Do zombies interact with the food and fire in the model? 
                  3. Do the zombies get detected by humans and infect them?
                  4. Do the humans get infected and turnt into zombies?
                  5. Do survival rates change if aggression and bravery are > 50 in the model?

The user can adjust the speed of the model and clear the world on each new run after adjusting the sliders and switches to gain different results. 
There are five monitors which display all the quantity of agents used in the model and  one of the monitors shows the current amount of ticks to the user when they increase/decrease the speed of the model.  

Fire: Count Fire displays all the vpods in the simulation (preset to 20).  

         1.  Do humans pickup the fire ? 
         2. Does the fire counter hit zero before the zombies win?
         3. Does the fire counter hit zero before the humans win?  

Food: Count Food displays the total amount of food in the simulation (preset to 20). 

         1. Does the food run out before the venom if aggression is set to a value > 50? 
         2. Does the food counter hit zero before the zombies win?
         3. Does the food counter hit zero if the humans win? 
         4. Do the humans pickup the food? 

Humans:  Count Peoples displays the total amount of humans in the model ( user choice). 

          1. Does changing peoples_Speed (slider) affect the rate of infection for the   humans resulting in the zombies winning? 
          2. Does changing pwr (slider) affect the humans current heading in the model
          3. Does the model end displaying a message prompt to the user highlighting which side won in the zombie epidemic?

Zombies: Count Zombies displays the total amount of zombies in the model ( user choice). 

        1. Does changing the zombie_speed (slider) increase  the rate of survival resulting in the zombies winning?
        2. Does changing the bwr (slider) affect the zombies current heading in the model.
        3. Does the model end displaying a message prompt to the user highlighting which side won in the zombie epidemic?
      
Total Agents: Count Turtles displays the total amount of agents in the model. 
           		
			 1. Does the plot display the human infection period of agents in the model over a short duration? 

## THINGS TO TRY

The user can move sliders, switches with the model to show different survival rates in a zombie epidemic. These factors can be manipulated by the user for each new run in the interface tab. 

## EXTENDING THE MODEL

Within the setup function, the user can uncomment
 
     		1. ;set heading 0 ;; sets the heading of the turtle to 0
     		2. ;pen-down ;; so the user can view where the turtle moves to

so they can view how each turtle moves. 

		3. In addition to that, they can edit the create-venom 20 (increase/decrease the number)[ make_venom] create-food 20(increase/decrease the number) [grow-food]. 

                4. Within the make_zombie_move function the user can change Forward zombie_speed +  (speed-variation * 0.2 (increase/decrease value here)  ;; moves the zombie forward due to the zombie speed variable. 


## NETLOGO FEATURES

This model used breeds to implement the population of humans vs zombies. 


User message:

This was created using Count Peoples and Count zombies to prompt to the user that death of the last turtle  displays  which side won in the simulation. 


Set color was used to set the color of the turtles, food and venom in the model.  

set pcolor was used to set the patch color for the model. 


## RELATED MODELS

 MODELS LIBRARY:

 Virus:

For the model itself:
Wilensky, U. (1998). NetLogo Virus model. http://ccl.northwestern.edu/netlogo/models/Virus. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

 Wolf Sheep Predation :

Wilensky, U. & Reisman, K. (2006). Thinking like a Wolf, a Sheep or a Firefly: Learning Biology through Constructing and Testing Computational Theories – an Embodied Modeling Approach. Cognition & Instruction, 24(2), pp. 171-209. http://ccl.northwestern.edu/papers/wolfsheep.pdf .


## CREDITS AND REFERENCES
The present model was created by Helitha and Patrick. All references made are from studynet practicals for the butterfly model. 
 
Studynet(2020).https://herts.instructure.com/courses/57497/pages/practical-resources-number-2?module_item_id=882506 // Date Accessed: 11/03/2020

Studynet(2020).https://herts.instructure.com/courses/57497/pages/practical-resources-number-3?module_item_id=882508  //Date Accessed:  11/03/2020

studynet(2020).https://herts.instructure.com/courses/57497/pages/practical-resources-number-4?module_item_id=882510  //  Date Accessed: 11/03/2020

studynet(2020).https://herts.instructure.com/courses/57497/pages/practical-resources-number-5?module_item_id=882512 //  Date Accessed: 11/03/2020
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

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

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
NetLogo 6.2.1
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
