# a nodejs html5 video build script, from:
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html
#

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")
analysis= require("./analysis")
assets= path.join(__dirname, 'assets')


#16x9 resolution
resolution= (h)->
  #don't resize unless asked
  return "iw:ih" if !h
  w= parseInt(h * (16/9))
  w= be_even(w)
  return "#{w}:#{h}"

reconcile_paths= (file="", flag="", ext="mp4")->
  obj= {}
  obj.input= path.join(assets, '/video_master/', file)
  obj.name= path.basename(obj.input)
  old_ext= path.extname(obj.name)
  obj.output= path.join(assets, "/builds", "#{path.basename(obj.input, old_ext)}#{flag}.#{ext}")
  return obj

#fix odd-numbered chrome bug
be_even= (h)->
  return null if !h
  Math.floor(h/2)*2

webm= (file, h)->
  h= be_even(h)
  obj= reconcile_paths(file, "#{h}", "webm")
  size= resolution(h)
  console.log " ---Webm #{h} ---"
  run_sync("ffmpeg -i #{obj.input} -y -c:v libvpx -c:a libvorbis -pix_fmt yuv420p -quality good -b:v 2M -crf 5 -vf 'scale=#{size}' #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output

mp4= (file, h)->
  h= be_even(h)
  obj= reconcile_paths(file, "#{h}", "mp4")
  size= resolution(h)
  console.log " ---mp4 #{h} ---"
  run_sync("ffmpeg -i #{obj.input} -y -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -preset slower -crf 18 -vf scale=#{size} #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output


#grab png from first frame
thumbnail= (file, h)->
  h= be_even(h)
  obj= reconcile_paths(file, "#{h}", "png")
  size= resolution(h)
  console.log " ---thumbnail #{h} ---"
  run_sync("ffmpeg -i #{obj.input} -y -vframes 1 -map 0:v:0 -vf 'scale=#{size}' #{obj.output}")
  return obj.output


#remove old videos+audio
rm_builds= ->
  builds = shell.ls("#{assets}/builds/")
  builds.forEach (v)->
    v= "#{assets}/builds/#{v}"
    shell.rm(v)

#all sizes & thumnails for a given video
rebuild= (file)->
  # sizes= [100]
  sizes= [258, 480, 720]
  sizes.forEach (h)->
    webm(file, h)
    mp4(file, h)
    thumbnail(file, h)

#rebuild all videos in ./assets/video_master
build_all= ()->
  videos = shell.ls("#{assets}/video_master/")
  rm_builds()
  videos.forEach (f)->
    console.log "===#{f}==="
    rebuild(f)


# videos = shell.ls("#{assets}/video_master/")
#
# analysis.play resize_video(videos[0], 86)
# analysis.play webm(videos[0], 287)
# thumbnail(videos[0], 487)
# rebuild(videos[0])
build_all()


# console.log reconcile_paths("shakey_spring.mp4", "OLD")
# console.log resolution(486)


