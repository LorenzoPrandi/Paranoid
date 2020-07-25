extensions [nw]

turtles-own

[
 ranking
 paranoid?
 standard?
 skeptic?
 p?
 notp?
 solveconf
 triangle?
 circle?
 discover_p?
 discover_notp?

  sick?
  student?
  worker?
  retired?
  sick-time
  quarantine?
  lockdown?
  infect-count
  essential_worker?
  strict_quarantine?
  spreader?
  contracted?
]

globals

[
  change-count
  n_of_standard
  n_of_paranoid
  n_of_student

    n_of_worker
    n_of_retired
    n_of_death
    neg_student
    neg_retired
    neg_worker
    days
    n_of_infected
]

to setup

  clear-all
  set-default-shape turtles "circle"
  create-turtles 3 [initializeTurtle]
  ask turtle 0 [create-link-with one-of other turtles]
  ask one-of turtles with [count link-neighbors = 0] [ create-link-with one-of other turtles ]
  while [count turtles < (_nodes)]
  [
   create-turtles 1
   [
    initializeTurtle
    create-link-with find-partner
   ]
  ]
  ask turtles [ set ranking 1 / count link-neighbors ]
  ask turtles [ set size 2 - ranking ]
  layout-radial turtles links max-one-of turtles [count link-neighbors]
  let factor 1.5 / ((max [count link-neighbors] of turtles) - (min [count link-neighbors] of turtles))
  ask turtles [ set size 0.5 + (count link-neighbors * factor) ]
  set change-count 0
  epistemic_attitudes
  reset-ticks

end


to-report find-partner

  let total random-float sum [count link-neighbors] of turtles
  let partner nobody
  let q 0
  while [q < count turtles]
  [
   ask turtle q
   [
    let nc count link-neighbors
    if partner = nobody
    [
     ifelse nc > total [ set partner self ]
     [set total total - nc]
    ]
   ]
    set q q + 1
  ]
  report partner

end


to initializeTurtle

  setxy random-pxcor random-pycor
  set color blue
  set size 0.8
  set ranking who
  set shape "turtle"

end

to epistemic_attitudes

  set n_of_paranoid (proportion_paranoid * _nodes) / 100
  repeat  n_of_paranoid
  [
  if any? turtles with [paranoid? = 0 and shape = "turtle"]
    [
      ask one-of turtles with [paranoid? = 0 and shape = "turtle"]
   [
    set shape "triangle"
    set paranoid? true
    set standard? false
    set skeptic? false
   ]
  ]
  ]

  let n_of_skeptic (proportion_skeptic * _nodes) / 100
  repeat  n_of_skeptic
  [
  if any? turtles with [skeptic? = 0 and shape = "turtle"]
    [
      ask one-of turtles with [skeptic? = 0 ]
   [
    set shape "x"
    set paranoid? false
    set standard? false
    set skeptic? true
   ]
  ]
  ]

    if any? turtles with [standard? = 0 and shape = "turtle"]
    [
      ask turtles with [standard? = 0 and shape = "turtle"]
  [
        set shape "circle"
        set paranoid? false
        set standard? true
        set skeptic? false
  ]
  ]




end


to minimize

   ask one-of turtles with-min [ranking]
   [
    set shape "circle"
    set standard? true
    set paranoid? false
    set skeptic? false
    set color green
    set p? true
    set notp? false
    set discover_p? true
    ask one-of other turtles with [standard? = true]
    [
     set shape "triangle"
     set paranoid? true
     set standard? false
     set skeptic? false
    ]
   ]


end


to discovery


   ifelse count turtles with-min [ranking] with [standard? = true or skeptic? = true ] = 0
    [minimize]
    [
     ask one-of turtles with-min [ranking] with [standard? = true or skeptic? = true]
     [
      set color green
      set p? true
      set notp? false
      set discover_p? true
     ]
    ]


end

to go_dis

  loop
  [
   transmission
   solveconflict
   tick
   if ticks mod 200 = 0
   [
    if change-count < 1 [stop] set change-count 0 setup_covid
   ]
  ]

end


