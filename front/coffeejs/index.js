// Generated by CoffeeScript 1.8.0
var arr;

arr = ["./libs/jquery.js", "./libs/sugar.js", "./libs/oj.js", "./libs/easings.js", "./libs/dirty.js", "./libs/inview.js", "./coffeejs/stages.js"];

head.js.apply(this, arr);

head(function() {
  var CHEAT_AMOUNT, CURRENT_STAGE, change_stage, scrollHandler, which_stage, y;
  oj.useGlobally();
  CHEAT_AMOUNT = parseInt(window.innerHeight * 0.33);
  CURRENT_STAGE = null;
  y = 0;
  $("#main").oj(div(function() {
    return stages.map(function(s, i) {
      return div({
        "class": "stage",
        style: "height:" + s.height + "px; overflow:hidden; width:100%; border:1px solid grey; font-size:68px;",
        insert: function() {
          s.el = $(this);
          s.preload();
          return s;
        }
      }, function() {
        return i;
      });
    });
  }));
  which_stage = function() {
    var bottom, real_estate, top;
    top = parseInt(window.pageYOffset);
    bottom = parseInt(top + window.innerHeight);
    real_estate = stages.map(function(s, i) {
      if (s.top >= top && s.bottom <= bottom) {
        s.visibility = parseInt(s.bottom - s.top) || 0;
      } else if (s.top < top && s.bottom > top) {
        s.visibility = parseInt(s.bottom - top) || 0;
      } else if (s.top < bottom && s.bottom > bottom) {
        s.visibility = parseInt(bottom - s.top) || 0;
      } else {
        s.visibility = 0;
      }
      return s;
    });
    return real_estate.sort(function(a, b) {
      return (b.visibility - a.visibility) || 0;
    })[0].i || 0;
  };
  change_stage = function(i) {
    var s, _i, _len;
    if (i !== CURRENT_STAGE) {
      CURRENT_STAGE = i;
      console.log("changing to " + i);
      for (_i = 0, _len = stages.length; _i < _len; _i++) {
        s = stages[_i];
        if (s.state === "playing" && s.i !== i) {
          s.stop();
        }
      }
    }
    return stages[i].play();
  };
  scrollHandler = function() {
    var i;
    i = which_stage();
    if (i !== CURRENT_STAGE) {
      return change_stage(i);
    }
  };
  $(window).on('scroll', function() {
    return window.requestAnimationFrame(scrollHandler);
  });
  return change_stage(which_stage());
});

//# sourceMappingURL=index.js.map
