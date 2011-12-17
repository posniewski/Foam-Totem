
#macro QW(str) return '["'+str.trim().split(/\s+/).join('", "')+'"]'
__LINE__
#define BOK foo
#define FOO2(amazing) """

THis is a #amazing __LINE_PP__
#amazingWow
#amazing##Wow

"""

var d
var a = QW("a b c")
FOO2(what ## the?)
"/* FOO2(porquoi?) */"
end

