DEFAULT_HEIGHT= 600

ASSET_WIDTH= ->
  w= window.innerWidth
  for s in [1280, 853, 458] by -1
    if w < s
      return s


class Stage
  constructor: (@data={}) ->
    the= this
    # waiting, loading, ready, playing, stopped/done
    @state= "waiting"
    @el= null
    @i= null
    @height= @data.height || DEFAULT_HEIGHT

    #preload automatically calls render
    @preload=()->
      the.state= "loading"
      the.state= "loading #{the.i}"

    @render=->
      the.state= "ready"
      console.log "ready #{the.i}"

    @play=->
      the.state= "playing"
      console.log "playing #{the.i}"

    @stop=->
      the.state= "stopped"
      console.log "stopped #{the.i}"


class VideoStage extends Stage
  constructor: (@data={}) ->
    the= this
    super(@data)

    @preload=->
      the.render()

    @render=->
      the.state= "ready"
      src= the.data.src.replace(/\..*?/,'')
      the.src= "../assets/derivative/#{src}_#{ASSET_WIDTH()}"
      console.log the
      the.el.oj(
        div {
          style:"position:relative; left:0px; top:0px;"
          },->
            video {
              style:"left:0px; top:0px;"
              poster:"#{the.src}.png",
              controls:false,
              autoplay:true,
              loop:true,
              insert:->
                the.video= $(this)[0]
              click:->
                # console.log($(this))
                if(the.video.paused)
                  the.video.play()
                else
                  the.video.pause()
            },->
              source {src:"#{the.src}.mp4", type:"video/mp4"}
              source {src:"#{the.src}.webm", type:"video/webm"}
              p -> "video unsupported on your browser"
      )


class ImageStage extends Stage
  constructor: (@data={}) ->
    the= this
    super(@data)

    @preload=()->
      the.state= "loading"
      src= the.data.src.replace(/\..*?/,'')
      the.src= "../assets/derivative/#{src}_#{ASSET_WIDTH()}.jpg"
      img= new Image()
      img.src= the.src
      img.onload= ->
        the.render()
      return img

    @render=->
      the.state= "ready"
      the.el.oj(
        div {
          style:"position:relative; left:0px; top:0px;"
          },->
            img {
              style:"position:absolute; left:0px; top:0px; width:100%;"
              src:the.src
            }
            div {
              style:"position:absolute; z-index:3; right:10px; top:250px; font-size:30px; color:grey;"
            },->
              the.data.title
      )



types= {
  image:ImageStage,
  video:VideoStage,
  stage:Stage
}


stages= [
  {
    type:"image",
    src:"toronto_aerial",
    title:"The Rise and Rise of Toronto",
    height:400
  },
  {
    type:"image",
    src:"shangri_la_toronto"
    height:900
  },
  {
    type:"video",
    src:"expo_montage"
  },
  {
    type:"video",
    src:"big_o_collapse"
    height:900
  },
  # {},
  # {},
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