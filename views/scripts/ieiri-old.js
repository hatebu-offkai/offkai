
$(function() {

	var rave = new buzz.sound("http://182.48.54.40/rave",{
		formats: [ "ogg", "mp3" ],
	    preload: true,
	    autoplay: false
	});

	rave.bind("playing", function(e) {
		fever();
	});

    $(document).ready(function(e){
        setInterval(fireworks, 3000);
        lazyLoadContents();
        mouseIeiri();
        numberOfVotes();
    });

    setInterval("removeFireworks()", 20000);
});

function removeFireworks() {
    $('.fireworks').remove();
}

var wrapper = $('.wrapper');

function lazyLoadContents(){
    loadYoutube(function(){
        loadTweetButtons(function(){
            loadIframes();
        });
    });
};

//
function loadTwitterWidgets() {
    console.log("loadTwitterWidgets");
    !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');
}
function loadTweetButtons(done) {
    console.log("loadTweetButtons");
    langList = [
        "ru", "fr", "ar", "es", "ko", "ru", "fil", "zh-tw", "zh-ch", "hi",
        "ru", "fr", "ar", "es", "ko", "ru", "fil", "zh-tw", "zh-ch", "hi"
    ];
    $.each(langList, function(idx, lang){
        button = $("<div class='twbtn'><a class='twitter-share-button' href='https://twitter.com/share'>Tweet</a></div>");
        button = button.find("a").attr({
            "data-url":"http://ieirikazuma.com/",
            "data-via":"hbkr",
            "data-related":"hbkr",
            "data-hashtags":"非公式ぼくらの政策",
            "data-size":"large",
            "data-lang":lang,
        });
        $("#tweetbuttons").append(button);
        if(idx == langList.length-1){
            loadTwitterWidgets();
            done();
        }
    });

}


var sizeList = ["20","40","50","80","100","150","200","250"];
var params = {page:1, per_page:15, total:null, rest:null}
function fireworks() {
    $.getJSON('/app/users', params, function(data, status, xhr){
        params.total = data.total;
        params.rest = data.total-(data.per_page*data.page);
        if (params.rest > 0) {
            params.page = parseInt(data.page)+1;
        } else {
            params.page = 1;
        }
        $.each(data.users, function(idx, user){
            var rand_x = Math.floor(Math.random()*90);
            var rand_y = Math.floor(Math.random()*80);
            var size = sizeList[Math.floor(Math.random() * sizeList.length)];
            wrapper.append('<img src="'+user.ieiriIcon+'" class="fireworks" style="width:'+size+'px;height:'+size+'px;left:'+rand_x+'%; top:'+rand_y+'%;" />');
        });
    });
}


function numberOfVotes() {
    var unixtime = Math.floor(new Date().getTime()/1000);
    var num = unixtime*Math.random()*0.00001;
    num *= 1.0;
    var keta = ['万', '億', '兆', '京', '垓', '𥝱', '穣', '溝', '澗', '正', '載', '極', '恒河沙', '阿僧祇', '那由他', '不可思議', '無量大数'];
    var text = '';
    for ( var i = keta.length - 1; i >= 0; i-- ) {
        var num2 = Math.floor( num / Math.pow( 10, i * 4 ) );
        if ( num2 > 0 ) {
            text += num2 + keta[i];
            num = num % Math.pow( 10, i * 4 );
        }
    }
    document.title = "東京都知事候補者 家入一真  予想得票数 "+text+"票 非公式ホームページ";
}

var rainbow_count = $('.rainbow').size();
var $h2 = $('h2');
var $rainbow = $('.rainbow');
var $span = $('span');

function fever() {
	$h2.kabuki().rainbow();

	setInterval('beat()', 460);

	for (var i=0; i<rainbow_count; i++) {
		console.log('rainbow');
		$rainbow.eq(i).kabuki().rainbow();
		$rainbow.eq(i).children('a').kabuki().rainbow();
	}
}

function beat() {
	$h2.animate({scale:'1.5'},30).delay(60).animate({scale:'1.0'},30);
	$h2.animate({rotate: '+=360deg', scale: '3.0'}, 120);
	$('.fireworks').animate({rotate: '+=360deg', scale: '2.0'}, 200);
	$span.animate({rotate:'+=360deg',scale:'2.5'},400).delay(10).animate({scale:'1.0'},10);
}