to transmission

  ask turtles with [p? = true]
  [
    if any? link-neighbors with [(color = blue) and (standard? = true) and (solveconf = 0)]
    [
      ask one-of link-neighbors with [(color = blue) and (standard? = true) and (solveconf = 0)]
      [trust_p]
    ]

     if any? link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
    [
      ask one-of link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
      [trust_p]
    ]

    if any? link-neighbors with
    [
     (notp? = true) and (standard? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (notp? = true) and (standard? = true) and (ranking > x) and (solveconf = 0)
      ]
      [mtrust_notp]
    ]

     if any? link-neighbors with
    [
     (notp? = true) and (skeptic? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (notp? = true) and (skeptic? = true) and (ranking > x) and (solveconf = 0)
      ]
      [mtrust_notp]
    ]

    if any? link-neighbors with
    [
     (color = blue) and (paranoid? = true) and (ranking <= [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (color = blue) and (paranoid? = true) and (ranking <= x) and (solveconf = 0)
      ]
      [trust_p]
    ]

    if any? link-neighbors with
    [
     (color = blue) and (paranoid? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (color = blue) and (paranoid? = true) and (ranking > x) and (solveconf = 0)
      ]
      [dtrust_p]
    ]

    if any? link-neighbors with
    [
     (p? = true) and (paranoid? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (p? = true) and (paranoid? = true) and (ranking > x) and (solveconf = 0)
      ]
      [dtrust_p]
    ]
  ]


  ask turtles with [notp? = true]
  [
    if any? link-neighbors with [(color = blue) and (standard? = true) and (solveconf = 0)]
    [
     ask one-of link-neighbors with [(color = blue) and (standard? = true) and (solveconf = 0)]
      [trust_notp]
    ]


    if any? link-neighbors with
    [
     (p? = true) and (standard? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (p? = true) and (standard? = true) and (ranking > x) and (solveconf = 0)
      ]
      [mtrust_p]
    ]

    if any? link-neighbors with
    [
     (color = blue) and (paranoid? = true) and (ranking <= [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (color = blue) and (paranoid? = true) and (ranking <= x) and (solveconf = 0)
      ]
      [trust_notp]
    ]

    if any? link-neighbors with
    [
     (color = blue) and (paranoid? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (color = blue) and (paranoid? = true) and (ranking > x) and (solveconf = 0)
      ]
      [dtrust_notp]
    ]

    if any? link-neighbors with
    [
     (notp? = true) and (paranoid? = true) and (ranking > [ranking] of myself) and (solveconf = 0)
    ]
    [
      let x 0
      set x [ranking] of self
      ask one-of link-neighbors with
      [
       (notp? = true) and (paranoid? = true) and (ranking > x) and (solveconf = 0)
      ]
      [dtrust_notp]
    ]
  ]

  ask turtles with [notp? = true and paranoid? = true]
  [
   if any? link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
   [
    ask one-of link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
    [dtrust_notp]
   ]
  ]

  ask turtles with [notp? = true and standard? = true]
  [
   if any? link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
   [
    ask one-of link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
    [trust_notp]
   ]
  ]

  ask turtles with [notp? = true and skeptic? = true]
  [
   if any? link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
   [
    ask one-of link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
    [trust_notp]
   ]
  ]

  ask turtles with [p? = true and skeptic? = true]
  [
   if any? link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
   [
    ask one-of link-neighbors with [(color = blue) and (skeptic? = true) and (solveconf = 0)]
    [trust_p]
   ]
  ]




   ask turtles with [(paranoid? = true) and (solveconf = 0)]
   [
    if notp? = true
    [
     if any? link-neighbors with [(color = blue) and (ranking < [ranking] of myself)]
     [
      if any? link-neighbors with [(p? = true) and (ranking < [ranking] of myself)]
      [
       let x one-of link-neighbors with [(color = blue) and (ranking < [ranking] of myself)]
       let currentLink in-link-from x
       ask currentLink
       [
        let mynodes [both-ends] of currentLink
        ask one-of mynodes with [(paranoid? = true) and (notp? = true) and (solveconf = 0)]
        [set solveconf solveconf + 2]
       ]
      ]
     ]
    ]
    if p? = true
    [
     if any? link-neighbors with [(color = blue) and (ranking < [ranking] of myself)]
     [
      if any? link-neighbors with [(notp? = true) and (ranking < [ranking] of myself)]
      [
       let x one-of link-neighbors with [(color = blue) and (ranking < [ranking] of myself)]
       let currentLink in-link-from x
       ask currentLink
       [
        let mynodes [both-ends] of currentLink
        ask one-of mynodes with [(paranoid? = true) and (p? = true) and (solveconf = 0)]
        [set solveconf solveconf + 2]
       ]
      ]
     ]
    ]
   ]

  ask turtles with [(solveconf = 0)]
  [
   if any? link-neighbors with [(ranking < [ranking] of myself) and (notp? = true)]
   [
    if any? link-neighbors with [(ranking < [ranking] of myself) and (p? = true)]
    [
     let m' link-neighbors with [(ranking < [ranking] of myself) and (p? = true)]
     let m link-neighbors with [(ranking < [ranking] of myself) and (notp? = true)]
     if ([ranking] of m') = ([ranking] of m) and (paranoid? = true)
     [
      set color red
      set p? false
      set notp? true
      set change-count change-count + 1
      set solveconf solveconf + 2
     ]
     if ([ranking] of m') = ([ranking] of m) and (standard? = true)
     [
      set color green
      set p? true
      set notp? false
      set change-count change-count + 1
      set solveconf solveconf + 2
     ]
    ]
   ]
  ]

  ask turtles with [solveconf = 0]
  [
   if any? link-neighbors with [(ranking < [ranking] of myself) and (notp? = true)]
   [
    if any? link-neighbors with [(ranking < [ranking] of myself) and (p? = true)]
    [
     set solveconf solveconf + 1
     solveconflict
    ]
   ]
  ]

end


to solveconflict

  ask turtles with [(solveconf = 1) and (paranoid? = true)]
  [
   let m link-neighbors with-min [ranking] ask [m] of self
   [
    if notp? = true or color = blue
    [
     ask turtles with [(solveconf = 1) and (paranoid? = true)]
     [
      set color green
      set p? true
      set notp? false
      set change-count change-count + 1
      set solveconf solveconf + 1
     ]
    ]
    if p? = true
    [
     ask turtles with [(solveconf = 1) and (paranoid? = true)]
     [
      set color red
      set p? false
      set notp? true
      set change-count change-count + 1
      set solveconf solveconf + 1
     ]
    ]
   ]
  ]

  ask turtles with [(solveconf = 1) and (standard? = true)]
  [
    let m link-neighbors with-min [ranking] with [p? = true or notp? = true] ask [m] of self
   [
    if notp? = true
    [
     ask turtles with [(solveconf = 1) and (standard? = true)]
     [
      set color red
      set p? false
      set notp? true
      set change-count change-count + 1
      set solveconf solveconf + 1
     ]
    ]
    if p? = true or color = blue
    [
     ask turtles with [(solveconf = 1) and (standard? = true)]
     [
      set color green
      set p? true
      set notp? false
      set change-count change-count + 1
      set solveconf solveconf + 1
     ]
    ]
   ]
  ]

end


to mtrust_p

   set color red
   set p? false
   set notp? true
   set change-count change-count + 1

end

to mtrust_notp

   set color green
   set p? true
   set notp? false
   set change-count change-count + 1

end

to trust_p

   set color green
   set p? true
   set notp? false
   set change-count change-count + 1

end

to trust_notp

   set color red
   set p? false
   set notp? true
   set change-count change-count + 1

end

to dtrust_p

   set color red
   set p? false
   set notp? true
   set change-count change-count + 1

end

to dtrust_notp

   set color green
   set p? true
   set notp? false
   set change-count change-count + 1

end


;-----------------------------------------------------------------------------------------------

to setup_covid

  let misinformed count turtles with [notp? = true]
  ca
  create-turtles people
  repeat misinformed
  [
   ask one-of turtles with [notp? = 0]
   [set notp? true]
  ]
  initialize_turtles
  ask turtles [setxy random-pxcor random-pycor]
  reset-ticks

end


to initialize_turtles

  ask turtles [set color blue]
  ask turtles [set shape "turtle"]
  student
  worker
  retired
  ask turtles
  [
   set sick? false
   set sick-time 0
  ]
  ask n-of 1 turtles
  [
   set sick? true
   set color red
  ]
  ask turtles [set lockdown? false]

end


to student

  set n_of_student (proportion_student * people) / 100
  repeat  n_of_student
  [
   if any? turtles with [student? = 0 and shape = "turtle"]
   [
    ask one-of turtles with [student? = 0 and shape = "turtle"]
    [
     set student? true
     set worker? false
     set retired? false
     set shape "circle"
    ]
   ]
  ]

end


to worker

  set n_of_worker (proportion_worker * people) / 100
  repeat  n_of_worker
  [
   if any? turtles with [shape = "turtle"]
   [
    ask one-of turtles with [shape = "turtle"]
    [
     set student? false
     set worker? true
     set retired? false
     set shape "triangle"
    ]
   ]
  ]

  repeat n_of_worker / 2
  [
   ask one-of turtles with [worker? = true and essential_worker? = 0]
   [set essential_worker? true]
  ]

end

to retired

  set n_of_retired (proportion_retired * people) / 100
  repeat  n_of_worker
  [
   if any? turtles with [shape = "turtle"]
   [
    ask one-of turtles with [shape = "turtle"]
    [
     set student? false
     set worker? false
     set retired? true
     set shape "x"
    ]
   ]
  ]

end

to go_covid

  lockdown

  ask turtles
  [
   if lockdown? = false and quarantine? = 0
    [move]
  ]

  ask turtles
  [
   if lockdown? = true and quarantine? = 0
    [slow_move]
  ]

  break_quarantine

  ask turtles with [spreader? = true and quarantine? = 0]
  [
   if lockdown? = true
    [move]
  ]

  ask turtles
  [
   if count turtles with [sick? = true ] >= 5 and sick-time > 5 and detection_sick_people = true
    [set quarantine? true]
  ]

  ask turtles
  [
   if sick? = true and quarantine? = 0
    [infect]
    sick-count
    recover-die
  ]

  time

  if count turtles with [ sick? = true ] = 0
   [stop]

  tick

end

to break_quarantine

  if remainder ticks 20 = 0
  [
   ask turtles with [notp? = true]
   [set spreader? false]
  ]
  if deterrents = false
  [
   if remainder ticks 20 = 0
   [
    ask turtles with [notp? = true and spreader? = false]
    [if random 100 <= 50
     [set spreader? true]
    ]
   ]
  ]

  if deterrents = true
  [
   if remainder ticks 20 = 0
   [
    ask turtles with [notp? = true and spreader? = false]
    [
     if random 100 <= 10
     [set spreader? true]
    ]
   ]
  ]

end

to sick-count

 if remainder ticks 20 = 0
 [
  if any? turtles with [sick? = true and contracted? = 0]
  [
   ask turtles with [sick? = true and contracted? = 0]
   [
    set contracted? true
    set n_of_infected n_of_infected + 1
   ]
  ]
 ]

end

to move

 if student? = true
 [
  rt random 80
  lt random 80
  fd 1
 ]

  if worker? = true
  [
   rt random 80
   lt random 80
   fd 1
  ]

  if retired? = true
  [
   rt random 80
   lt random 80
   fd 0.75
  ]

end

to lockdown

  if count turtles with [sick? = true ] >= 5
  [
   if lockdown_type = "lockdown_student"
   [
    ask turtles with [student? = true]
    [set lockdown? true]
   ]
   if lockdown_type = "lockdown_retired"
   [
    ask turtles with [retired? = true]
    [set lockdown? true]
   ]
   if lockdown_type = "lockdown_retired+student"
   [
    ask turtles with [student? = true or retired? = true]
    [set lockdown? true]
   ]
   if lockdown_type = "essential_activities"
   [
    ask turtles with [essential_worker? = 0]
    [set lockdown? true]
   ]
   if lockdown_type = "all"
   [
    ask turtles[ set lockdown? true]
   ]
  ]
end

to slow_move

 if student? = true
 [
  rt random 100
  lt random 100
  fd 0.08
 ]

  if worker? = true
  [
   rt random 100
   lt random 100
   fd 0.08
  ]

  if retired? = true
  [
   rt random 100
   lt random 100
   fd 0.08
  ]

end


to time

  if ticks > 1
   [
    if remainder ticks 20 = 0
    [
     set days days + 1
     ask turtles [sickness]
     ask turtles with [student? = true]
      [
       if lockdown? = true or quarantine? = true
        [set neg_student neg_student + 0.75]
      ]
     ask turtles with [worker? = true]
      [
       if lockdown? = true or quarantine? = true
        [set neg_worker neg_worker + 1]
      ]
     ask turtles with [retired? = true]
     [
      if lockdown? = true or quarantine? = true
      [set neg_retired neg_retired + 0.5]
     ]
    ]
   ]

end


to infect

  if security_measures = false or count turtles with [sick? = true] <= 5
  [
   if student? = true
   [
    if any? other turtles in-radius 1.2 with [sick? = false]
    [
     ask other turtles in-radius 1.2 with [ sick? = false  ]
     [
      if random 100 <= 5
      [get-sick]
     ]
    ]
   ]
   if worker? = true
   [
    if any? other turtles in-radius 1.1 with [sick? = false]
    [
     ask other turtles in-radius 1.1 with [ sick? = false  ]
     [
     if random 100 <= 6
     [get-sick ]
     ]
    ]
   ]
   if retired? = true
   [
    if any? other turtles in-radius 0.8 with [ sick? = false  ]
    [
     ask other turtles in-radius 0.8 with [ sick? = false  ]
     [
      if random 100 <= 9
      [get-sick]
     ]
    ]
   ]
  ]

  if security_measures = true and count turtles with [sick? = true ] >= 5 and notp? = 0
  [
   if student? = true
   [
    if any? other turtles in-radius 1.2 with [ sick? = false  ]
    [
     ask other turtles in-radius 1.2 with [ sick? = false  ]
     [
      if random 100 <= 1.7
      [get-sick]
     ]
    ]
   ]
   if worker? = true
   [
    if any? other turtles in-radius 1.1 with [ sick? = false  ]
    [
     ask other turtles in-radius 1.1 with [ sick? = false  ]
     [
      if random 100 <= 2
      [get-sick]
     ]
    ]
   ]
   if retired? = true
   [
    if any? other turtles in-radius 0.8 with [ sick? = false  ]
    [
     ask other turtles in-radius 0.8 with [ sick? = false  ]
     [
      if random 100 <= 3
      [ get-sick ]
     ]
    ]
   ]
  ]

  if count turtles with [sick? = true ] >= 5 and security_measures = true and notp? = true
  [
   if student? = true
   [
    if any? other turtles in-radius 1.2 with [ sick? = false  ]
    [
     ask other turtles in-radius 1.2 with [ sick? = false  ]
     [
      if random 100 <= 3.4
      [ get-sick ]
     ]
    ]
   ]
   if worker? = true
   [
    if any? other turtles in-radius 1.1 with [ sick? = false  ]
    [
     ask other turtles in-radius 1.1 with [ sick? = false  ]
     [
      if random 100 <= 4
      [ get-sick ]
     ]
    ]
   ]
   if retired? = true
   [
    if any? other turtles in-radius 0.8 with [ sick? = false  ]
    [
     ask other turtles in-radius 0.8 with [ sick? = false  ]
     [
      if random 100 <= 6
      [ get-sick ]
     ]
    ]
   ]
  ]

end


to get-sick

   set sick? true
   set color red

end

to sickness

 if sick? = true
 [
  set sick-time sick-time + 1
 ]

end

to recover-die

  if student? = true and sick-time >= duration and sick? = true
  [
   ifelse random-float 100 >= 0.1
   [
    set color grey set sick? 0
   ]
   [
    set n_of_death n_of_death + 1 die
   ]
  ]
  if worker? = true and sick-time >= duration and sick? = true
  [
   ifelse random-float 100 >= 1
   [
    set color grey set sick? 0
   ]
   [
    set n_of_death n_of_death + 1 die
   ]
  ]
  if retired? = true and sick-time >= duration and sick? = true
  [ifelse random-float 100 >= 25.5
   [
    set color grey set sick? 0
   ]
   [
    set n_of_death n_of_death + 1 die
   ]
  ]

end

to save

  if count turtles with [notp? = true] = 0
  [
    if detection_sick_people = true and security_measures = true
  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "control_epidemic_det(on)_sec(on)" random-float 1.0 ".csv")
  ]

  if detection_sick_people = true and security_measures = false
  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "control_epidemic_det(on)_sec(off)" random-float 1.0 ".csv")
  ]

  if detection_sick_people = false and security_measures = true
  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "control_epidemic_det(off)_sec(on)" random-float 1.0 ".csv")
  ]

  if detection_sick_people = false and security_measures = false
  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "control_epidemic_det(off)_sec(off)" random-float 1.0 ".csv")
  ]]


