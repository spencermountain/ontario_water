arr= [
  "./libs/jquery.js",
  "./libs/sugar.js",
  "./libs/oj.js",
  "./libs/easings.js",
  "./libs/dirty.js",
  "./libs/inview.js",
  "./coffeejs/stages.js"
]
head.js.apply(this, arr);

head ->
  oj.useGlobally();

  CURRENT_STAGE= null
  determine_stage= ->
    #set the first visible one to play, and stop all preceding
    found= false
    for s,i in stages
      if found==false && s.visibleY && s.visibleY!="bottom"
        CURRENT_STAGE= i
        s.play()
        found= true
      else if s.visibleY && s.state!="ready"
        s.stop()


  $("#main").oj(
    div ->
      h2 {style:"color:grey; font-size:28px; padding:0px; margin:0px; height:1200px; "},->
        "hi der!"
      stages.map (stage, i)->
        div {
          class:"stage"
          style:"height:650px; width:100%; border:1px solid grey; font-size:68px;"
          insert:->
            stage.el= $(this)
            stage.render()
          bind:
            inview: (event, isInView, visiblePartX, visibleY)->
              stage.visibleY= visibleY
              determine_stage()
              console.log CURRENT_STAGE
        },->
          i
  )











