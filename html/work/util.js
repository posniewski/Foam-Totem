
(function () {

// Establish the root object, which could be window or global depending

var MODULE = { }

if (typeof exports !== 'undefined') {
	if (typeof module !== 'undefined' && module.exports) {
		exports = module.exports = MODULE;
	}
	exports.##MODULE = MODULE;
}
else if (typeof define === 'function' && define.amd) {
	// This is for AMD-style exporting
	define('underscore', function() { return MODULE; });
}
else {
	// No special system, just stick it in the global namespace
	this[#MODULE] = MODULE;
}

///////////////////////////////////////////////////
//
// Helpers
//


//
// Util.RemoveClass
//
// Removes the given class name from an element's css class list
// 
Util.RemoveClass = function (elem, remove)
{
	var re = new RegExp('\\b'+remove+'\\b');
	elem.className = elem.className.replace(re, '').trim();
}

///////////////////////////////////////////////////

}());