if count turtles with [notp? = true] > 0
  [
    if detection_sick_people = true and security_measures = true  and deterrents = true

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(on)_sec(on)_pol(on)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = true and security_measures = true  and deterrents = false

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(on)_sec(on)_pol(off)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = true and security_measures = false  and deterrents = false

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(on)_sec(off)_pol(off)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = false and security_measures = true  and deterrents = true

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(off)_sec(on)_pol(on)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = false and security_measures = false  and deterrents = true

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(off)_sec(off)_pol(on)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = false and security_measures = true  and deterrents = false

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(off)_sec(on)_pol(off)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = true and security_measures = false  and deterrents = true

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(on)_sec(off)_pol(on)" random-float 1.0 ".csv")
  ]

     if detection_sick_people = false and security_measures = false  and deterrents = false

  [
    set-current-directory "c:/Users/loren/OneDrive/Desktop/final/epidemic"
    export-world (word "epidemic_det(off)_sec(off)_pol(off)" random-float 1.0 ".csv")
  ]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
335
19
831
516
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-30
30
-30
30
0
0
1
ticks
30.0

SLIDER
20
50
192
83
_nodes
_nodes
0
1000
500.0
1
1
NIL
HORIZONTAL

BUTTON
11
121
74
160
NIL
setup\n
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
177
125
244
158
NIL
go_dis\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
85
126
170
159
NIL
discovery\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
12
345
83
390
NIL
count links
17
1
11

