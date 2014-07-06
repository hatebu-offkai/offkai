
var youtubeCurrentVideo = null;
var youtubeVideoList = [
    "Th-Z6le3bHA", // ソヴィエト
    "Th-Z6le3bHA", // ソヴィエト
    "Th-Z6le3bHA", // ソヴィエト
    "j1UflQ0WeR0", // 紅
    "LSbnECOt5WA", // シンガポールナイトサファリ (ショー)
    "kfLbhmQkzOY" // シンガポールナイトサファリ (ツアー)
];

// loadYoutube
function loadYoutube(done) {
    youtubeCurrentVideo = youtubeVideoList[Math.floor(Math.random() * youtubeVideoList.length)];
    var youtubeUrl = "//www.youtube.com/embed/"+youtubeCurrentVideo+"?rel=0&controls=0&showinfo=0&autoplay=1&loop=1&cc_load_policy=1&vq=hd720";
    console.log("loadYoutube", youtubeUrl);
    $("#kurenai").attr("src", youtubeUrl).load(done());
    $(".kurenai").css({width:"80px", height:"60px"})
};

// onload
$(function() {
    $('.kurenai').mouseover(function(e){
        $('.kurenai').stop().animate({
            width: "95%",
            height: "95%"
        }, 3500, "easeInOutCubic");
    });
    $('.kurenai').mouseout(function(e){
        $('.kurenai').stop().animate({
            width: "80px",
            height: "60px"
        }, 500)
    });
});
