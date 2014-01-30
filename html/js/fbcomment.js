
var FB;
var fb_inited = false;
var logged_in = false;
var fb_name = '';
var fb_name_info = '';

var reply_html =
	'<div class="replychoice"><table><tr>'
	+ '<td class="replies"><a href="#" onClick="loginFacebookAndReply(this); return false;">Reply with Facebook</a><br>'
	+ 'Your comments will appear here and on Facebook.</td>'
	+ '<td class="replies"><a href="#" onClick="reply_expand_foam(this); return false;">Reply with Foam Totem</a><br>'
	+ 'Your comments will only appear here.</td>'
	+ '</tr></table>'
	+ '</div>';

window.fbAsyncInit = function() {
	FB.init({appId: '219939589007', status: true, cookie: true, xfbml: true});
	fb_inited = true;

	/* All the events registered */
	FB.Event.subscribe('auth.login', function(response) {
		// do something with response
		loginCB();
	});
	FB.Event.subscribe('auth.logout', function(response) {
		// do something with response
		logoutCB();
		a = 9;
	});

	checkFacebook();
}

function checkFacebook() {
	FB.getLoginStatus(function(response) {
		if (response.status === 'connected') {
			// logged in and connected user, someone you know
			loginCB(response);
		}
		else {
			logoutCB();
		}
	});
}

function loginFacebook() {
	FB.login(function(response) {
		if (response.status === 'connected') {
			// user successfully logged in
		} else {
			// user cancelled login
		}
	});
}

function loginFacebookAndReply(elem) {
	FB.login(function(response) {
		if (response.status === 'connected') {
			reply_expand_fb(elem);
		} else {
			// user cancelled login
		}
	});
}

function logoutFacebook() {
	FB.logout(function(response) {
		// user is now logged out
	});
}

function cacheLoginInfo() {
	if(!fb_name)
	{
		FB.api('/me', function(response) {
			fb_name = response.name;
			fb_name_info = " as " + fb_name + " (Facebook)";
			$(".fb_name").empty().prepend(fb_name_info);
		});
	}
	else
	{
		$(".fb_name").empty().prepend(fb_name_info);
	}
}

function loginCB(response) {

	cacheLoginInfo();

	$(".fb_comment").show();
	$(".foam_comment").hide();
	$(".replychoice").hide();

	logged_in = true;
}

function logoutCB() {
	$(".fb_comment").hide();
	$(".foam_comment").show();
	$(".replychoice").show();

	$(".fb_name").empty();

	logged_in = false;
	fb_name = '';
}

function postComment(fbid,fid) {
	var new_comment = document.getElementById('new_comment_'+fid).value;

	if(new_comment)
	{
		FB.api('/' + fbid + '/comments/',
			'post',
			{ message: new_comment },
			function(response) {
				if (!response || response.error) {
					alert('Error occured' + response.error.message + '\n' + fbid + ':' + new_comment);
				} else {
					$.get("/perl/comment_sync.pl", { 'fid': fid },
						function(data, textStatus) {
							cexpand(document.getElementById('new_comment_'+fid));
						}
					);
				}
			}
		);
	}
}

$(document).ready(function() {

	$('article:has(footer.comments)').each( function(i, elem) {
		if(i<5) {
			var foam = jQuery.parseJSON($(elem).attr("foam"));

			$.get("/perl/comment_fetch.pl", { fid: foam.fid, count: 6 },
				function(data, textStatus) {
					$('#'+elem.id+' > footer').prepend(
						'<div class="full_comments">'
						+ data
						+ '<div id="form_' + foam.fid + '">'
						+ '<a href="#" onClick="reply_expand(this); return false;">Reply</a>'
						+ '</div>'
						+ '</div>');

					$('#'+elem.id+' .permalink').hide();
				}
			);
		}
		else {
			$('#'+elem.id+' .permalink').click(function() {
				cexpand(this);
				return false;
			});
		}
	});


	$('article:has(footer.full_comments)').each( function(i, elem) {
		var foam = jQuery.parseJSON($(elem).attr("foam"));

		$.get("/perl/comment_fetch.pl", { fid: foam.fid },
			function(data, textStatus) {

				$('#'+elem.id+' > footer').prepend(
					'<div class="full_comments">'
					+ data
					+ '<div id="form_' + foam.fid + '">'
					+ '<a href="#" onClick="reply_expand(this); return false;">Reply</a>'
					+ '</div>'
					+ '</div>');

				$('#'+elem.id+' .permalink').hide();
			}
		);

	});

});


