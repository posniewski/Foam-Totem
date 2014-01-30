<?php

	$app_id = "202981499713630";
	$app_secret = "7c4028223161aedc2325605745a01313";
	$my_url = "http://foamtotem.org/facebook/index.php";

	$code = $_REQUEST["code"];

function qw($str) {
	return (preg_split("/[\b|\s]+/",$str));
}

$all_permissions = qw('
	user_about_me              friends_about_me
	user_activities            friends_activities
	user_birthday              friends_birthday
	user_education_history     friends_education_history
	user_events                friends_events
	user_groups                friends_groups
	user_hometown              friends_hometown
	user_interests             friends_interests
	user_likes                 friends_likes
	user_location              friends_location
	user_notes                 friends_notes
	user_online_presence       friends_online_presence
	user_photo_video_tags      friends_photo_video_tags
	user_photos                friends_photos
	user_questions             friends_questions
	user_relationships         friends_relationships
	user_relationship_details  friends_relationship_details
	user_religion_politics     friends_religion_politics
	user_status                friends_status
	user_subscriptions         friends_subscriptions
	user_videos                friends_videos
	user_website               friends_website
	user_work_history          friends_work_history
	email
	read_friendlists           manage_friendlists
	read_insights
	read_mailbox
	read_requests
	read_stream
	xmpp_login
	ads_management
	user_checkins              friends_checkins

	publish_stream
	create_event
	rsvp_event
	sms
	offline_access
	publish_checkins
	publish_actions
	user_actions.music
	user_actions.news
	user_actions.video
	user_actions:runmeter
	user_actions.fitness
	user_actions.runs
	user_games_activity

	manage_pages
	manage_notifications
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
