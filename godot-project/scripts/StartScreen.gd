extends Control

@onready var start_button: Button = $VBox/StartButton
@onready var close_button: Button = $VBox/CloseButton
@onready var player_name_input: LineEdit = $VBox/PlayerNameContainer/PlayerNameInput
@onready var high_score_label: Label = $VBox/HighScoreLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	close_button.pressed.connect(_on_close_pressed)

	# Initialize high score display to 0 immediately
	high_score_label.text = "High Score: 0"
	high_score_label.visible = true
	
	# Listen for global high score updates
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		global.connect("high_score_updated", Callable(self, "_on_high_score_updated"))
		global.connect("applaa_game_data_loaded", Callable(self, "_on_applaa_game_data_loaded"))

	# Request load from localStorage
	if OS.has_feature("HTML5"):
		JavaScriptBridge.eval("window.parent.postMessage({ type: 'applaa-game-load-data', gameId: 'tapordie_a1b2c3d4' }, '*');")

func _on_high_score_updated(new_high_score: int) -> void:
	high_score_label.text = "High Score: %d" % new_high_score

func _on_applaa_game_data_loaded(json_data: String) -> void:
	# Data already handled by Global, update UI accordingly
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		if global.high_score > 0:
			high_score_label.text = "High Score: %d" % global.high_score
		if global.last_player_name != "":
			player_name_input.text = global.last_player_name

func _on_start_pressed() -> void:
	var player_name = player_name_input.text.strip()
	if player_name == "":
		player_name = "Player"
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		global.last_player_name = player_name
		global.reset_score()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed() -> void:
	get_tree().quit()