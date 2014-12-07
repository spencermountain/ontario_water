# a nodejs html5 video build script, from:
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html
#

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")
analysis= require("./analysis")
assets= path.join(__dirname, '../assets')


#16x9 resolution
resolution= (w)->
  #don't resize unless asked
  return "iw:ih" if !w
  h= parseInt(w * (9/16))
  h= be_even(h)
  return "#{w}:#{h}"

reconcile_paths= (file="", flag="", ext="mp4")->
  obj= {}
  obj.input= path.join(assets, '/video_master/', file)
  obj.name= path.basename(obj.input)
  old_ext= path.extname(obj.name)
  obj.output= path.join(assets, "/derivative", "#{path.basename(obj.input, old_ext)}_#{flag}.#{ext}")
  return obj

#fix odd-numbered chrome bug
be_even= (h)->
  return null if !h
  Math.floor(h/2)*2

webm= (file, w)->
  w= be_even(w)
  obj= reconcile_paths(file, "#{w}", "webm")
  size= resolution(w)
  console.log " ---Webm #{w} ---"
  console.log size
  run_sync("ffmpeg -i #{obj.input} -y -c:v libvpx -c:a libvorbis -pix_fmt yuv420p -quality good -b:v 2M -crf 5 -strict -2 -vf 'scale=#{size}' #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output

mp4= (file, w)->
  w= be_even(w)
  obj= reconcile_paths(file, "#{w}", "mp4")
  size= resolution(w)
  console.log " ---mp4 #{w} ---"
  run_sync("ffmpeg -i #{obj.input} -y -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -preset faster -crf 18 -vf scale=#{size} #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output


#grab png from first frame
thumbnail= (file, w)->
  w= be_even(w)
  obj= reconcile_paths(file, "#{w}", "png")
  size= resolution(w)
  console.log " ---thumbnail #{w} ---"
  run_sync("ffmpeg -i #{obj.input} -y -vframes 1 -map 0:v:0 -vf 'scale=#{size}' #{obj.output}")
  return obj.output


#remove old videos+audio
rm_builds= ->
  builds = shell.ls("#{assets}/derivative/")
  builds.forEach (v)->
    v= "#{assets}/derivative/#{v}"
    shell.rm(v)

#all sizes & thumnails for a given video
rebuild= (file)->
  sizes= [1280, 853, 458]
  # sizes= [458]
  sizes.forEach (w)->
    webm(file, w)
    mp4(file, w)
    thumbnail(file, w)

#rebuild all videos in ./assets/video_master
build_all= ()->
  videos = shell.ls("#{assets}/video_master/")
  # rm_builds()
  videos.forEach (f)->
    console.log "===#{f}==="
    rebuild(f)


videos = shell.ls("#{assets}/video_master/")
#
# analysis.play resize_video(videos[0], 86)
# analysis.play webm(videos[0], 287)
# thumbnail(videos[0], 487)
# rebuild(videos[0])
build_all()


# console.log reconcile_paths("shakey_spring.mp4", "OLD")
# console.log resolution(486)