MONITOR
111
344
194
389
NIL
count turtles
17
1
11

MONITOR
8
437
108
482
standard nodes
count turtles with [ standard? = true]
17
1
11

MONITOR
133
437
231
482
paranoid nodes
count turtles with [ paranoid? = true]
17
1
11

MONITOR
10
538
67
583
nodes p
count turtles with [ p? = true ]
17
1
11

MONITOR
93
537
168
582
nodes notp
count turtles with [notp? = true]
17
1
11

SLIDER
17
200
189
233
proportion_paranoid
proportion_paranoid
0
100
12.0
1
1
NIL
HORIZONTAL

SLIDER
17
261
189
294
proportion_skeptic
proportion_skeptic
0
100
12.0
1
1
NIL
HORIZONTAL

MONITOR
240
438
329
483
Skeptic nodes
count turtles with [ skeptic? = true]
17
1
11

SLIDER
851
18
1023
51
people
people
0
500
500.0
1
1
NIL
HORIZONTAL

SLIDER
853
64
1025
97
duration
duration
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
854
108
1026
141
proportion_student
proportion_student
0
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
1066
17
1238
50
proportion_worker
proportion_worker
0
100
53.0
1
1
NIL
HORIZONTAL

SLIDER
1067
62
1239
95
proportion_retired
proportion_retired
0
100
29.0
1
1
NIL
HORIZONTAL

