extends Control

@onready var final_score_label: Label = $VBox/FinalScoreLabel
@onready var high_score_label: Label = $VBox/HighScoreLabel
@onready var restart_button: Button = $VBox/RestartButton
@onready var main_menu_button: Button = $VBox/MainMenuButton
@onready var close_button: Button = $VBox/CloseButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Display final and high score
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		final_score_label.text = "Your Score: %d" % global.score
		high_score_label.text = "High Score: %d" % global.high_score

func _on_restart_pressed() -> void:
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		global.reset_score()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_main_menu_pressed() -> void:
	if "Global" in ProjectSettings.global_singletons:
		var global = get_node("/root/Global")
		global.reset_score()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed() -> void:
	get_tree().quit()