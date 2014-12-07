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
  obj.input= path.join(__dirname,  "./staging/#{file}")
  obj.name= path.basename(obj.input)
  old_ext= path.extname(obj.name)
  obj.output= path.join(__dirname, "/staging", "#{path.basename(obj.input, old_ext)}#{flag}.#{ext}")
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

timelapse= (folder)->
  console.log "creating timelapse"
  if !folder
    glob= "./staging/timelapse/*.JPG"
  else
    glob= path.join(folder, "/*.JPG")
  output= "./staging/timelapse.avi"
  size= "1280:720"
  cmd= "ffmpeg -framerate 10 -pattern_type glob -i '#{glob}' -y -vf scale=#{size} #{output}"
  console.log cmd
  run_sync(cmd)
  run_sync("ffplay #{output} -autoexit -exitonkeydown -exitonmousedown -loop 0")


module.exports= {
  strip_audio: strip_audio,
  master: master
  add_meta: add_meta
}

# analysis.play strip_audio("./shakey_spring.MOV")
# analysis.play master("./shakey_spring.MOV")
# console.log add_meta("shakey_spring.MOV")
# analysis.play crop_video("./shakey_spring.MOV", 286)
# analysis.play timelapse("./timelapse")

# ffmpeg -f image2 -r 1 -i '*.JPG' -r 15 -s hd1080 -vcodec libx264 video.mp4
# ffmpeg -framerate 10 -i 'img-%03d.jpeg' out.mkv
folder= "/Users/spencer/video/kingston/timelapse_storm"
analysis.play timelapse(folder)