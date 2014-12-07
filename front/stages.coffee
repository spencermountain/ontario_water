DEFAULT_HEIGHT= 500

ASSET_WIDTH= ->
  w= window.innerWidth
  for s in [1280, 853, 458] by -1
    if w < s
      return s


class Stage
  constructor: (@data={}) ->
    # waiting, loading, ready, playing, stopped/done
    @state= "waiting"
    @el= null
    @i= null
    @height= @data.height || DEFAULT_HEIGHT

    #preload automatically calls render
    @preload=(callback)->
      @state= "loading"
      @render()
      callback()

    @render=->
      @state= "ready"
      @el.oj("#{@i} ready")

    @play=->
      @state= "playing"
      @el.oj("playing #{@i}")

    @stop=->
      @state= "stopped"
      @el.oj("- #{@i} -")


class VideoStage extends Stage
  constructor: (@data={}) ->
    the= this
    super(@data)


class ImageStage extends Stage
  constructor: (@data={}) ->
    the= this
    super(@data)

    @preload=(callback=->)->
      src= @data.src.replace(/\..*?/,'')
      src= "../assets/derivative/#{src}_#{ASSET_WIDTH()}.jpg"
      img= new Image()
      img.src= src
      img.onload= callback
      return img



types= {
  image:ImageStage,
  video:VideoStage,
  stage:Stage
}


stages= [
  {
    type:"image",
    src:"toronto_aerial"
  },
  {
    type:"",
  },
  {
    type:"image",
    src:"shangri_la_toronto"
  },
]


offset= 0
stages= stages.map (s,i)->
  s.type= s.type || 'stage'
  s= new types[s.type](s)
  s.top= offset
  s.bottom= offset + (s.height || DEFAULT_HEIGHT)
  s.i= i
  offset += s.height || DEFAULT_HEIGHT
  s

window.stages= stages
console.log stages



