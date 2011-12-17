
///////////////////////////////////////////////////
//
// HTML5 functions
// 

//
// String.trim
// 
// Trim whitespace from left and right of a string
// 
if(typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function() {
		return this.replace(/^\s\s*/g, '').replace(/\s\s*$/g, ''); 
	}
}

//
// window.requestAnimationFrame
//
if(window) {
	if(!window.requestAnimationFrame) {
		window.requestAnimationFrame = window.webkitRequestAnimationFrame
			|| window.mozRequestAnimationFrame
			|| window.oRequestAnimationFrame
			|| window.msRequestAnimationFrame
			|| function(/* function */ callback, /* DOMElement */ element) { window.setTimeout(callback, 1000 / 60); };
	}
}


