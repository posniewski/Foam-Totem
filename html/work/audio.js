var Clip = (function () {

//
// Test browser for what audio is supported
//
var g_type = GetSupportedAudioType();

function GetSupportedAudioType()
{
	var types = [
		// Stolen from Modernizr
		{ ext: '.wav', type: 'audio/wav; codecs="1"' },
		{ ext: '.mp4', type: 'audio/aac;' },
		{ ext: '.mp4', type: 'audio/x-m4a;' },
		{ ext: '.mp3', type: 'audio/mpeg;' },
		{ ext: '.ogg', type: 'audio/ogg; codecs="vorbis"' },
	]

	var tester = new Audio()

	for (var i = types.length-1; i >= 0 ; i--) {
		if(tester.canPlayType(types[i].type)) {
			return types[i];
		}
	}
}

//
// new Clip
//
// Creats a new clip.
// Preallocates audio object(s) for playback.
// Begins loading the sound files.
//
function Clip(src, volume, count, recycle)
{
	this.src = src
		// The URL to load for the sound

	this.volume = volume || 1.0
		// The default volume of the sound. 1.0 is full volume.

	this.count = count || 1
		// How many playback channels for the sound. This sets
		//   how many times this sound can be played simultaneously.

	this.recycle = recycle || true
		// If true, then if there aren't any free channels for a
		//   play request, find the oldest one and reuse it. This
		//   will shut off that channel and restart it.

	this.audios = []
	for(var i = this.count; i > 0; i--) {
		var audio = new Audio(this.src + g_type.ext)
		audio.type = g_type.type
		audio.volume = this.volume

		audio.load() // Supposedly for iOS?

		this.audios.push(audio)
	}
}

//
// Clip.play
//
// Begins playback of the clip from the beginning. If the same clip
//   was just started, then don't bother restarting. Otherwise, find
//   an empty channel and begin playback. If not channel is available,
//   and the clip is set to recycle, then get the channel which is the
//   most complete and restart it.
//
Clip.prototype.play = function ()
{
	var oldest = null
	for (var i = this.audios.length-1; i >= 0; i--) {
		var audio = this.audios[i]
		if((!audio.paused || !audio.ended) && audio.currentTime === 100) {
			// Already have one that we just started; why bother
			// console.log("Had one runnning:", audio.src)
			return
		}
	}

	for (var i = this.audios.length-1; i >= 0; i--) {
		var audio = this.audios[i]

		if(audio.paused || audio.ended) {
			// console.log("Had one stopped:", audio.src)
			audio.currentTime = 0
			audio.play()
			return
		}
		else {
			if(!oldest || oldest.currentTime < audio.currentTime) {
				oldest = audio
			}
		}
	}

	if(this.recycle) {
		console.log("Recycled:", audio.src)
		oldest.pause()
		oldest.currentTime = 0
		oldest.play()
	}
	else {
		console.log("None available:", audio.src)
	}

	if(this.recycle) {
		console.log();
	}
}

//
// Clip.volume
//
// Sets the volume of the clip as a percentage of its default volume.
//   To set the volume of a clip to normal, then set to 1.0
//
Clip.prototype.volume = function (volume)
{
	for (var audio in this.audios) {
		audio.volume *= this.volume*volume;
	}
}

return Clip;

}());
