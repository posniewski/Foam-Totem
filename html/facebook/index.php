<?php

	$app_id = "202981499713630";
	$app_secret = "7c4028223161aedc2325605745a01313";
	$my_url = "http://foamtotem.org/facebook/index.php";

	$code = $_REQUEST["code"];

function qw($str) {
	return (preg_split("/[\b|\s]+/",$str));
}

$all_permissions = qw('
	public_profile
	user_friends
	email
	user_about_me

	user_actions.books
	user_actions.fitness
	user_actions.music
	user_actions.news
	user_actions.video
	user_actions:runmeter
	user_actions:runtastic

	user_birthday
	user_education_history
	user_events
	user_games_activity
	user_groups
	user_hometown
	user_likes
	user_location
	user_managed_groups
	user_photos
	user_posts
	user_relationships
	user_relationship_details
	user_religion_politics
	user_status
	user_tagged_places
	user_videos
	user_website
	user_work_history

	read_custom_friendlists
	read_insights
	read_mailbox
	read_page_mailboxes
	read_stream
	manage_notifications
	manage_pages
	publish_pages
	publish_actions
	rsvp_event
');

	if(empty($code)) {
		$dialog_url = "http://www.facebook.com/dialog/oauth?client_id="
			. $app_id . "&redirect_uri=" . urlencode($my_url)
			. "&scope=".implode(",", $all_permissions);

		echo("<script> top.location.href='" . $dialog_url . "'</script>");
	}

	$token_url = "https://graph.facebook.com/oauth/access_token?client_id="
		. $app_id . "&redirect_uri=" . urlencode($my_url) . "&client_secret="
		. $app_secret . "&code=" . $code;

	$access_token = file_get_contents($token_url);

	$graph_url = "https://graph.facebook.com/me?" . $access_token;

	$user = json_decode(file_get_contents($graph_url));

	echo("Hello " . $user->name);
	echo("<br>Hello " . $access_token );

?>
