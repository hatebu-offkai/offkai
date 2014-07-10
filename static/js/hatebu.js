function hatebuButtonShower() {
	setInterval(button_x_x, 40);
	setInterval(button_x_y, 40);
	setInterval(button_y_x, 40);
	setInterval(button_y_y, 40);
}

function button_x_x() {
	var x = Math.ceil(Math.random()*100);
	var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_x_x" style="left:'+x+'%" />');
	$button.appendTo('body').animate({
		'top': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}

function button_x_y() {
	var y = Math.ceil(Math.random()*100);
	var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_x_y" style="left:'+y+'%" />');
	$button.appendTo('body').animate({
		'bottom': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}

function button_y_x() {
	var x = Math.ceil(Math.random()*100);
	var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_y_x" style="top:'+x+'%" />');
	$button.appendTo('body').animate({
		'left': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}

function button_y_y() {
	var x = Math.ceil(Math.random()*100);
	var $button = $('<img src="http://b.st-hatena.com/images/entry-button/button-only@2x.png" class="button_y_y" style="top:'+x+'%" />');
	$button.appendTo('body').animate({
		'right': '120%'
	}, 700, 'linear')
	.queue(function() {
		this.remove();
	});
}