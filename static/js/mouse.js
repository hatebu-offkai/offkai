function mouseCustom() {
    var src = "/static/img/profile_s.gif";
    var ganmen = $("<div class='ganmen'><img src='"+src+"'></div>");
    $(ganmen).css({overflow:'hidden', position:'absolute', top:'0', left:'0'});
    $('body').append(ganmen);

    $('html').mousemove(function(ev){
        var position = [10, 25, 40, 50, 70];
        var randPosX = position[Math.floor(Math.random()*position.length)];
        var randPosY = position[Math.floor(Math.random()*position.length)];
        $(".ganmen").stop();
        $(".ganmen").animate({
            top:ev.pageY+50,
            left:ev.pageX+50
            },{
                duration: 1000,
                specialEasing:{
                    top:'easeOutCirc',
                    left:'easeOutCirc'
                }});
    });
}