CHOOSER
1292
15
1497
60
lockdown_type
lockdown_type
"lockdown_retired" "lockdown_student" "none" "lockdown_retired+student" "essential_activities" "all"
4

MONITOR
904
226
982
271
NIL
n_of_death
17
1
11

PLOT
908
279
1230
500
epidemic
days
infected/deaths/recoverd
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"infected" 1.0 0 -16777216 true "" " if ticks > 1 \n [\n  if remainder ticks 20 = 0 \n  [\n   plotxy days count turtles with [ sick? = true ] \n   ]\n   ]"
"deaths" 1.0 0 -7500403 true "" "if ticks > 1 \n [\n  if remainder ticks 20 = 0 \n  [\n   plotxy days 500 - count turtles \n   ]\n   ]"
"recoverd" 1.0 0 -2674135 true "" "if ticks > 1 \n [\n  if remainder ticks 20 = 0 \n  [\n   plotxy days count turtles with [ color = gray ] \n   ]\n   ]"
"pen-3" 1.0 0 -955883 true "" "if ticks > 1 \n [\n  if remainder ticks 20 = 0 \n  [\n   plotxy days count turtles with [ spreader? = true ] \n   ]\n   ]"

BUTTON
877
161
975
194
NIL
setup_covid\n
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
1117
158
1198
191
NIL
go_covid
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1294
68
1472
101
detection_sick_people
detection_sick_people
1
1
-1000

