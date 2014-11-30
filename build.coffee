# a nodejs html5 video build script, from:
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")
analysis= require("./analysis")

# timelapse
# ffmpeg -r 30 -i img%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4

assets= path.join(__dirname, 'assets')
videos = shell.ls("#{assets}/video_master/")
audios = shell.ls("#{assets}/audio_master/")


resolution= (h=0)->
  w= parseInt(h * (16/9))
  return "#{w}:#{h}"

resize_video= (file, h)->
  input= path.join(assets, '/video_master/', file)
  name= path.basename(input)
  ext= path.extname(name)
  output= path.join(assets, "/builds", "#{path.basename(input, ext)}.mp4")
  console.log "resizing #{name} to #{resolution(h)}"
  cmd = """ffmpeg -i #{input} -y -vf scale=#{resolution(h)} #{output}"""
  run_sync(cmd)
  console.log analysis.metadata(input)
  console.log analysis.metadata(output)
  analysis.diff(input, output)
  return output

# 16 x 9 resolutions
# 864 x 486
# 1280 x 720

console.log resize_video(videos[0], 486)
# console.log resolution(486)


