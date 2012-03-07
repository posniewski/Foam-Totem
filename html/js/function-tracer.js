//------------------------------------------------------------------------------
// JavaScript function tracer for "classes"
//------------------------------------------------------------------------------
// from: pmuellr@muellerware.org
// home: http://gist.github.com/189144
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// define our function tracer
//------------------------------------------------------------------------------
FunctionTracer = {};

//------------------------------------------------------------------------------
// logging function, default is to write to console
//------------------------------------------------------------------------------
FunctionTracer.logFunction = function(message) { console.log(message); };

//------------------------------------------------------------------------------
// print time in messages?
//------------------------------------------------------------------------------
FunctionTracer.printTime = false;

//------------------------------------------------------------------------------
// print arguments in messages?
//------------------------------------------------------------------------------
FunctionTracer.printArgs = false;

 var FuncInfo = function(name) {
	this.name = name;
	this.totalTime = 0;
	this.myTime = 0;
	this.count = 0;
	this.totalHeap = 0;
	this.myHeap = 0;
};


FunctionTracer.childTimes = [];
FunctionTracer.timerStack = [];
FunctionTracer.funcs = {};

//------------------------------------------------------------------------------
// return a registered function
// example: say you have a function named "foo".  You can trace it via:
//    foo = FunctionTracer.traceFunction(foo, "foo");
//------------------------------------------------------------------------------
FunctionTracer.traceFunction = function(func, name) {
	if (!FunctionTracer.startTime) FunctionTracer.startTime = new Date().getTime();

	if (!FunctionTracer.indent) FunctionTracer.indent = "";

	//--------------------------------------------------------------------------
	// best effort printing an argument as a string
	//--------------------------------------------------------------------------
	function arg2string(argument) {
		if (argument === null) return "null";
		if (argument === undefined) return "undefined";
		try {
			return JSON.stringify(argument);
		}
		catch(e) {
			return argument.toString();
		}
	}

	//--------------------------------------------------------------------------
	// this function creates a wrapper for each function which traces itself,
	// then invokes the original function
	//--------------------------------------------------------------------------
	function getWrapper(func, name) {
		if (typeof func != "function") throw new Error(name + " is not a function");

		return function timer() {
			var oldIndent = FunctionTracer.indent;
			FunctionTracer.indent += "   ";

			var message = oldIndent + name;

			if (FunctionTracer.printTime) {
				var time = new Date().getTime() - FunctionTracer.startTime;
				time = "" + time;
				while (time.length < 8) time = " " + time;

				message = time + ": " + message;
			}

			if (!FunctionTracer.printArgs) {
				message += "()";
			}
			else {
				message += "(";

					for (var i=0; i<arguments.length; i++) {
						message += arg2string(arguments[i]);
						if (i != arguments.length - 1) {
							message += ", ";
						}
					}

				message += ")";
			}

			var timer = {};
			timer.timer = new chrome.Interval();
			timer.depth = FunctionTracer.childTimes.length;
			FunctionTracer.timerStack.push(timer);
			timer.timer.start();
			timer.heap = performance.memory.usedJSHeapSize;

if(FunctionTracer.timerStack.length === 1 && timer.depth > 0) {
	console.log("ouch");
}

			try {
				//				(FunctionTracer.logFunction)(message);
				return func.apply(this, Array.prototype.splice.call(arguments, 0));
			}
			catch(e) {
				(FunctionTracer.logFunction)(message + "; exception: " + e);
				throw e;
			}
			finally {

				timer = FunctionTracer.timerStack.pop();
				timer.timer.stop();

				if(!FunctionTracer.funcs[name]) {
					FunctionTracer.funcs[name] = new FuncInfo(name);
				}
				var funcinfo = FunctionTracer.funcs[name];
   
				if(performance.memory.usedJSHeapSize - timer.heap > 0) {
					// I checked for this in case a GC happens.
					funcinfo.myHeap += performance.memory.usedJSHeapSize - timer.heap;
				}

				var total = timer.timer.microseconds();

				funcinfo.count++;
				funcinfo.totalTime += total;

				var childsum = 0;
				while(FunctionTracer.childTimes.length > timer.depth) {
					childsum += FunctionTracer.childTimes.pop();
				}
				funcinfo.myTime += total-childsum;

				if(FunctionTracer.timerStack.length > 0) {
					FunctionTracer.childTimes.push(total);
				}

				FunctionTracer.indent = oldIndent;
			}
		}
	}

	//--------------------------------------------------------------------------
	// main function logic
	//--------------------------------------------------------------------------
	(FunctionTracer.logFunction)("installed tracer: " + name + "()");

	return getWrapper(func, name);
}

//------------------------------------------------------------------------------
// register functions in an object to trace themselves
// example: say you have a 'class' called FooBar, that has a bunch of methods
// in it by virtual of having functions defined on FooBar.prototype.  You can
// trace those methods via:
//    FunctionTracer.traceFunctionsInObject(FooBar.prototype, "FooBar.");
//------------------------------------------------------------------------------
FunctionTracer.traceFunctionsInObject = function(object, prefix) {

	//--------------------------------------------------------------------------
	// process the functions in the object
	//--------------------------------------------------------------------------
	var functions = {};
	var getters   = {};
	var setters   = {};
	var isES5     = this.__lookupGetter__;

	for (var property in object) {
		//----------------------------------------------------------------------
		// ignore inherited properties
		//----------------------------------------------------------------------
		if (!object.hasOwnProperty(property))
			continue;

		//----------------------------------------------------------------------
		// check for getters/setters
		//----------------------------------------------------------------------
		var getter = undefined;
		var setter = undefined;

		if (isES5) {
			getter = object.__lookupGetter__(property);
			setter = object.__lookupSetter__(property);
		}

		var name = prefix + property;

		//----------------------------------------------------------------------
		// found a getter/setter?
		//----------------------------------------------------------------------
		if (getter || setter) {
			if (getter) {
				getters[property] = FunctionTracer.traceFunction(getter, name + "<get>");
			}

			if (setter) {
				setters[property] = FunctionTracer.traceFunction(setter, name + "<set>");
			}
		}

		//----------------------------------------------------------------------
		// found a function?
		//----------------------------------------------------------------------
		else {
			var func = object[property];
			if (typeof func != "function") continue;

			functions[property] = FunctionTracer.traceFunction(func, name);
		}
	}

	//--------------------------------------------------------------------------
	// install the wrappers; didn't do this in the original loop since we are
	// in some sense mutating the object while iterating on it's properties,
	// typically not a safe thing to do
		//--------------------------------------------------------------------------

	for (var property in functions) {
		object[property] = functions[property];
		(FunctionTracer.logFunction)("installed tracer: " + prefix + property + "()");
	}

	for (var property in getters) {
		object.__defineGetter__(property, getters[property]);
		(FunctionTracer.logFunction)("installed tracer: " + prefix + property + "<get>()");
	}

	for (var property in setters) {
		object.__defineSetter__(property, setters[property]);
		(FunctionTracer.logFunction)("installed tracer: " + prefix + property + "<set>()");
	}
}
