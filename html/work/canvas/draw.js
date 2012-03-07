
(function () {

var Draw = {};

if (typeof exports !== 'undefined') {
	if (typeof module !== 'undefined' && module.exports) {
		exports = module.exports = Draw;
	}
	exports.Draw = Draw;
}
else if (typeof define === 'function' && define.amd) {
	// This is for AMD-style exporting
	define('Draw', function() { return Draw; });
}
else {
	// No special system, just stick it in the global namespace
	this['Draw'] = Draw;
}

///////////////////////////////////////////////////


function Shape(def)
{
	this.def = def;
	this.shapes = [];
};

Shape.prototype.draw = function()
{
	// Draw myself
	if(typeof this.def === 'function')
	{
		this.def.call(T);
	}
	else
	{
//		console.log(this.def);
	}

	// Draw all my children
	for(var i = 0; i < this.shapes.length; i++)
	{
		this.shapes[i].draw();
	}
};

Shape.prototype.addShape = function(def)
{
	var s = new Shape(def);
	this.shapes.push(s);
	return s;
}

///////////////////////////////////////////////////

var T = {
	ctx: {},
	drawing: true,
	up: function up() {
		this.drawing = false;
	},
	down: function down() {
		this.drawing = true;
	},
	toggle: function toggle() {
		this.drawing = !this.drawing;
	},
	cir: function cir(rad) {
		this.ctx.arc(0, 0, rad, 0, 2*Math.PI);
	},
	fwd: function fwd(x, y) {
		this.ctx.translate(x, y);
		if(this.drawing) {
			this.ctx.lineTo(0, 0);
		}
		else {
			this.ctx.moveTo(0, 0);
		}
	},
	rot: function rot(deg) {
		this.ctx.rotate(deg/180*Math.PI);
	},
	scale: function scale(x, y) {
		this.ctx.scale(x, y);
	},
};

///////////////////////////////////////////////////

Draw.Shape = Shape;
Draw.T = T;

///////////////////////////////////////////////////

Draw.shapes = [];
Draw.canvas = {};
Draw.ctx = {};
Draw.root = {};

///////////////////////////////////////////////////

Draw.init = function (name)
{
	this.canvas = document.getElementById(name);
	this.ctx = this.canvas.getContext('2d');
	this.root = new Shape('');
}

Draw.draw = function()
{
	T.ctx = this.ctx;
	this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
	this.ctx.save();
	this.ctx.beginPath();
	this.root.draw();
	this.ctx.restore();
};

Draw.addShape = function(def)
{
	return this.root.addShape(def);
}

///////////////////////////////////////////////////

}());

