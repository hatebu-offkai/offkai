
var startMatrix = function(){
  var s = window.screen;
  var width = q.width = s.width;
  var height = q.height = s.height;
  var letters = Array(256).join(1).split('');


  var draw = function () {
    var fontSize = 14;
    q.getContext('2d').font = "14px 'ＭＳ Ｐゴシック'";
    q.getContext('2d').fillStyle='rgba(0,0,0,.05)';
    q.getContext('2d').fillRect(0,0,width,height);
    q.getContext('2d').fillStyle='#0F0';
    var textBase = "齊藤貴義".split("");
    letters.map(function(y_pos, index){
      //text = String.fromCharCode(3e4+Math.random()*33);
      text = textBase[Math.floor(Math.random()*textBase.length)];
      x_pos = index * fontSize;
      q.getContext('2d').fillText(text, x_pos, y_pos);
      letters[index] = (y_pos > 758 + Math.random() * 1e4) ? 0 : y_pos + fontSize;
    });
  };
  setInterval(draw, 33);
};
