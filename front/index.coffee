arr= [
  "./libs/jquery.js",
  "./libs/sugar.js",
  "./libs/oj.js",
  "./libs/easings.js",
  "./libs/dirty.js",
]
head.js.apply(this, arr);

head ->
  oj.useGlobally();

  render_video=(name, size=720)->
    name= "../assets/builds/#{name}#{size}"
    video {
      poster:"#{name}.png",
      controls:false,
      autoplay:true,
      loop:false
    },->
      source {src:"#{name}.mp4", type:"video/mp4"}
      source {src:"#{name}.webm", type:"video/webm"}
      p -> "video unsupported on your browser"


  render_audio=(name)->
    name= "../assets/builds/#{name}"
    audio {
      controls:false,
      autoplay:false,
      loop:false,
      preload:"none", #auto
    },->
      source {src:"#{name}.mp3", type:"audio/mpeg" }
      source {src:"#{name}.ogg", type:"audio/ogg"}


  determine_video=->
    w= window.innerWidth
    console.log w
    sizes= [258, 480, 720]
    for s in sizes
      s_width= parseInt(s*(16/9)) #calculate corollary
      if w <= s_width
        return s
    return sizes[sizes.length-1]

  $("#main").oj(
    div ->
      h2 {style:"color:grey; font-size:28px; padding:0px; margin:0px;"},->
        "hi der!"
      render_audio("dylanleslie_slow_jam")
      size= determine_video()
      console.log size
      render_video("shakey_spring", size)
  )