SWITCH
1298
115
1457
148
security_measures
security_measures
0
1
-1000

MONITOR
1008
227
1065
272
NIL
days
17
1
11

MONITOR
1080
225
1150
270
Spreaders
count turtles with [spreader? = true]
17
1
11

MONITOR
1161
224
1238
269
Recovered 
count turtles with [ color = grey]
17
1
11

MONITOR
1257
225
1359
270
Negative impact
neg_student + neg_retired + neg_worker
17
1
11

MONITOR
1262
291
1351
336
Total infected
count turtles with [color = gray] + n_of_death
17
1
11

SWITCH
1298
156
1442
189
deterrents
deterrents
1
1
-1000

PLOT
1248
352
1448
502
total cases
days
total infected
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" " if ticks > 1 \n [\n  if remainder ticks 20 = 0 \n  [\n   plotxy days n_of_infected\n   ]\n   ]"

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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="control" repetitions="5" runMetricsEveryStep="false">
    <setup>setup_covid</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control_det(on)_sec(on)" repetitions="20" runMetricsEveryStep="false">
    <setup>setup_covid</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control_det(off)_sec(off)" repetitions="20" runMetricsEveryStep="false">
    <setup>setup_covid</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="control_det(off)_sec(on)" repetitions="20" runMetricsEveryStep="false">
    <setup>setup_covid</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="misinfodemics" repetitions="5" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(on)_sec(on)_pol(off)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(off)_sec(off)_pol(off)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(off)_sec(on)_pol(off)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(on)_sec(off)_pol(on)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(on)_sec(on)_pol(on)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(off)_sec(off)_pol(on)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="det(off)_sec(on)_pol(on)" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
discovery
go_dis</setup>
    <go>go_covid</go>
    <final>save</final>
    <metric>n_of_death</metric>
    <metric>days</metric>
    <metric>count turtles with [spreader? = true]</metric>
    <metric>count turtles with [color = gray]</metric>
    <metric>count turtles with [notp? = true]</metric>
    <metric>Neg_student + Neg_retired + Neg_worker</metric>
    <metric>count turtles with [color = gray] + n_of_death</metric>
    <enumeratedValueSet variable="detection_sick_people">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="security_measures">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deterrents">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_retired">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_network_type">
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="_nodes">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_paranoid">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_worker">
      <value value="53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infectious_rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="duration">
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discovery_type">
      <value value="&quot;standard_min&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lockdown_type">
      <value value="&quot;lockdown_retired&quot;"/>
      <value value="&quot;lockdown_student&quot;"/>
      <value value="&quot;none&quot;"/>
      <value value="&quot;lockdown_retired+student&quot;"/>
      <value value="&quot;essential_activities&quot;"/>
      <value value="&quot;all&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_student">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="stability-factor">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion_skeptic">
      <value value="12"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
