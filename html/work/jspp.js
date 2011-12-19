//
// jspp - A JavaScript preprocessor
//
// Copyright (c) 2011, Shannon Posniewski (posniewski@gmail.com)
// 
// You may do anything with this work that copyright law would normally
// restrict, so long as you retain the above notices) and this license
// in all redistributed copies and derived works.  There is no warranty.
//

(function () {

//
// escape
//
// Escapes regex metacharacters in the given string, and returns it
//
function escape(str)
{
	return str.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")
}

//
// ProcessDefines
//
// Scans through the string, collecting any defines or macros found, storing 
//   them in the given object.
//   
// Returns the input string modified such that the defines and macros are 
//   commented out.
//
function ProcessDefines(str, defines)
{
	// This beast of a regular expression finds preprocessor commands.
	//   It requires a # being the first non-space character on a line,
	//     immediately followed by a directive.
	//   At the moment, it then requires whitespace and another word.
	//   After that, everything is optional, but is used by defines/macros
	var re_start = /^[ \t]*#(\w+)[ \t]+(\w+)(?:(?:([^\n\r]*[^"\n\r])$)|(?:([^\r\n]*)(""")$))*/m
		// 1 = type of preproc directive: define|macro
		// 2 = name
		// 3 = parameters or body if no here doc
		// 4 = parameters or body if there is a here doc
		// 5 = """ if a here doc


	var res
	while(res = re_start.exec(str)) {
		var define = {
			type: res[1].toLowerCase(),
				// Type of define. Either 'define' (text replacement)
				//   or 'macro' (code-generated replacement)

			name: res[2],
				// The name of the define

			name_restr: "\\b"+escape(res[2])+"\\s*\\(",
				// The regex string for finding instance of this define in 
				//   code
					// 1 - the matched name

			body: "" ,
				// The actual body of the define. This will be modified by 
				//   having instances of args replaced with the passed 
				//   parameters

			args: null,
				// Object array mapping argument name to index

			args_restr: "",
				// The regex string for replacing arguments in the define body
				//   1 - if 2 is # and this isn't a #, the character preceding the #
				//   2 - # if the char preceding the arg is a #
				//   3 - the matched argname

			re_args: null,
				// The RegExp object for args_restr

			exec_pre: "",
			exec_post: "",
				// For macros, the two parts of the eval string

			start: res.index
				// The location where this define was defined. Used for 
				//  determining if the define is in scope. (Currently UNUSED)
		}

		var start = res.index;
		var end = res.index+res[0].length;

		var arg_str
		if(res[5]) {
			// If res[5] is defined, then there's a here doc to slurp up for 
			//   the body
			var here_start = end
			var here_end = end
			var done = 0
			while(done < 3) {
				if(str[here_end]==='"')
					done += 1
				else
					done = 0

				here_end += 1
			}
			define.body = str.slice(here_start, here_end-3)
				.replace(/^\r{0,1}\n{0,1}/, "")
				.replace(/\r{0,1}\n{0,1}$/, "")

			end = here_end

			arg_str = res[4]
		}
		else {
			arg_str = res[3]
		}

		if(arg_str) {
			var args = GetArgs(arg_str, 0)
			if(!define.body) {
				define.body = args.pop()
			}
			else {
				// Don't want the last part if we've already picked up the body
				args.pop()
			}

			// Generate the regex for finding the args in the body
			//   and make the reverse index (args)
			// The tests for # and ## in the regex are to capture the weld 
			//   and stringize operations.
			define.args = { }
			define.args_restr = "(?:\\b|([^#])(#))("
			for(i=0; i<args.length; i++) {
				define.args[args[i]] = i
				if(i>0) {
					define.args_restr += "|"
				}
				define.args_restr += escape(args[i])
			}
			define.args_restr += ")\\b"
			define.re_args = new RegExp(define.args_restr, "g")
		}

		if(define.type === "macro") {
			// Generate the parts of the function for later execution.
			//   Everything but the passed arguments, which are added at
			//   each instantiation
			var exec = "(function ("
			for(var arg in define.args) {
				if(define.args[arg]>0) exec += ","
				exec += arg
			}
			exec += "){"+define.body+"}("

			define.exec_pre = exec;
			define.exec_post = "));"
		}

		// Finally all done. Save the define.
		defines[define.name] = define

		// Comment out the define in the code
		str = str.slice(0, start)
			+ '//'
			+ res[0]
			+ (res[5] ? define.body.replace(/\n/g, "\n//")+'"""' : "")
			+ str.slice(end)
	}

	return str
}

//
// ExpandDefines
//
// Does macro expansion in the given string.
//
// Returns the transformed string.
// 
function ExpandDefines(str, defines, invariants)
{
	for(var name in defines) {
		var res
		var define = defines[name]
		var name_re = new RegExp(define.name_restr, "g")
		while(res = name_re.exec(str))
		{
			var end
			if(define.args_restr)
			{
				var args = GetArgs(str, res.index)
				if(define.type === "define")
				{
					var repl = define.body.replace(define.re_args,
						function (entire_match, notweld_hash, stringize_hash, matched_arg) {
							var ret = ""
							if(stringize_hash === "#") {
								if(notweld_hash !== undefined) {
									// This isn't part of the actual part we 
									//   want to replace, so stick it back in 
									//   the result.
									// This was captured in the regex so we can 
									//   distinguish stringinze (#) and weld (##)
									ret += notweld_hash
								}
								// Stringize the replacement
								ret += '"'+args[define.args[matched_arg]]+'"'
							}
							else {
								// Stuff the unchanged replacement in there
								ret += args[define.args[matched_arg]]
							}
							return ret
						})

					repl = RemoveInvariants(repl, invariants) 
					repl = repl.replace(/\s*##\s*/g, "")

					str = str.slice(0, res.index)+repl+str.slice(args.end)
				}
				else if(define.type === "macro")
				{
					var exec_args = ""
					for(var arg in define.args) {
						if(define.args[arg]>0) exec_args += ","
						exec_args += args[define.args[arg]]
					}
					exec_args = ReplaceInvariants(exec_args, invariants)

					var answer = eval(define.exec_pre+exec_args+define.exec_post)

					answer = RemoveInvariants(answer, invariants)
					str = str.slice(0, res.index)+answer+str.slice(args.end)
				}
			}
			else
			{
				str = str.slice(0, res.index)
					+define.body
					+str.slice(res.index+define.name.length)
			}
		}
	}

	return str
}

//
// GetArgs
//
// Given a string and a starting point, create an array of arguments gathered 
//   from the string. Strings and sub-parenthetical expressions are supported.
//   The remainder of the line not part of the argument list is returned as 
//   the last element in the array.
//
// Returns the array of args, and the leftover portion of the line as the last 
//   element.
//
// Examples:
//   GetArgs("func(x, y) body", 0) => [ "x", "y", "body" ]
//   GetArgs("func((1+2)*q, 'fun()')", 0) => [ "(1+2)*q", " 'fun()'", ""]
//
//
function GetArgs(str, idxStart)
{
	var args = []
	var depth = 0
	var start = 0
	var inquote = false
	var indquote = false

	args.start = idxStart
	var pos = idxStart
	while(pos < str.length) {
		if((inquote || indquote) && str[pos] === '\\') {
			// Skip over the escaped character
			pos += 1
		}
		else if(!inquote && !indquote && str[pos] === '(') {
			if(depth === 0) {
				start = pos+1
			}
			depth += 1
		}
		else if(!inquote && !indquote && str[pos] === ')') {
			depth -= 1
			if(depth === 0) {
				args.push(str.slice(start, pos).trim())
				break
			}
		}
		else if(!inquote && !indquote && depth === 1 && str[pos] === ',') {
			args.push(str.slice(start, pos).trim())
			start = pos+1
		}
		else if(!inquote && str[pos] === "\"") {
			indquote = !indquote
		}
		else if(!indquote && str[pos] === "'") {
			inquote = !inquote
		}

		pos += 1
	}

    args.push(str.slice(pos+1).trim())
	args.end = pos+1

	return args
}


//
// ProcessLineNumbers
//
// Replaces __LINE__ with the line number the token is found on.
// This is called early on, before any macro expansion has been done. The
//   line number will be the line number where the token is found in the
//   original source file.
//   
function ProcessLineNumbers(str)
{
	var lines = str.split(/\r*\n/)
	str = ""

	var re = /__LINE__/
	for(var i=0; i<lines.length; i++) {
		lines[i] = lines[i].replace(re, i)
	}

	return lines.join("\n")
}

//
// ProcessLinePPNumbers
//
// Replaces __LINE_PP__ with the line number the token is found on.
// This is called after all macro expansion has been done, providing line
//   numbers in the post-processed output.
//
function ProcessLinePPNumbers(str)
{
	var lines = str.split(/\r*\n/)
	str = ""

	var re = /__LINE_PP__/
	for(var i=0; i<lines.length; i++) {
		lines[i] = lines[i].replace(re, i)
	}

	return lines.join("\n")
}


//
// RemoveInvariants
//
// This function removes comments and strings, substituting them with 
//   tokens. The original text is saved in the given array.
//
// This is done so macro replacement (or other program transformations) can't
//   affect them. Once processing is complete, the tokens are replaced with 
//   the original text (via ReplaceInvariants).
//
function RemoveInvariants(str, invariants)
{
	var pos = 0
	var last = ""
	var incomment = false
	var inq = false
	var indq = false
	var start, end

	while(pos < str.length) {
		if((inq || indq) && str[pos] === '\\') {
			// Skip over the escaped character
			pos += 1
		}
		else if(incomment === "/" ) {
			if(str[pos] === "\n") {
				incomment = ""

				invariants.push(str.slice(start, pos))
				str = str.slice(0, start)+"~#"+(invariants.length-1)+"#~"+str.slice(pos)
				pos = start
			}
		}
		if(incomment === "/*" ) {
			if(last === "*" && str[pos]==="/") {
				incomment = ""
				invariants.push(str.slice(start, pos+1))
				str = str.slice(0, start)+"~#"+(invariants.length-1)+"#~"+str.slice(pos+1)
				pos = start
			}
		}
		else if(!inq && !indq && str[pos]==="/" && last === "/") {
			incomment = "/"
			start = pos-1
		}
		else if(!inq && !indq && last === "/" && str[pos]==="*") {
			incomment = "/*"
			start = pos-1
		}
		else if(!incomment && !indq && str[pos]==="'") {
			if(inq) {
				invariants.push(str.slice(start, pos+1))
				str = str.slice(0, start)+"~#"+(invariants.length-1)+"#~"+str.slice(pos+1)
				pos = start
			}
			else {
				start = pos
			}

			inq = !inq
		}
		else if(!incomment && !inq && str[pos]==='"') {
			if(indq) {
				invariants.push(str.slice(start, pos+1))
				str = str.slice(0, start)+"~#"+(invariants.length-1)+"#~"+str.slice(pos+1)
				pos = start
			}
			else {
				start = pos
			}

			indq = !indq
		}

		last = str[pos]
		pos += 1
	}

	return str
}

//
// ReplaceInvariants
//
// Reverses the effect of RemoveInvariants, replacing the inserted tokens with
//   the original text.
//
function ReplaceInvariants(str, invariants)
{
	for(var i=0; i<invariants.length; i+=1) {
		str = str.replace("~#"+i+"#~", invariants[i])
	}

	return str
}


//
// ProcessScript
//
// The overall script processing function. Calls a variety of transformation
//   functions on the given input string (assumed to be a script).
//
// Returns the transformed script.
// 
function ProcessScript(str)
{
	var defines = {}
	var invariants = []

	str = ProcessLineNumbers(str)
	// console.log("ProcessLineNumbers")
	// console.log(str)

	str = ProcessDefines(str, defines)
	// console.log("ProcessDefines")
	// console.log(str)

	str = RemoveInvariants(str, invariants)
	// console.log("RemoveInvariants")
	// console.log(str)

	str = ExpandDefines(str, defines, invariants)
	// console.log("ExpandDefines")
	// console.log(str)

	str = ProcessLinePPNumbers(str)
	// console.log("ProcessLinePPNumbers")
	// console.log(str)

	str = ReplaceInvariants(str, invariants)
	// console.log("ReplaceInvariants")
	// console.log(str)

	return str
}


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////


//
// InsertScript
//
// Appends the given string as a script in the HTML document's header.
// 
function InsertScript(str) {
	var e = document.createElement("script")
	e.type = "text/javascript"
	e.innerHTML = str
	var head = document.getElementsByTagName("head")[0]
	head.appendChild(e)
}

//
// GetScripts
//
// Scan the script objects in the HTML document, looking for scripts to
//   process. Scripts of type 'text/jspp' are loaded and pre-processed.
//
function GetScripts()
{
	var a = document.getElementsByTagName("script")

	for(var s = 0; s < a.length; s++) {
		if(a[s].type === 'text/jspp') {
			var req = new XMLHttpRequest()
			req.open('GET', a[s].src, false)
			req.send(null)
			if(req.status === 200) {
				InsertScript(ProcessScript(req.responseText))
				// ProcessScript(req.responseText)
			}
		}
	}
}

// Automatically load jspp scripts when this script is loaded
GetScripts()

}());
