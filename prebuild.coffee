# remove audio, and
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")
diff= require("./analysis").diff




#make it a mp4 that doesn't suck
master= (input)->
  input= path.join(__dirname, input)
  name= path.basename(input)
  ext= path.extname(name)
  output= path.join(__dirname, "/assets/video_master/#{path.basename(input, ext)}.mp4")
  console.log "converting #{name} to mp4"
  cmd = """ffmpeg -i #{input} -y -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -preset slower -crf 18 -vf "scale=trunc(in_w/2)*2:trunc(in_h/2)*2" #{output}"""
  run_sync(cmd)
  diff(input, output)
  return output



#remove audio track
strip_audio= (input)->
  input= path.join(__dirname, input)
  name= path.basename(input)
  output= path.join(__dirname, "QUIET_#{name}")
  console.log "stripping audio from #{name}.."
  cmd= "ffmpeg -i #{input} -y -vcodec copy -an #{output}"
  run_sync(cmd)
  diff(input, output)
  return output


module.exports= {
  strip_audio: strip_audio,
  master: master
}

console.log strip_audio("./shakey_spring.MOV")
console.log master("./QUIET_shakey_spring.MOV")