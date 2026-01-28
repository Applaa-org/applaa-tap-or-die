extends Control

@onready var flash_panel: ColorRect = $FlashPanel
@onready var score_label: Label = $ScoreLabel

var correct_signal_color: Color = Color(0, 1, 0)
var incorrect_signal_color: Color = Color(1, 0, 0)
var neutral_color: Color = Color(0, 0, 0)
var flash_time: float = 1.2
var timer: Timer
var signal_correct: bool = false
var is_input_enabled: bool = false
var signals = []
var current_signal_index: int = -1

const WAIT_BEFORE_FLASH = 1.0

func _ready():
	# Prepare signal colors: green means tap, others do not
	signals = [
		Color(0, 1, 0),    # Green = correct signal
		Color(1, 0, 0),    # Red = wrong
		Color(0, 0, 1),    # Blue = wrong
		Color(1, 1, 0),    # Yellow = wrong
		Color(1, 0, 1),    # Magenta = wrong
		Color(0, 1, 1)     # Cyan = wrong
	]
	
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_flash_timeout"))
	
	# Initialize UI
	flash_panel.color = neutral_color
	score_label.text = "Score: 0"
	
	is_input_enabled = false
	
	# Setup input listen
	set_process_input(true)
	
	# Start the game after 1 second delay
	yield(get_tree().create_timer(WAIT_BEFORE_FLASH), "timeout")
	_next_flash()

func _input(event):
	if not is_input_enabled:
		return
	
	# Mobile tap or spacebar tap
	if (event is InputEventScreenTouch and event.pressed) or (event.is_action_pressed("ui_accept")):
		_on_player_tapped()

func _next_flash() -> void:
	# Choose random signal index to flash
	current_signal_index = randi() % signals.size()
	var chosen_color = signals[current_signal_index]
	flash_panel.color = chosen_color
	signal_correct = (chosen_color == correct_signal_color)
	is_input_enabled = true
	
	# Timer for current flash duration
	timer.start(flash_time)

func _on_flash_timeout() -> void:
	# Flash expired without tap, check if should count as fail if correct signal was shown
	if signal_correct:
		# Player missed correct tap → defeat
		_game_over(False)
		return
	else:
		# No tap on incorrect signal OK, continue
		_reset_flash()
		yield(get_tree().create_timer(WAIT_BEFORE_FLASH), "timeout")
		_next_flash()

func _reset_flash() -> void:
	flash_panel.color = neutral_color
	is_input_enabled = false

func _on_player_tapped() -> void:
	if signal_correct:
		# Correct tap
		if "Global" in ProjectSettings.global_singletons:
			var global = get_node("/root/Global")
			global.add_score(1)
			score_label.text = "Score: %d" % global.score
		_reset_flash()
		timer.stop()
		# Next flash in a short delay
		yield(get_tree().create_timer(0.4), "timeout")
		_next_flash()
	else:
		# Wrong tap → defeat
		_game_over(False)

func _game_over(victory: bool) -> void:
	is_input_enabled = false
	_reset_flash()
	# Save score with player name
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		global.save_score(global.last_player_name, global.score)
	get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")