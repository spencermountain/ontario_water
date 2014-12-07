arr= [
  "./libs/jquery.js",
  "./libs/sugar.js",
  "./libs/oj.js",
  "./libs/easings.js",
  "./libs/dirty.js",
  "./libs/inview.js",
  "./coffeejs/stages.js"
]
head.js.apply(this, arr)

head ->
  oj.useGlobally();

  CHEAT_AMOUNT= parseInt(window.innerHeight * 0.33)
  CURRENT_STAGE= null
  y= 0


  $("#main").oj(
    div ->
      stages.map (s, i)->
        div {
          class:"stage"
          style:"height:#{s.height}px; overflow:hidden; width:100%; border:1px solid grey; font-size:68px;"
          insert:->
            s.el= $(this)
            s.preload()
            s
        },->
          i
  )


  which_stage=->
    top= parseInt(window.pageYOffset) #+ CHEAT_AMOUNT
    bottom= parseInt(top + window.innerHeight)
    real_estate= stages.map (s,i)->
      #fully-visible
      if s.top >= top && s.bottom <= bottom
        s.visibility= parseInt(s.bottom - s.top) || 0
      #top-visible
      else if s.top < top && s.bottom > top
        s.visibility= parseInt(s.bottom - top) || 0
      # bottom-visible
      else if s.top < bottom && s.bottom > bottom
        s.visibility= parseInt(bottom - s.top) || 0
      else
        s.visibility= 0
      s
    # console.log real_estate.map('visibility')
    return real_estate.sort((a,b)-> (b.visibility - a.visibility)||0)[0].i || 0


  change_stage=(i)->
    if i != CURRENT_STAGE
      CURRENT_STAGE= i
      console.log "changing to #{i}"
      for s in stages
        if s.state=="playing" && s.i != i
          s.stop()
    stages[i].play()

  scrollHandler=->
    i= which_stage()
    if i != CURRENT_STAGE
      change_stage(i)


  $(window).on 'scroll', ->
     window.requestAnimationFrame(scrollHandler);

  change_stage(which_stage())

