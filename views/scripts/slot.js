
var slotLeft;
var slotCenter;
var slotRight;

var slotRollLeft;
var slotRollCenter;
var slotRollRight;

var $slotLeft;
var $slotCenter;
var $slotRight;
var $slotRestart;

function slotStart() {
    slotRollLeft();
    slotRollCenter();
    slotRollRight();

    $slotLeft.removeClass('stop');
    $slotCenter.removeClass('stop');
    $slotRight.removeClass('stop');
}

function slotRollLeft() {
    var rand = Math.floor(Math.random()*7);
    $slotLeft.css({'backgroundImage': 'url(assets/img/slot-'+rand+'.jpg)'});
    $slotLeft.attr({'data-yama': rand});
    slotStopLeft = setTimeout("slotRollLeft();", 250);
}

function slotRollCenter() {
    var rand = Math.floor(Math.random()*7);
    $slotCenter.css({'backgroundImage': 'url(assets/img/slot-'+rand+'.jpg)'});
    $slotCenter.attr({'data-yama': rand});
    slotStopCenter = setTimeout("slotRollCenter();", 250);
}

function slotRollRight() {
    var rand = Math.floor(Math.random()*7);
    $slotRight.css({'backgroundImage': 'url(assets/img/slot-'+rand+'.jpg)'});
    $slotRight.attr({'data-yama': rand});
    slotStopRight = setTimeout("slotRollRight();", 250);
}

$(function() {
    //スロットのjqueryオブジェクトをキャッシュ
    $slotLeft = $('#slot-left');
    $slotCenter = $('#slot-center');
    $slotRight = $('#slot-right');
    $slotRestart = $('#slot-restart');

    //スロットの左のストップボタンが押された時の処理
    $('#slot-stop-left').click(function() {
        clearTimeout(slotStopLeft);
        slotLeft = $slotLeft.attr('data-yama');

        $slotLeft.addClass('stop');

        if ($slotLeft.hasClass('stop') && $slotCenter.hasClass('stop') && $slotRight.hasClass('stop')) {
            if (slotLeft == slotCenter && slotLeft == slotRight) {
                fever();
            } else {
                $slotRestart.fadeIn();
            }
        }
    });
    //スロットの中央のストップボタンが押された時の処理
    $('#slot-stop-center').click(function() {
        clearTimeout(slotStopCenter);
        slotCenter = $slotCenter.attr('data-yama');

        $slotCenter.addClass('stop');

        if ($slotLeft.hasClass('stop') && $slotCenter.hasClass('stop') && $slotRight.hasClass('stop')) {
            if (slotLeft == slotCenter && slotLeft == slotRight) {
                fever();
            } else {
                $slotRestart.fadeIn();
            }
        }
    });
    //スロットの右のストップボタンが押された時の処理
    $('#slot-stop-right').click(function() {
        clearTimeout(slotStopRight);
        slotRight = $slotRight.attr('data-yama');

        $slotRight.addClass('stop');

        if ($slotLeft.hasClass('stop') && $slotCenter.hasClass('stop') && $slotRight.hasClass('stop')) {
            if (slotLeft == slotCenter && slotLeft == slotRight) {
                fever();
            } else {
                $slotRestart.fadeIn();
            }
        }
    });

    //スロットの再スタートボタンが押された時の処理
    $slotRestart.click(function() {
        slotStart();
        $(this).fadeOut();
    });

    //スロット回転開始
    slotStart();
});
