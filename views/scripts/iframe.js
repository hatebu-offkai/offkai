
var iframeUrlList = [
    "https://www.nhk.or.jp/jirenma/guest_ieirikazuma.html",
    "http://www.slideshare.net/sinpost2/20140127-f",
    "https://www.facebook.com/ieirikazuma",
    "http://nlab.itmedia.co.jp/nl/articles/1312/19/news127.html",
    "http://www.kakugo.tv/detail_789.html",
    "http://alternas.jp/study/it_social/14334",
    "http://ieiri.net/assets/img/main.jpg",
    "https://www.facebook.com/groups/339881266150122/"
];

// loadIframes
function loadIframes() {
    console.log("loadIframes");
    move = ["move-right", "move-left"];
    $.each(iframeUrlList, function(idx, url){
        setTimeout(function(){
            iframe = $("<iframe></iframe>");
            iframe.attr("src", url);
            iframe.addClass("ieiri-site"+(idx+1));
            iframe.addClass(move[Math.floor(Math.random() * iframeUrlList.length)]);
            console.log("append iframe", url);
            $(".iframe-wrap").append(iframe);
        }, 100*idx);
    });
}


$(function() {
    $('.move-left').mouseover(function(){
        $(this).animate({'right': '+=10px'},2000);
    });
    $('.move-right').mouseover(function(){
        $(this).animate({'left': '+=10px'},2000);
    });
});
