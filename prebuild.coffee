# remove audio, and
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html

# timelapse
# ffmpeg -r 30 -i img%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")
analysis= require("./analysis")

reconcile_paths= (file="", flag="", ext="mp4")->
  obj= {}
  if flag
    flag= "_#{flag}"
  obj.input= path.join(__dirname,  file)
  obj.name= path.basename(obj.input)
  old_ext= path.extname(obj.name)
  obj.output= path.join(__dirname, "/assets/video_master", "#{path.basename(obj.input, old_ext)}#{flag}.#{ext}")
  return obj

#fix odd-numbered chrome bug
be_even= (h)->
  return Math.floor(h/2)*2

#make it a mp4 that doesn't suck
master= (input)->
  obj= reconcile_paths(input, "", "mp4")
  old_ext= path.extname(obj.name)
  console.log "converting #{obj.name} to mp4"
  run_sync("ffmpeg -i #{obj.input} -y #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output

#keep current width, and select middle ranged height
crop_video= (file, h)->
  h= be_even(h)
  obj= reconcile_paths(file, "CROP#{h}")
  console.log "resizing #{obj.name} height to #{h}px"
  run_sync("ffmpeg -i #{obj.input} -y -filter:v 'crop=in_w:#{h}' #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output



#remove audio track
strip_audio= (input)->
  input= path.join(__dirname, input)
  name= path.basename(input)
  output= path.join(__dirname, "QUIET_#{name}")
  console.log "stripping audio from #{name}.."
  run_sync("ffmpeg -i #{input} -y -vcodec copy -an #{output}")
  analysis.diff(input, output)
  return output

add_meta= (file)->
  input= path.join(__dirname, file)
  output= path.join(__dirname, "META_#{file}")
  run_sync("ffmpeg -i #{input} -y -metadata author='Spencer Kelly' -metadata comment='@spencermountain' -metadata year='2014' #{output}")
  analysis.pretty_print(output)
  return output

module.exports= {
  strip_audio: strip_audio,
  master: master
  add_meta: add_meta
}

# analysis.play strip_audio("./shakey_spring.MOV")
analysis.play master("./shakey_spring.MOV")
# console.log add_meta("shakey_spring.MOV")
# analysis.play crop_video("./shakey_spring.MOV", 286)