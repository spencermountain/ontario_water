class Stage
  constructor: (@data) ->
    @state= "" # waiting, loading,  (prepared, rendered, active, done)
    @visibleY= null
    @el= null
    @i= null

    @render=->
      @el.oj("#{@i} ready")
      @state= "ready"
    @play=->
      @el.oj("playing #{@i}")
      @state= "playing"
    @stop=->
      @el.oj("- #{@i} -")
      @state= "stopped"


stages= [
  {},
  {},
  {},
  {},
  {},
  {},
  {},
  {},
  {}
]

# add index dynamically
stages= stages.map (o,i)->
  s= new Stage(o)
  s.i= i
  s