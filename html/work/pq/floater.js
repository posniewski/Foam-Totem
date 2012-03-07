(function () {


var Floater = {};

if (typeof exports !== 'undefined') {
	if (typeof module !== 'undefined' && module.exports) {
		exports = module.exports = Floater;
	}
	exports.Floater = Floater;
}
else if (typeof define === 'function' && define.amd) {
	// This is for AMD-style exporting
	define('Floater', function() { return Floater; });
}
else {
	// No special system, just stick it in the global namespace
	this['Floater'] = Floater;
}

///////////////////////////////////////////////////

Floater.parent = null;

Floater.SetParent = function(eParent) {
	Floater.parent = eParent;
}

Floater.aFloaters = [];

Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

function UpdateFloaters(time) {
	var a = Floater.aFloaters;
	for (var i=0; i<a.length; i+=1) {
		if(a[i].done) {
	        Floater.parent.removeChild(a[i].div);
			a.remove(i);
		}
		else {
			UpdateFloater(a[i], time);
		}
	};

	if(a.length > 0) {
		window.requestAnimationFrame(UpdateFloaters);
	}
}


function UpdateFloater(float, time) {
	if(time > float.start) {
		div.style.visibility = 'visible';

		if(time > float.end) {
			float.div.style.left = float.dx + 'px';
			float.div.style.top = float.dy + 'px';
			float.done = true;
		}
		else {
			var t = (time - float.start) / (float.end - float.start);
			float.div.style.left = ((t*(float.dx - float.sx)+float.sx)|0) + 'px';
			float.div.style.top = ((t*(float.dy - float.sy)+float.sy)|0) + 'px';

			//console.log(float.div.style.left, float.div.style.top,float.div.innerHTML);
		}
	}
}


Floater.AddFloater = function(html, className, sx, sy, dx, dy, duration, delay) {
	var f = {};

	f.sx = sx-150/2; // minus half-width  ;
	f.sy = sy-50/2;  // minus half-height ;
	f.dx = dx-150/2; // minus half-width
	f.dy = dy-50/2;  // minus half-height
	f.start = Date.now()+delay*1000;
	f.end = f.start + duration*1000;
	f.done = false;

	if(!Floater.parent) {
		console.log("You need to call Floater.SetParent() first.");
	}
	else {
		div = document.createElement('div');
		div.className = className;
		div.innerHTML = html;

		div.style.left = f.sx + 'px';
		div.style.top = f.sy + 'px';

        if(delay>0) {
			div.style.visibility = 'hidden';
		}

        Floater.parent.appendChild(div);

		f.div = div;

		Floater.aFloaters.push(f);
	}

	if(Floater.aFloaters.length > 0) {
		window.requestAnimationFrame(UpdateFloaters);
	}
}


}());