function cexpand(me) {
	var article = $(me).parents('article').first();
	var foam = jQuery.parseJSON($(article).attr('foam'));

	var footer = $('#' + $(article).attr('id') + ' > footer');

	$.get('/perl/comment_fetch.pl', { fid: foam.fid },
		function(data, textStatus) {
			$(footer).children('.full_comments').remove();
			$(footer).prepend(
				'<div class="full_comments">'
				+ data
				+ '<div id="form_' + foam.fid + '">'
				+ '<a href="#" onClick="reply_expand(this); return false;">Reply</a>'
				+ '</div>'
				+ '</div>');

			$(footer).children('.permalink').hide();
		}
	);

	return false;
}

function reply_expand(me) {
	var article = $(me).parents('article').first();
	var foam = jQuery.parseJSON($(article).attr('foam'));

	if(typeof foam.fbid === "undefined")
	{
		reply_expand_foam(me);
	}
	else if(fb_inited && logged_in)
	{
		reply_expand_fb(me);
	}
	else
	{
		var article = $(me).parents('article').first();
		var foam = jQuery.parseJSON($(article).attr('foam'));
		var choice = '<div id="form_' + foam.fid + '">' + reply_html + '</div>';

		$('#form_'+foam.fid).replaceWith(choice);
	}

	return false;
}

function reply_expand_fb(me) {
	var article = $(me).parents('article').first();
	var foam = jQuery.parseJSON($(article).attr('foam'));

	$('#form_'+foam.fid).replaceWith(makeFBCommentBlock(foam));

	return false;
}


function reply_expand_foam(me) {
	var article = $(me).parents('article').first();
	var foam = jQuery.parseJSON($(article).attr('foam'));

	$('#form_'+foam.fid).replaceWith(makeFoamCommentBlock(foam));

	var options = {
		type:          'get',
		url:           'http://foamtotem.org/perl/comment_add.pl',
		success:       showResponse
	};

	// bind form using 'ajaxForm'
	$('#foam_comment_'+foam.fid).ajaxForm(options);

	Recaptcha.create(
		'6LcoAL0SAAAAAGAoDP7b5-pI213rg-NxiANRYO9B',
		'captcha_'+foam.fid,
		{ theme: 'white' });

	return false;
}

// post-submit callback
function showResponse(responseText, statusText, xhr, form)  {
	cexpand(form);
}

function makeFBCommentBlock(foam) {

	var comment =
		'<div id="form_' + foam.fid + '">'
		+ '<div class="fb_comment">'
		+ '<textarea id="new_comment_'
		+ foam.fid + '" '
		+ 'class="new_comment" cols="63" placeholder="Write a comment..."></textarea><br>'
		+ '<button type="button" onClick="postComment(\''
		+ foam.fbid + '\',\''
		+ foam.fid + '\''
		+ ');">Post Comment</button>'
		+ '<div class="fb_name">'
		+ fb_name_info
		+'</div> '
		+ '<div class="fb_logout"><a href="#" onClick="logoutFacebook(); return false;">[Log out]</a></div>'
		+ '</div>'
		+ '<a href="#" onClick="reply_expand(this); return false;" class="replychoice" style="display: none;">Reply</a>'
		+ '</div>';

	return comment;
}

function makeFoamCommentBlock(foam) {
	var comment =
		'<div id="form_' + foam.fid + '">'
		+ '<div class="foam_comment">'
		+ '<form id="foam_comment_' + foam.fid + '" '
		+ 'action="http://foamtotem.org/perl/comment_add.pl" method="get">'
		+ '<textarea '
			+ 'id="new_comment_' + foam.fid + '" '
			+ 'name="message" '
			+ 'class="new_comment" cols="63" placeholder="Write a comment..."></textarea><br>'
		+ '<textarea '
		+ 'id="new_name_' + foam.fid + '" '
			+ 'name="name" '
			+ 'class="new_name" cols="63" rows="1" placeholder="Your name...">'+fb_name+'</textarea><br>'
		+ '<div class="captcha" '
			+ 'id="captcha_' + foam.fid + '"></div>'
		+ '<input type="hidden" name="fid" value="' + foam.fid +'">'
		+ '<input type="submit" value="Post Comment">'
		+ '</form>'
		+ '</div>';

	if(typeof foam.fbid === "undefined") {
		comment += '(This post isn\'t on Facebook, so your comment will only appear here.)';
	}
	else {
		comment += '<a href="#" onClick="loginFacebook(); reply_expand_fb(this); return false;">Reply with Facebook instead</a>';
	}

	comment += '</div>';

	return comment;
}

