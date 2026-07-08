# EndingSelector - Final ending determination at tribulation
extends RefCounted

func determine_ending() -> Dictionary:
	var route = RouteTracker.get_dominant_route()
	var route_name = RouteTracker.get_route_name(route)
	
	var endings = {
		"orthodox": {
			"title": "位列仙班",
			"text": "天庭的炼丹司多了一张新面孔。你依然在炼丹，只是委托人从山镇居民换成了各路神仙。祥云之下，你偶尔会想起山镇丹房里的那盏孤灯。哪一个你更自由？",
			"route": "仙道正统"
		},
		"cthulhu": {
			"title": "丹方永存",
			"text": "你化为虚空的一部分，但在此之前，你用最后一炉清醒丹换来了真相的传递。你留下的丹方上，字迹正在被不可名状的力量扭曲——但人类会记住。",
			"route": "禁忌窥视"
		},
		"meta": {
			"title": "编译新世界",
			"text": "终端屏幕上闪烁着绿色字符：「是否编译新的世界？[Y/N]」你的手指停在键盘上方。你知道了自己是什么——但那不等于你的选择没有意义。",
			"route": "次元觉醒"
		},
		"hybrid_cthulhu_heaven": {
			"title": "金色触手",
			"text": "你在天庭的金瓦红墙间看见触手从砖缝中伸出。众仙依然在微笑、行礼、炼丹。没有人注意到——或者没有人愿意注意到。只有你看见了。",
			"route": "克苏鲁天庭"
		},
		"hybrid_awakened_cthulhu": {
			"title": "互相吞噬",
			"text": "你发现了一个不可能的事实：旧日支配者在同化你的同时，你也在感染祂。两种意识在虚空中互相吞噬，而你的丹炉依然在燃烧。",
			"route": "觉醒旧日"
		}
	}
	
	var key = "orthodox"
	match route:
		0: key = "orthodox"
		1: key = "cthulhu"
		2: key = "meta"
		3: key = "hybrid_cthulhu_heaven"
		4: key = "hybrid_awakened_cthulhu"
	
	return _make_ending(key, endings[key]["route"], endings[key]["text"])

func _make_ending(id: String, route: String, text: String) -> Dictionary:
	return {"id": id, "route": route, "text": text}
