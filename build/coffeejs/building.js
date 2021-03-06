// Generated by CoffeeScript 1.8.0
var analysis, assets, be_even, build_all, mp4, path, rebuild, reconcile_paths, resolution, rm_builds, run_sync, shell, thumbnail, webm;

shell = require("shelljs");

path = require("path");

run_sync = require("./cmd");

analysis = require("./analysis");

assets = path.join(__dirname, 'assets');

resolution = function(h) {
  var w;
  if (!h) {
    return "iw:ih";
  }
  w = parseInt(h * (16 / 9));
  w = be_even(w);
  return "" + w + ":" + h;
};

reconcile_paths = function(file, flag, ext) {
  var obj, old_ext;
  if (file == null) {
    file = "";
  }
  if (flag == null) {
    flag = "";
  }
  if (ext == null) {
    ext = "mp4";
  }
  obj = {};
  obj.input = path.join(assets, '/video_master/', file);
  obj.name = path.basename(obj.input);
  old_ext = path.extname(obj.name);
  obj.output = path.join(assets, "/builds", "" + (path.basename(obj.input, old_ext)) + flag + "." + ext);
  return obj;
};

be_even = function(h) {
  if (!h) {
    return null;
  }
  return Math.floor(h / 2) * 2;
};

webm = function(file, h) {
  var obj, size;
  h = be_even(h);
  obj = reconcile_paths(file, "" + h, "webm");
  size = resolution(h);
  console.log(" ---Webm " + h + " ---");
  run_sync("ffmpeg -i " + obj.input + " -y -c:v libvpx -c:a libvorbis -pix_fmt yuv420p -quality good -b:v 2M -crf 5 -vf 'scale=" + size + "' " + obj.output);
  analysis.diff(obj.input, obj.output);
  return obj.output;
};

mp4 = function(file, h) {
  var obj, size;
  h = be_even(h);
  obj = reconcile_paths(file, "" + h, "mp4");
  size = resolution(h);
  console.log(" ---mp4 " + h + " ---");
  run_sync("ffmpeg -i " + obj.input + " -y -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -preset slower -crf 18 -vf scale=" + size + " " + obj.output);
  analysis.diff(obj.input, obj.output);
  return obj.output;
};

thumbnail = function(file, h) {
  var obj, size;
  h = be_even(h);
  obj = reconcile_paths(file, "" + h, "png");
  size = resolution(h);
  console.log(" ---thumbnail " + h + " ---");
  run_sync("ffmpeg -i " + obj.input + " -y -vframes 1 -map 0:v:0 -vf 'scale=" + size + "' " + obj.output);
  return obj.output;
};

rm_builds = function() {
  var builds;
  builds = shell.ls("" + assets + "/builds/");
  return builds.forEach(function(v) {
    v = "" + assets + "/builds/" + v;
    return shell.rm(v);
  });
};

rebuild = function(file) {
  var sizes;
  sizes = [258, 480, 720];
  return sizes.forEach(function(h) {
    webm(file, h);
    mp4(file, h);
    return thumbnail(file, h);
  });
};

build_all = function() {
  var videos;
  videos = shell.ls("" + assets + "/video_master/");
  rm_builds();
  return videos.forEach(function(f) {
    console.log("===" + f + "===");
    return rebuild(f);
  });
};

build_all();

//# sourceMappingURL=building.js.map
