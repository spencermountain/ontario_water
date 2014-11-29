# remove audio, and
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")


prebuild= (input)->
  abs= path.join(__dirname, input)
  name= path.basename(abs)
  dir= path.dirname(abs)
  output= path.join(dir, "fix_#{name}")
  #webm
  console.log "stripping audio"
  cmd= "ffmpeg -i #{abs} -vcodec copy -an #{output}"
  console.log(cmd)
  run_sync(cmd)


prebuild("./assets/video/shakey_spring.MOV")