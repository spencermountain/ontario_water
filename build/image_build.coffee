shell = require("shelljs")
path= require("path")
analysis= require("./analysis")
run_sync= require("./cmd")
assets= path.join(__dirname, '../assets')

analyse= (file)->
  cmd= "ffprobe -v quiet -print_format json -show_format -show_streams #{file}"
  data= JSON.parse(run_sync(cmd)).streams[0]
  return {
    width:data.width||1,
    height:data.height||1,
  }

height_for= (w, data={})->
  r= data.height/data.width
  return parseInt(w*r)

resize= (file, w)->
  obj= {}
  obj.input= path.join(assets, '/image_master/', file)
  obj.name= path.basename(obj.input)
  old_ext= path.extname(obj.name)
  data= analyse(obj.input)
  obj.output= path.join(assets, "/derivative", "#{path.basename(obj.input, old_ext)}_#{w}.jpg")
  if w>data.width #don't up-size
    w= data.width
  h= height_for(w, data)
  cmd= "ffmpeg -i #{obj.input} -y -vf scale=#{w}:#{h} #{obj.output}"
  console.log cmd
  run_sync(cmd)
  return obj

resize("shangri_la_toronto.jpg", 400)
resize("shangri_la_toronto.jpg", 700)
resize("shangri_la_toronto.jpg", 900)
resize("shangri_la_toronto.jpg", 4900)
