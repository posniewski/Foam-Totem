define([
'underscore','song','jquery'
],function(_,Song,$){

 	var queue = {};

	window.m3uLoad = function() {
		_.each(queue, function(callback, url) {
			$.post(url, 'action=ShuffleAll', function(data) {
				var list = [];
				var lines = data.split('\n');
				var name = '';
				var re = new RegExp('^(#)(EXTM3U|EXTINF)([^,]*,)?(.*)');
				for(var i = 0; i < lines.length; i++)
				{

					var res = re.exec(lines[i]);
					console.log(lines[i], res);
					if(!res && name)
					{
						list.push(new Song({ title: name, url: lines[i] }));
						name = '';
					}
					else if(res && res[2] == 'EXTINF')
					{
						name = res[4];
					}
				}
				console.log(list)
				callback(list);
			});
		});
	};

	return {
		load:function(url, req, callback, config){
			queue[url] = callback;
			m3uLoad();
		}
	};
});

// define([
// 'underscore','song',
// 'https://www.google.com/jsapi'
// ],function(_,Song){
// 	//uses google feed api
//
// 	var queue = {}, isLoaded = false;
//
// 	window.googleFeedLoad = function(){
// 		isLoaded = true;
// 		_.each(queue,function(callback,url){
// 			var feed = new google.feeds.Feed(url);
// 			feed.setNumEntries(100);
// 			feed.load(function(result){
// 				callback(_.map(result.feed.entries,function(entry){
// 					var res = /(.*)(\?stream)/.exec(entry.link);
// 					if(res)
// 						entry.link = res[1];
// 					var url = entry.link;
// 					if(entry.mediaGroups && entry.mediaGroups[0].contents[0].url)
// 						url = entry.mediaGroups[0].contents[0].url;
// 					return new Song({
// 						title:entry.title,
// 						url:url
// 					});
// 				}));
// 			});
// 		});
// 		queue = {};
// 	}
// 	google.load("feeds", "1",{callback:'googleFeedLoad'});
//
// 	return {
// 		load:function(url, req, callback, config){
// 			queue[url] = callback;
// 			if(isLoaded) googleFeedLoad();
// 		}
// 	};
// });
