#pretty-print audio + video data using ffprobe
shell = require("shelljs")
path = require("path")
run_sync= require("./cmd")


# var file= process.argv[2];
format_seconds = (i=0) ->
  i= parseFloat(i)
  if i > 60
    s = parseInt(i % 60)
    s = "0" + s  if s < 10
    return parseInt(i / 60) + ":" + s
  i.toFixed(1) + "seconds"

timeSince = (date) ->
  seconds = Math.floor((new Date() - date) / 1000)
  interval = Math.floor(seconds / 31536000)
  return interval + " years ago"  if interval > 1
  interval = Math.floor(seconds / 2592000)
  return interval + " months ago"  if interval > 1
  interval = Math.floor(seconds / 86400)
  return interval + " days ago"  if interval > 1
  interval = Math.floor(seconds / 3600)
  return interval + " hours ago"  if interval > 1
  interval = Math.floor(seconds / 60)
  return interval + " minutes ago"  if interval > 1
  Math.floor(seconds) + " seconds ago"

humanFileSize = (bytes=0, si) ->
  thresh = (if si then 1000 else 1024)
  return bytes + " B"  if bytes < thresh
  units = ["kb", "Mb", "Gb", "Tb", "Pb", "Eb", "Zb", "Yb"]
  u = -1
  loop
    bytes /= thresh
    ++u
    break unless bytes >= thresh
  bytes.toFixed(1) + " " + units[u]

format_audio = (obj) ->
  return `undefined`  unless obj
  obj.tags = obj.tags or {}
  date = undefined
  date = timeSince(new Date(obj.tags.creation_time))  if obj.tags.creation_time
  return {
    type: obj.codec_name
    channels: obj.channel_layout + "(" + (obj.channels or 0) + ")"
    created: date
  }

format_video = (obj) ->
  return `undefined`  unless obj
  date = undefined
  if obj.tags.creation_time
    date = timeSince(new Date(obj.tags.creation_time))
  return {
    type: obj.codec_name
    size: obj.width + "x" + obj.height
    created: date
  }


metadata= (file)->
  cmd= "ffprobe -v quiet -print_format json -show_format -show_streams #{file}"
  data= JSON.parse(run_sync(cmd))
  data.format = data.format or {}
  name = path.basename(data.format.filename)
  audio = data.streams.filter((s) ->
    s.codec_type == "audio"
  )
  video = data.streams.filter((s) ->
    s.codec_type == "video"
  )
  obj =
    name: name
    length: format_seconds(data.format.duration or 0)
    size: humanFileSize(data.format.size)
    tracks: "#{audio.length} audio, #{video.length} video"
    audio: format_audio(audio[0])
    video: format_video(video[0])
  return obj


pretty_print= (file)->
  obj= metadata(file)
  console.log "================= " + obj.name + " ================="
  delete obj.name
  Object.keys(obj).forEach (k) ->
    if typeof obj[k] is "object"
      console.log " " + k + "-"
      Object.keys(obj[k]).forEach (k2) ->
        console.log "   " + k2 + ": " + obj[k][k2]  if obj[k][k2]
    else
      console.log " " + k + " :  " + obj[k]  if obj[k]



module.exports = {
  metadata:metadata,
  pretty_print:pretty_print
}

pretty_print("./assets/audio/dylanleslie_slow_jam.mp3")
pretty_print("./assets/video/norwood.MOV")