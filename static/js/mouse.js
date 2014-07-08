
function mouseCustom() {
    var src = "/static/img/profile_s.gif"
    var ganmen = $("<div class='ganmen'><img src='"+src+"'></div>")
    $(ganmen).css({overflow:'hidden', position:'absolute', top:'0', left:'0'});
    $('body').append(ganmen);
    $('html').mousemove(function(e){
        var icon = $(ganmen).offset();
        $(ganmen).stop();
        $(ganmen).animate({
            top:e.pageY+50,
            left:e.pageX+50
            },{
                duration: 1000,
                specialEasing:{
                    top:'easeOutCirc',
                    left:'easeOutCirc'
                }});
    });
}
