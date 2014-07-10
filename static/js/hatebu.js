function hatebuButtonShower() {
	setInterval(button_x_x, 40);
	setInterval(button_x_y, 40);
	setInterval(button_y_x, 40);
	setInterval(button_y_y, 40);
}

function button_x_x() {
	var x = Math.ceil(Math.random()*100);
	if (Math.floor( Math.random()*1) === 1) {
		var $button = $('<img src="http://b.hatena.ne.jp/images/users/normal/09999.png" class="button_x_x" style="left:'+x+'%" />');
	} else {
		var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_x_x" style="left:'+x+'%" />');
	}
	$button.appendTo('body').animate({
		'top': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}

function button_x_y() {
	var y = Math.ceil(Math.random()*100);
	if (Math.floor(Math.random()*1) === 1) {
		var $button = $('<img src="http://b.hatena.ne.jp/images/users/normal/09999.png" class="button_x_y" style="left:'+y+'%" />');
	} else {
		var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_x_y" style="left:'+y+'%" />');
	}
	$button.appendTo('body').animate({
		'bottom': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}

function button_y_x() {
	var x = Math.ceil(Math.random()*100);
	if (Math.floor(Math.random()*1) === 1) {
		var $button = $('<img src="http://b.hatena.ne.jp/images/users/normal/09999.png" class="button_y_x" style="top:'+x+'%" />');
	} else {
		var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_y_x" style="top:'+x+'%" />');
	}
	$button.appendTo('body').animate({
		'left': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}

function button_y_y() {
	var x = Math.ceil(Math.random()*100);
	if (Math.floor(Math.random()*1) === 1) {
		var $button = $('<img src="http://b.hatena.ne.jp/images/users/normal/09999.png" class="button_y_y" style="top:'+x+'%" />');
	} else {
		var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_y_y" style="top:'+x+'%" />');
	}
	$button.appendTo('body').animate({
		'right': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}