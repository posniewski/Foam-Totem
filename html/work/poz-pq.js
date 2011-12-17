
var poz_PQ = (function () {

//////////////////////

if(typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function() {
		return this.replace(/^\s\s*/g, '').replace(/\s\s*$/g, ''); 
	}
}

function RemoveClass (elem, remove) {
	var re = new RegExp('\\b'+remove+'\\b');
	elem.className = elem.className.replace(re, '').trim();
}

//////////////////////

if(!window.requestAnimationFrame) {
	window.requestAnimationFrame = 
			window.webkitRequestAnimationFrame
			|| window.mozRequestAnimationFrame
			|| window.oRequestAnimationFrame
			|| window.msRequestAnimationFrame
			|| function(/* function */ callback, /* DOMElement */ element) { window.setTimeout(callback, 1000 / 60); };
}

//////////////////////

var g_game = {
	// Number of boxes in board
	width: 7,
	height: 7,

	// Selected boxes
	first: null,
	second: null,
	
	// How big each tile is
	gridSize: 93,

	// Selection is allowed
	select: true,

	// How many matches have been made in a row
	consecutiveMatches: 1,

	// how many blocks in a row have been deleted
	series: 0,

	// The total score
	score: 0,

	// The actual board
	board: []
}

var e_board = null;
var e_scorelog = null;
var e_score = null;

var g_audio = {
	click : { audio: null, volume: 1.0, count: 5 },
	clack : { audio: null, volume: 1.0, count: 2 },
	empty : { audio: null, volume: 1.0, count: 1 },
	zap   : { audio: null, volume: 1.0, count: 4 },
	bomb  : { audio: null, volume: 1.0, count: 4 },
	chime1: { audio: null, volume: 0.3, count: 3 },
	chime2: { audio: null, volume: 0.5, count: 2 },
	chime3: { audio: null, volume: 0.7, count: 1 },
	chime4: { audio: null, volume: 1.0, count: 1 },
};
var g_scores = [ 0, 3, 0, 10, 20, 40, 0, 0, 0 ] // last three aren't possible

var g_types = [
	{ css: 'x' },
	// g_typestart
	{ css: 'g' },
	{ css: 'r' },
	{ css: 'b' },
	{ css: 'y' },
	{ css: 'p' },
	{ css: 'w' }
]
var g_typestart = 1;
var g_specials = [
	{ css: '',     cb: null },
	{ css: 'bomb', cb: DestroyNear },
	{ css: 'zap',  cb: DestroyHV   },
]

function OnMouseOver(evt) {
	if(g_game.select) {
		g_audio['click'].audio.play()
	}
}

function OnClick(evt) {
	if(!g_game.select) {
		return
	}

	if(evt.shiftKey) {
		this.block.special = 1
		this.block.div.className = 'block '+g_specials[this.block.special].css+' '+g_types[this.block.type].css
		return
	}
	else if(evt.ctrlKey) {
		this.block.special = 2
		this.block.div.className = 'block '+g_specials[this.block.special].css+' '+g_types[this.block.type].css
		return
	}
	else if(evt.altKey) {
		this.block.type = 0
		this.block.div.className = 'block '+g_specials[this.block.special].css+' '+g_types[this.block.type].css
		return
	}

	this.className += " selected"
	var f = g_game.first
	var s = this.block

	if(g_game.first) {

		var dx = s.x-f.x
		var dy = s.y-f.y
		if((dx && dy)
			|| dx > 1
		|| dx < -1
		|| dy > 1
		|| dy < -1)
		{
			RemoveClass(f.div, "selected")
			g_game.first = s
		}
		else
		{
			g_game.second = s

			g_game.board[s.x][s.y] = f
			g_game.board[f.x][f.y] = s

			if(TestMatches()) {
				var x = f.x
				var y = f.y
				f.x = s.x
				f.y = s.y
				s.x = x
				s.y = y

				f.div.style.left = f.x*g_game.gridSize+'px'
				f.div.style.top = f.y*g_game.gridSize+'px'

				s.div.style.left = s.x*g_game.gridSize+'px'
				s.div.style.top = s.y*g_game.gridSize+'px'

				g_game.select = false
				e_board.className += ' nosel'
				window.setTimeout(ProcessMatches, .5*1000)
			}
			else {
				g_game.board[s.x][s.y] = s
				g_game.board[f.x][f.y] = f

				RemoveClass(f.div, "selected")
				RemoveClass(s.div, "selected")
				g_game.first = null
				g_game.second = null
			}
		}
	}
	else {
		g_game.first = s
	}

}

/////////////////////////////////////////

function ProcessBoard(OnMatchH, OnMatchV, state)
{
	// Find all horizontal matches
	for(var y=0; y < g_game.height; y++) {
		var count = 1
		var wilds = 0
		var test = g_game.board[0][y].type
		for(var x=1; x < g_game.width; x++) {

			if(test === 0
				|| g_game.board[x][y].type === test
				|| g_game.board[x][y].type === 0)
			{
				if(test === 0) {
					wilds += 1
					test = g_game.board[x][y].type
				}
				else if(g_game.board[x][y].type === 0) {
					wilds += 1
				}
				else {
					wilds = 0
				}
				count += 1
			}
			else {
				if(count >= 3 || wilds >= 2) {
					// we have a match
					if(count < 3) {
						count = 3 // This fixes count up for wilds
					}

					if(!OnMatchH(count, x, y, state)) {
						return;
					}
				}

				count = 1 + wilds // Handle trailing wilds
				wilds = 0
				test = g_game.board[x][y].type
			}
		}

		if(count >= 3) {
			// we have a match
			if(!OnMatchH(count, x, y, state)) {
				return
			}
		} 

	}

	// Find all vertical matches
	for(var x=0; x < g_game.width; x++)
	{
		var count = 1
		var wilds = 0
		var test = g_game.board[x][0].type
		for(var y=1; y < g_game.height; y++)
		{

			if(test ===0
				|| g_game.board[x][y].type === test
				|| g_game.board[x][y].type === 0)
			{
				if(test === 0) {
					wilds += 1
					test = g_game.board[x][y].type
				}
				else if(g_game.board[x][y].type === 0) {
					wilds += 1
				}
				else {
					wilds = 0
				}
				count += 1
			}
			else {
				if(count >= 3 || wilds >= 2) {
					// we have a match
					if(count < 3) {
						count = 3 // Fix up the count for trailing wilds
					}

					if(!OnMatchV(count, x, y, state)) {
						return;
					}
				}

				count = 1 + wilds // Handle trailing wilds
				wilds = 0
				test = g_game.board[x][y].type
			}
		}

		if(count >= 3) {
			// we have a match
			if(!OnMatchV(count, x, y, state)) {
				return;
			}
		}

	}
}

////////////////////////

function OnMatchTest (count, x, y, state)
{
	state.matched = true
	return false // exit early
}

function TestMatches () {
	var state  = { matched: false }

	ProcessBoard(OnMatchTest, OnMatchTest, state)

	return state.matched
}

////////////////////////

function PermuteChoices () {
	var matched = false

	for(var y=0; y < g_game.height; y++) { 
		for(var x=0; x < g_game.width-1; x++) {
			var f = g_game.board[x][y]
			var s = g_game.board[x+1][y]
			
			g_game.board[x][y] = s
			g_game.board[x+1][y] = f

			matched = TestMatches()

			g_game.board[x][y] = f
			g_game.board[x+1][y] = s

			if(matched) {
				return true
			}
		}
	}

	for(var x=0; x < g_game.width; x++) {
		for(var y=0; y < g_game.height-1; y++) {
			var f = g_game.board[x][y]
			var s = g_game.board[x][y+1]
			
			g_game.board[x][y] = s
			g_game.board[x][y+1] = f

			matched = TestMatches()

			g_game.board[x][y] = f
			g_game.board[x][y+1] = s

			if(matched) {
				return true
			}
		}
	}

	return false
}

////////////////////////

function AddScore(count) {
	if(count === 0) {
		g_game.consecutiveMatches = 1
		g_game.series = 0
	}
	else {
		var mul = (g_game.series / 12)|0
		g_game.score += g_scores[count] * (mul+g_game.consecutiveMatches)
		g_game.series += count

		e_scorelog.value += g_scores[count]+' * ('+mul+'+'+g_game.consecutiveMatches+') = '+g_scores[count]*(mul+g_game.consecutiveMatches)+'\n'
		e_score.innerHTML = g_game.score

		if((g_game.series % 12)|0 === 0) {
			// Show bonus thingy?
		}
	}
}

var g_queue = [];
function QueueSpecial(f, x, y) {
	// console.log("QueueSpecials: ", f, x, y);
	g_queue.push( { f: f, x: x, y: y } );
}

function ProcessSpecials(q) {
	while (special = q.pop()) {
		// console.log("ProcessSpecials: ", special.f, special.x, special.y);
		special.f(special.x, special.y);
	}
}

function DestroyHV(x, y) {
	g_audio['zap'].audio.play();
	for(var i = 0; i < g_game.width; i++) {
		g_game.board[i][y].div.className += " zappedh"
		if(!g_game.board[i][y].matched) {
			AddScore(1)
			MarkMatch(g_game.board[i][y], i, y, true)
		}
	}
	for(var i = 0; i < g_game.width; i++) {
		g_game.board[x][i].div.className += " zappedv"
		if(!g_game.board[x][i].matched) {
			AddScore(1)
			MarkMatch(g_game.board[x][i], x, i, true)
		}
	}
	g_game.board[x][y].div.className += " zappedc"
}

function DestroyNear(x, y) {
	g_audio['bomb'].audio.play();
	for(var i = x-1; i <= x+1; i++) {
		if(i < 0 || i >= g_game.width) {
			continue;
		}

		for(var j = y-1; j <= y+1; j++) {
			if(j < 0 || j >= g_game.height) {
				continue;
			}

			g_game.board[i][j].div.className += " bombed"
			if(!g_game.board[i][j].matched) {
				AddScore(1)
				MarkMatch(g_game.board[i][j], i, j, true)
			}
		}
	}
}

function PlaceSpecial(b, count) {
	if(count === 4) {
		b.special = 1 // array entry for bomb.
	}
	else if(count === 5) {
		b.special = 2 // array entry for zap.
	}
	b.div.className = 'block '+g_specials[b.special].css+' '+g_types[b.type].css
	b.matched = false
}

function MarkMatch(b, x, y, delay) {
	if(!b.matched) {
		b.div.className += " matched"
		b.matched = true
		if(g_specials[b.special].cb) {
			if(!delay) {
				g_specials[b.special].cb(x, y);
			}
			else {
				QueueSpecial(g_specials[b.special].cb, x, y);
			}
		}
	}
}

function OnMatchH(count, x, y, state)
{
	state.totalMatched += count
	AddScore(count)

	for(var m = x-count; m < x; m++) {
		MarkMatch(g_game.board[m][y], m, y)
	}

	if(count >= 4) {
		PlaceSpecial(g_game.board[(x-count/2)|0][y], count)
	}
}

function OnMatchV(count, x, y, state)
{
	state.totalMatched += count
	AddScore(count)

	for(var m = y-count; m < y; m++) {
		MarkMatch(g_game.board[x][m], x, m)
	}

	if(count >= 4) {
		PlaceSpecial(g_game.board[x][(y-count/2)|0], count)
	}
}

function ProcessMatches()
{
	var state = { totalMatched: 0 }

	ProcessBoard(OnMatchH, OnMatchV,state)
	
	if(state.totalMatched > 0) {
		var clip = 'chime' + (g_game.consecutiveMatches % 4 + 1);
		g_audio[clip].audio.play()

		g_game.consecutiveMatches += 1
		window.setTimeout(AnimStep, .25*1000)
	}
	else {
		AddScore(0)
		if(!PermuteChoices()) {
			g_audio['empty'].audio.play()
			for(var x=0; x < g_game.width; x++) { 
				for(var y=0; y < g_game.height; y++) {
					g_game.board[x][y].div.className += ' failed'
					g_game.board[x][y].matched = true;
				}
			}

			window.setTimeout(RemoveAndRefill, .5*1000)
		}
		else {
			RemoveClass(e_board, 'nosel')
			g_game.select = true;
		}
	}
}

function AnimStep ()
{
	if(g_game.first) {
		RemoveClass(g_game.first.div, 'selected')
		g_game.first = null
	}
	if(g_game.second) {
		RemoveClass(g_game.second.div, 'selected')
		g_game.second = null
	}

	if(g_queue.length) {
		var q = g_queue
		g_queue = []

		ProcessSpecials(q);

		g_game.consecutiveMatches += 1
		window.setTimeout(AnimStep, .25*1000)
	}
	else {
		window.setTimeout(RemoveAndRefill, .25*1000)
	}
}

function RemoveAndRefill () {
	var cnt = 6
	for(var x=0; x < g_game.width; x++) { 
		var curtop = 0;
		for(var y=0; y < g_game.height; y++) {
			// remove delays to avoid ugly transitions 
			g_game.board[x][y].div.style.webkitTransitionDelay = null
			g_game.board[x][y].div.style.MozTransitionDelay = null
			g_game.board[x][y].div.style.transitionDelay = null

			if(g_game.board[x][y].matched) {
				var b = g_game.board[x].splice(y, 1)[0]

				cnt+=1

				b.matched = false

				if(cnt > 12) {
					cnt = 0
					b.type = 0 // drop a wild every 6 or so
					console.log("wild")
				}
				else {
					b.type = g_typestart+(Math.random()*(g_types.length-g_typestart)|0)
				}
				b.special = 0 // (Math.random()*2)|0
				b.div.className = 'block '+g_types[b.type].css+' '+g_specials[b.special].css;

				curtop++;
				b.div.style.top = (-g_game.gridSize*curtop)+'px'

				g_game.board[x].splice(0,0,b)
			}
		}
		for(var y=0; y < g_game.height; y++) {
			var b = g_game.board[x][y]
			b.x = x
			b.y = y
		}
	}

	// This hand-waving shuts off the transitions and lets some of the divs
	//   teleport to their interim position. Reposition() will turn transtions
	//   back on and move them to their final position in a pretty way
	e_board.className = 'nosel'
	setTimeout(Reposition, 20)
}

function Reposition () {
	e_board.className += ' trans'; // turns transitions back on
	for(var x=0; x < g_game.width; x++) { 
		for(var y=0; y < g_game.height; y++) {
			// Delay the transitions so the boxes come in staggered
			g_game.board[x][y].div.style.webkitTransitionDelay = ((g_game.height-y)+(g_game.width-x))*.02+'s'
			g_game.board[x][y].div.style.MozTransitionDelay = ((g_game.height-y)+(g_game.width-x))*.02+'s'
			g_game.board[x][y].div.style.transitionDelay = ((g_game.height-y)+(g_game.width-x))*.02+'s'

			g_game.board[x][y].div.style.left = x*g_game.gridSize + 'px'
			g_game.board[x][y].div.style.top = y*g_game.gridSize + 'px'
		}
	}
	window.setTimeout(ProcessMatches, .5*1000)
}

///////////////////////////////

function CreateBlockDiv (x, y, type)
{
	x = x || 0
	y = y || 0
	type = type || 0

	var div; 
	div = document.createElement('div')

	div.className = 'block ' + type

	div.style.left = x + 'px'
	div.style.top = y + 'px'

	div.onclick = OnClick
	div.onmouseover = OnMouseOver

	return div
}

function Block (x, y, type, special)
{
	this.x = x
	this.y = y
	this.type = type
	this.special = special || 0

	this.div = CreateBlockDiv(g_game.gridSize*x, -g_game.gridSize*(g_game.height-y), g_types[type].css+g_specials[special].css)
	this.div.block = this;
}

function InitBoard(w, h)
{
	for(var x = w-1; x >= 0; x--) {
		g_game.board[x] = [];
		for(var y = h-1; y >= 0; y--) {
			var block = new Block(x, y, 0, 0)
			e_board.appendChild(block.div)
			g_game.board[x][y] = block
		}
	}
}

function FillBoard()
{
	for(var x = g_game.width-1; x >= 0; x--) {
		for(var y = g_game.height-1; y >= 0; y--) {
			var type = g_typestart+(Math.random()*(g_types.length-g_typestart)|0)

			g_game.board[x][y].type = type;
			g_game.board[x][y].div.className = 'block '+g_types[type].css+' '+g_specials[g_game.board[x][y].special].css;
		}
	}
}

function InitAudio ()
{
	for (clip in g_audio) {
		g_audio[clip].audio = new Clip('/work/'+clip, g_audio[clip].volume, g_audio[clip].count)
	}
}

return {
	Run: function (w, h) {
		e_board = document.getElementById('board')
		e_scorelog = document.getElementById('scorelog')
		e_score = document.getElementById('score')

		g_game.width = w || g_game.width;
		g_game.height = h || g_game.height;

		e_board.style.width = g_game.width*g_game.gridSize+5+'px';
		e_board.style.height = g_game.height*g_game.gridSize+5+'px';

		InitAudio()

		InitBoard(g_game.width, g_game.height)
		FillBoard()
		while(!PermuteChoices()) {
			console.log('Reinit')
			FillBoard()
		}

		setTimeout(Reposition, .5*1000)
	}
}

}());

