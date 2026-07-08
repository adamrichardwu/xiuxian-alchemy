# AlchemyUI - Main alchemy screen controller
extends Control

# Node references (set in _ready)
var herb_list_container: VBoxContainer
var selected_herbs_container: VBoxContainer
var recipe_list_container: VBoxContainer
var recipe_info_label: RichTextLabel
var fire_slider: HSlider
var fire_accuracy_label: Label
var brew_button: Button
var result_overlay: ColorRect
var result_label: RichTextLabel
var realm_label: Label
var insight_bar: ProgressBar
var commission_label: RichTextLabel

# State
var selected_recipe_id: String = ""
var selected_herbs: Array[String] = []
const MAX_HERBS = 4
var alchemy_engine = preload("res://scripts/systems/alchemy/alchemy_engine.gd").new()

func _ready():
	_setup_ui()
	_refresh_herbs()
	_refresh_recipes()
	_update_realm_display()
	_update_commission_display()
	
	EventBus.brew_completed.connect(_on_brew_completed)
	EventBus.realm_changed.connect(_on_realm_changed)
	EventBus.dao_insight_changed.connect(_on_insight_changed)
	EventBus.commission_accepted.connect(_on_commission_accepted)
	EventBus.commission_completed.connect(_on_commission_completed)
	EventBus.herb_added.connect(_on_herb_changed)

func _setup_ui():
	# Build UI programmatically
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	margin.add_child(main_vbox)
	
	# Top bar: realm + insight
	var top_bar = HBoxContainer.new()
	main_vbox.add_child(top_bar)
	
	realm_label = Label.new()
	realm_label.text = "练气期"
	realm_label.add_theme_font_size_override("font_size", 24)
	top_bar.add_child(realm_label)
	
	insight_bar = ProgressBar.new()
	insight_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	insight_bar.max_value = 1.0
	insight_bar.value = 0.0
	top_bar.add_child(insight_bar)
	
	# Commission info
	commission_label = RichTextLabel.new()
	commission_label.bbcode_enabled = true
	commission_label.fit_content = true
	commission_label.text = "[i]暂无委托[/i]"
	main_vbox.add_child(commission_label)
	
	# Main content: herbs | furnace | recipes
	var content_hbox = HBoxContainer.new()
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content_hbox)
	
	# Left: Herb selection
	var herb_panel = _make_panel("药材")
	content_hbox.add_child(herb_panel)
	
	var herb_scroll = ScrollContainer.new()
	herb_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	herb_scroll.custom_minimum_size = Vector2(200, 0)
	herb_panel.add_child(herb_scroll)
	
	herb_list_container = VBoxContainer.new()
	herb_scroll.add_child(herb_list_container)
	
	# Center: Furnace + selected herbs
	var center_vbox = VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(center_vbox)
	
	var furnace_view = _make_panel("丹炉")
	furnace_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_child(furnace_view)
	
	var furnace_label = Label.new()
	furnace_label.text = "🔮"
	furnace_label.add_theme_font_size_override("font_size", 64)
	furnace_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	furnace_view.add_child(furnace_label)
	
	var selected_panel = _make_panel("已选药材")
	center_vbox.add_child(selected_panel)
	
	selected_herbs_container = VBoxContainer.new()
	selected_panel.add_child(selected_herbs_container)
	
	# Right: Recipe info
	var recipe_panel = _make_panel("丹方")
	content_hbox.add_child(recipe_panel)
	
	var recipe_vbox = VBoxContainer.new()
	recipe_panel.add_child(recipe_vbox)
	
	recipe_list_container = VBoxContainer.new()
	recipe_vbox.add_child(recipe_list_container)
	
	recipe_info_label = RichTextLabel.new()
	recipe_info_label.bbcode_enabled = true
	recipe_info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	recipe_info_label.custom_minimum_size = Vector2(220, 0)
	recipe_vbox.add_child(recipe_info_label)
	
	# Bottom: Fire control + Brew
	var bottom_bar = HBoxContainer.new()
	main_vbox.add_child(bottom_bar)
	
	var fire_label = Label.new()
	fire_label.text = "火候:"
	bottom_bar.add_child(fire_label)
	
	fire_slider = HSlider.new()
	fire_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fire_slider.min_value = 0.0
	fire_slider.max_value = 1.0
	fire_slider.step = 0.01
	fire_slider.value = 0.7
	fire_slider.value_changed.connect(_on_fire_changed)
	bottom_bar.add_child(fire_slider)
	
	fire_accuracy_label = Label.new()
	fire_accuracy_label.text = "70%"
	bottom_bar.add_child(fire_accuracy_label)
	
	brew_button = Button.new()
	brew_button.text = "开炉炼丹"
	brew_button.pressed.connect(_on_brew_pressed)
	bottom_bar.add_child(brew_button)
	
	# Result overlay (hidden by default)
	result_overlay = ColorRect.new()
	result_overlay.color = Color(0, 0, 0, 0.8)
	result_overlay.visible = false
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(result_overlay)
	
	result_label = RichTextLabel.new()
	result_label.bbcode_enabled = true
	result_label.add_theme_font_size_override("font_size", 18)
	result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_overlay.add_child(result_label)

