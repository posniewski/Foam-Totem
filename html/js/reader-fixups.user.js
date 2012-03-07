// ==UserScript==
// @name           Google Reader Optimized
// @namespace      http://foamtotem.org
// @description    Reduces margins on the new Google Reader layout
// @include        http://www.google.com/reader/view/*
// @include        https://www.google.com/reader/view/*
// @include        http://www.google.*/reader/view/*
// @include        https://www.google.*/reader/view/*
// @version        1.0
// ==/UserScript==

var overrideCSS =

    /*This adds a border between the items and the sidebar*/

	"#chrome-viewer-container {" +
    "  border-left-width: 1px !important;" +
    "  border-left-style: solid !important;" +
    "  border-left-color: #CCC !important;" +
    "}" +

	/*Adds some breathing room around images*/

	".item-body img {" +
    "  padding-top: 10px;" +
    "  padding-right: 10px;" +
    "  padding-bottom: 10px;" +
    "}" +

	/* change colour of subscribe button */

	".jfk-button-primary {" +
    "  background: #f2f2f2 url(none) !important;" +
    "  border: 1px solid #DCDCDC !important;" +
    "  color: black !important;" +
    "}" +
    
	/*add blue bg to current topic at top of page */
    
	"#title-and-status-holder {" +
    "  background: #D5DFF6 !important;" +
    "  padding-left: 13px !important;" +
    "  height: 1%;" +
    "  overflow: hidden;" +
    "  margin-right: 0px !important;" +
    "  padding-top: 5px !important;" +
    "  padding-bottom: 5px !important;" +
    "  padding-right: 5px !important;" +
    "}" +
    
	/*add light blue bg to viewer header */
    
	"#chrome-viewer-container { background: #EBEFF9 !important; }" +
    "#viewer-top-controls-container {}" +
    "" +
    "#viewer-header {" +
    "   zoom: 1;" +
    "   background: #EBEFF9 !important;" +
    "   color: #333;" +
    "   height: 41px !important;" +
    "   margin-right: 33px;" +
    "   overflow: hidden;" +
    "   position: relative;" +
    "   padding-left: 10px !important;" +
    "}" +
    
	/* make left border of currently selected folder green */
    
	".tree-link-selected {" +
    "  border-left: 5px solid hsl(117, 71%, 35%) !important;" +
   	"  background-color: hsl(117, 31%, 85%); }" +
    "#lhn-selectors .selector.selected {" +
    "  border-left: 5px solid hsl(117, 71%, 35%) !important;" +
    "  background-color: hsl(117, 31%, 85%)}" +
	"#lhn-selectors .selected a span, #lhn-selectors .selected a:hover span {" +
	"  color: black !important;" +
	"}"+
	".selector:hover, #lhn-selectors .selector:hover, .scroll-tree li a:hover {" +
	"  background-color: hsl(117, 31%, 75%);"+
	"}"+
    
	/* less padding around collpased entries & changed read colour to blue */
    
	"div.collapsed { line-height: 1.3em !important; }" +
    "div.entry-secondary { height: 15px !important; }" +
    "#entries.list .read .collapsed {" +
    "  background: #EBEFF9 !important;" +
    "}" +
    
	/* makes the entry actions area grey */
    
	"xx.entry-actions { background-color: #F6F6F6 !important; }" +
    
	/* removes red from 'explore' */
    
	".name { color: #000 !important; }" +

	"#nav { width: 210px; }" +
	"#lhn-add-subscription-section { width: 210px; }" +
	"#chrome {margin-left: 210px;}" +

	".card .card-bottom { margin-left: -14px; padding-left: 14px; }"+
	".card-common .card-actions { background-color: #f0f0ff; border-style: solid none none none; }"+
	".cards .entry { padding: 0px 0px; }"+
	"#top-bar { height: 50px; }"+
	"#search { padding: 10px 0px; }"+
	".card { border-color: white white #CCC white; }"+

	".entry .entry-body, .entry .entry-title, .entry .entry-likers { max-width: 850px; }" +

	/* END */ "";
	

	GM_addStyle(overrideCSS);


