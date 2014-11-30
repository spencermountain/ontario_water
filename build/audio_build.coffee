# a nodejs html5 audio build script, from:
#  https://blog.mediacru.sh/2013/12/23/The-right-way-to-encode-HTML5-video.html
#

# file= process.argv[2];
shell = require("shelljs")
path= require("path")
run_sync= require("./cmd")
analysis= require("./analysis")
assets= path.join(__dirname, '../assets')


reconcile_paths= (file="", flag="", ext="mp3")->
  obj= {}
  obj.input= path.join(assets, '/audio_master/', file)
  obj.name= path.basename(obj.input)
  old_ext= path.extname(obj.name)
  obj.output= path.join(assets, "/builds", "#{path.basename(obj.input, old_ext)}#{flag}.#{ext}")
  return obj


ogg= (file, h)->
  obj= reconcile_paths(file, "", "ogg")
  console.log " ---ogg ---"
  run_sync("ffmpeg -i #{obj.input} -y -acodec libvorbis -map 0:a:0 #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output

mp3= (file, h)->
  obj= reconcile_paths(file, "", "mp3")
  console.log " ---mp3 ---"
  run_sync("ffmpeg -i #{obj.input} -y -acodec libmp3lame -map 0:a:0 #{obj.output}")
  analysis.diff(obj.input, obj.output)
  return obj.output


#all formats for an audio file
rebuild= (file)->
  ogg(file)
  mp3(file)

#rebuild all audio files in ./assets/audio_master
build_all= ()->
  audios = shell.ls("#{assets}/audio_master/")
  audios.forEach (f)->
    console.log "===#{f}==="
    rebuild(f)


build_all()