func _make_panel(title: String) -> Panel:
	var panel = Panel.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title_label)
	return panel

func _refresh_herbs():
	for child in herb_list_container.get_children():
		child.queue_free()
	
	var herbs = DataManager.get_herbs_for_realm(GameState.realm)
	for herb in herbs:
		var hbox = HBoxContainer.new()
		herb_list_container.add_child(hbox)
		
		var name_label = Label.new()
		name_label.text = herb.get("name_cn", "???")
		name_label.custom_minimum_size = Vector2(80, 0)
		hbox.add_child(name_label)
		
		var count_label = Label.new()
		var herb_id = herb.get("id", "")
		var count = GameState.herb_inventory.get(herb_id, 0)
		count_label.text = "x%d" % count
		hbox.add_child(count_label)
		
		var add_btn = Button.new()
		add_btn.text = "+"
		add_btn.pressed.connect(_add_herb.bind(herb_id))
		hbox.add_child(add_btn)

func _refresh_recipes():
	for child in recipe_list_container.get_children():
		child.queue_free()
	
	var recipes = DataManager.get_recipes_for_realm(GameState.realm)
	for recipe in recipes:
		var btn = Button.new()
		btn.text = recipe.get("name_cn", "???")
		btn.pressed.connect(_select_recipe.bind(recipe.get("id", "")))
		recipe_list_container.add_child(btn)

func _select_recipe(recipe_id: String):
	selected_recipe_id = recipe_id
	var recipe = DataManager.get_recipe(recipe_id)
	if recipe.is_empty():
		recipe_info_label.text = ""
		return
	
	var text = "[b]%s[/b] [%d品]\n\n" % [recipe.get("name_cn", ""), recipe.get("tier", 1)]
	text += recipe.get("description", "") + "\n\n"
	text += "[color=yellow]火候:[/color] " + recipe.get("fire_description", "") + "\n"
	
	if recipe.get("incomplete", false):
		text += "\n[color=red][b]⚠ 丹方残缺 ⚠[/b][/color]\n"
	if recipe.get("forbidden", false):
		text += "\n[color=purple][b]☠ 禁术丹方 ☠[/b][/color]\n"
	
	var hidden = recipe.get("hidden_tip", "")
	if hidden != "" and GameState.realm >= 2:
		text += "\n[color=gray][i]" + hidden + "[/i][/color]\n"
	
	recipe_info_label.text = text

func _add_herb(herb_id: String):
	if selected_herbs.size() >= MAX_HERBS:
		return
	if GameState.herb_inventory.get(herb_id, 0) <= 0:
		return
	
	selected_herbs.append(herb_id)
	GameState.remove_herb(herb_id)
	_refresh_selected_herbs()
	_refresh_herbs()

func _refresh_selected_herbs():
	for child in selected_herbs_container.get_children():
		child.queue_free()
	
	for herb_id in selected_herbs:
		var hbox = HBoxContainer.new()
		selected_herbs_container.add_child(hbox)
		
		var herb = DataManager.get_herb(herb_id)
		var label = Label.new()
		label.text = herb.get("name_cn", herb_id)
		hbox.add_child(label)
		
		var remove_btn = Button.new()
		remove_btn.text = "X"
		remove_btn.pressed.connect(_remove_herb.bind(herb_id))
		hbox.add_child(remove_btn)

