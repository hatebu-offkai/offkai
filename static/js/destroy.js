function destroy() {
	$('img').attr({'src': 'http://cdn7.www.st-hatena.com/users/ne/netcraft/profile.gif'});
	$('div').css({'background': 'url(http://cdn7.www.st-hatena.com/users/ne/netcraft/profile.gif)'});

	setInterval(function() {
		$('img').animate({
			'scale': '5.0',
			'rotate': '+=360'
		}, 300).animate({
			'scale': '1.0',
			'rotate': '+=360'
		}, 300);
	}, 1000);
}