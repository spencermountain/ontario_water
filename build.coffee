# a nodejs html5 video build script, from:
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")

assets= path.join(__dirname, 'assets')


#create the build directory
if !shell.test("-d", "#{assets}/built_files")
  shell.mkdir("-p","#{assets}/built_files")

videos = shell.ls("#{assets}/video/")
audios = shell.ls("#{assets}/audio/")

build_video= (file)->
  cmd= "ffmpeg -i #{file} -q 5 -pix_fmt yuv420p -acodec libvorbis -vcodec libtheora output.ogv"

  #webm
  console.log "building webm"
  cmd= """ffmpeg -i #{file} -c:v libvpx -c:a libvorbis -pix_fmt yuv420p -quality good -b:v 2M -crf 5 -vf "scale=trunc(in_w/2)*2:trunc(in_h/2)*2" output.webm"""


# ffmpeg -i ./assets/video/norwood.MOV -q 5 -pix_fmt yuv420p -acodec libvorbis -vcodec libtheora output.ogv


# timelapse
# ffmpeg -r 30 -i img%03d.png -c:v libx264 -r 30 -pix_fmt yuv420p out.mp4