func _remove_herb(herb_id: String):
	var idx = selected_herbs.find(herb_id)
	if idx >= 0:
		selected_herbs.remove_at(idx)
		GameState.add_herb(herb_id)
		_refresh_selected_herbs()
		_refresh_herbs()

func _on_fire_changed(value: float):
	fire_accuracy_label.text = "%d%%" % int(value * 100)

func _on_brew_pressed():
	if selected_herbs.is_empty():
		_show_result("请先选择药材")
		return
	if selected_recipe_id.is_empty():
		_show_result("请先选择丹方")
		return
	
	EventBus.brew_started.emit(selected_recipe_id)
	
	var result = alchemy_engine.brew(selected_herbs.duplicate(), selected_recipe_id, fire_slider.value)
	
	# Clear selection
	selected_herbs.clear()
	_refresh_selected_herbs()
	_refresh_herbs()
	
	_display_result(result)

func _display_result(result: Dictionary):
	var text = "[center]"
	
	if result.get("success", false):
		text += "[b][font_size=28]%s[/font_size][/b]\n\n" % result.get("quality_label", "")
		text += "品级: %d 品\n" % result.get("tier", 0)
		text += "灵力: %.0f\n" % result.get("spirit_power", 0.0)
		text += "杂质: %.0f%%\n" % (result.get("impurity_ratio", 0.0) * 100)
		
		var side = result.get("side_effects", [])
		if side.size() > 0:
			text += "\n[color=orange]副作用: %s[/color]\n" % ", ".join(side)
		
		if result.get("is_flawless", false):
			text += "\n[color=gold]✨ 无瑕之作 ✨[/color]\n"
		if result.get("tribulation_triggered", false):
			text += "\n[color=red]⚡ 丹劫降临 ⚡[/color]\n"
		if result.get("variant_id", "") != "":
			text += "\n[color=purple]🜚 异变化丹 🜚[/color]\n"
	else:
		text += "[color=red][b]炼丹失败[/b][/color]\n"
		text += result.get("fail_reason", "")
	
	text += "\n\n[font_size=14]点击任意处继续[/font_size][/center]"
	_show_result(text)
	
	# Check commission completion
	if GameState.active_commission_id != "":
		_check_commission_delivery(result)

func _check_commission_delivery(result: Dictionary):
	var comm = DataManager.get_commission(GameState.active_commission_id)
	if comm.is_empty():
		return
	
	var required_pill = comm.get("required_pill", "")
	if required_pill == "none":
		return
	
	if result.get("recipe_id", "") != required_pill:
		return
	
	var outcome = "fail"
	if result.get("success", false):
		if result.get("tier", 0) >= 5:
			outcome = "success"
		else:
			outcome = "partial"
	
	var comm_result = CommissionBoard.complete_commission(outcome)
	_update_commission_display()

func _show_result(text: String):
	result_label.text = text
	result_overlay.visible = true

func _on_brew_completed(_result: Dictionary):
	_update_realm_display()
	_refresh_herbs()

func _on_realm_changed(_new_realm: int, _name: String):
	_update_realm_display()
	_refresh_herbs()
	_refresh_recipes()

func _on_insight_changed(_value: float):
	_update_realm_display()

func _on_commission_accepted(_id: String):
	_update_commission_display()

func _on_commission_completed(_id: String, _outcome: String):
	_update_commission_display()
	_refresh_herbs()

func _on_herb_changed(_herb_id: String, _amount: int):
	_refresh_herbs()

func _update_realm_display():
	realm_label.text = RealmManager.get_realm_name()
	insight_bar.value = GameState.dao_insight

func _update_commission_display():
	if GameState.active_commission_id.is_empty():
		commission_label.text = "[i]暂无委托 — 等待委托人上门[/i]"
		return
	
	var comm = DataManager.get_commission(GameState.active_commission_id)
	if comm.is_empty():
		return
	
	var client = DataManager.get_character(comm.get("client_id", ""))
	var client_name = client.get("name_cn", "???")
	commission_label.text = "[b]当前委托:[/b] %s — %s" % [comm.get("title", ""), client_name]

func _input(event):
	if event is InputEventMouseButton and event.pressed and result_overlay.visible:
		result_overlay.visible = false
