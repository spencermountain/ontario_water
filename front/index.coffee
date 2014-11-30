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
      source {src:"#{name}.mp4"}
      source {src:"#{name}.webm"}
      p -> "video unsupported on your browser"


  render_audio=(name)->
    name= "../assets/builds/#{name}"
    audio {
      controls:false,
      autoplay:false,
      loop:false
    },->
      source {src:"#{name}.mp3"}
      source {src:"#{name}.ogg"}
      p -> "audio unsupported on your browser"



  $("#main").oj(
    div ->
      h2 {style:"color:grey; font-size:28px; padding:0px; margin:0px;"},->
        "hi der!"
      render_audio("dylanleslie_slow_jam")
      render_video("shakey_spring", 480)
  )











