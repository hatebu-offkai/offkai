$(function(){
    console.log("onload");
    loadYoutube(
      mouseCustom
    );
    hatebuButtonShower();

    $('.destroy').click(function() {
    	destroy();
    });
  }
);
