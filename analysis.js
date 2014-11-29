var file="/Users/spencer/mountain/ontario_water/assets/norwood.MOV"
var file="/Users/spencer/mountain/ontario_water/assets/dylanleslie_slow_jam.mp3"
// var file= process.argv[2];

var ffmpeg = require('fluent-ffmpeg');
var path= require("path")

var humanFileSize= function(bytes, si) {
    var thresh = si ? 1000 : 1024;
    if(bytes < thresh) return bytes + ' B';
    var units = ['kB','MB','GB','TB','PB','EB','ZB','YB']
    var u = -1;
    do {
        bytes /= thresh;
        ++u;
    } while(bytes >= thresh);
    return bytes.toFixed(1)+' '+units[u];
};

function format_seconds(i){
  if(i>60){
    var s=parseInt(i%60)
    if(s<10){
      s="0"+s
    }
    return parseInt(i/60) + ":"+ s
  }
  return i.toFixed(1)+"seconds"
}


function timeSince(date) {
    var seconds = Math.floor((new Date() - date) / 1000);
    var interval = Math.floor(seconds / 31536000);
    if (interval > 1) {
        return interval + " years ago";
    }
    interval = Math.floor(seconds / 2592000);
    if (interval > 1) {
        return interval + " months ago";
    }
    interval = Math.floor(seconds / 86400);
    if (interval > 1) {
        return interval + " days ago";
    }
    interval = Math.floor(seconds / 3600);
    if (interval > 1) {
        return interval + " hours ago";
    }
    interval = Math.floor(seconds / 60);
    if (interval > 1) {
        return interval + " minutes ago";
    }
    return Math.floor(seconds) + " seconds ago";
}

var format_audio= function(obj){
  if(!obj){
    return undefined
  }
  obj.tags=obj.tags || {}
  var date;
  if(obj.tags.creation_time){
    date=timeSince(new Date(obj.tags.creation_time))
  }
  return {
    type:obj.codec_name,
    channels:obj.channel_layout + "("+(obj.channels||0)+")",
    created:date
  }
}

var format_video= function(obj){
  if(!obj){
    return undefined
  }
  var date;
  if(obj.tags.creation_time){
    date=timeSince(new Date(obj.tags.creation_time))
  }
  return {
    type:obj.codec_name,
    size:obj.width+"x"+obj.height,
    created:date
  }
}


var pretty_print=function(obj){
  console.log("================= "+obj.name+" =================")
  delete obj.name
  Object.keys(obj).forEach(function(k){
    if(typeof obj[k]=="object"){
      console.log(" "+k+"-")
      Object.keys(obj[k]).forEach(function(k2){
        if(obj[k][k2]){
          console.log("   "+k2+": "+obj[k][k2])
        }
      })
    }else{
      if(obj[k]){
        console.log(" "+k + " :  "+obj[k])
      }
    }
  })
  console.log("=================  =================")
}

ffmpeg.ffprobe(file, function(err, metadata) {
    if(err){
      console.log(err);
      process.exit(1);
    }

    metadata.format= metadata.format||{}
    var name=path.basename(metadata.format.filename)
    var audio=metadata.streams.filter(function(s){return s.codec_type=="audio"})
    var video=metadata.streams.filter(function(s){return s.codec_type=="video"})
    var obj={
      name:name,
      length: format_seconds(metadata.format.duration||0),
      size: humanFileSize(metadata.format.size),
      tracks: audio.length+" audio, "+video.length+" video",
      audio:format_audio(audio[0]),
      video:format_video(video[0])
    }
    pretty_print(obj);
});