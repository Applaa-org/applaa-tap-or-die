extends Node

@export var game_id: String = "tapordie_a1b2c3d4" # Unique ID for this app (8 chars suffix)

var score: int = 0
var high_score: int = 0
var last_player_name: String = ""
var scores: Array = []
var game_progress: Dictionary = {}

signal score_changed(new_score: int)
signal high_score_updated(new_high_score: int)

func _ready():
	# Initialize score to zero
	score = 0
	high_score = 0
	last_player_name = ""
	scores = []
	game_progress = {}
	
	# Connect messaging from JS for loading Applaa data
	if OS.has_feature("HTML5"):
		JavaScriptBridge.eval("""
			window.addEventListener('message', function(event) {
				if (event.data.type === 'applaa-game-data-loaded') {
					if (event.data.gameId === '%s') {
						// Call Godot exposed method with data JSON string
						JavaScriptBridge.emit_signal('applaa_game_data_loaded', JSON.stringify(event.data.data));
					}
				}
				if (event.data.type === 'applaa-game-score-saved') {
					if (event.data.gameId === '%s') {
						JavaScriptBridge.emit_signal('applaa_game_data_saved', JSON.stringify(event.data.data));
					}
				}
			});
		""" % [game_id, game_id])
		
	# Call load data immediately after a short delay
	yield(get_tree().create_timer(0.1), "timeout")
	load_data()

func load_data():
	if OS.has_feature("HTML5"):
		# Initialize high score label immediately to 0 by emitting signal
		emit_signal("high_score_updated", 0)
		JavaScriptBridge.eval("window.parent.postMessage({ type: 'applaa-game-load-data', gameId: '%s' }, '*');" % game_id)

@signal
func applaa_game_data_loaded(json_data: String) -> void:
	var data = JSON.parse(json_data)
	if data.error != OK:
		# Parsing failed
		return
	var game_data = data.result
	high_score = game_data.get("highScore", 0)
	last_player_name = game_data.get("lastPlayerName", "")
	scores = game_data.get("scores", [])
	game_progress = game_data.get("gameProgress", {})
	emit_signal("high_score_updated", high_score)

func save_score(player_name: String, value: int) -> void:
	score = value
	last_player_name = player_name
	if OS.has_feature("HTML5"):
		JavaScriptBridge.eval("""
			window.parent.postMessage({
				type: 'applaa-game-save-score',
				gameId: '%s',
				playerName: '%s',
				score: %d
			}, '*');
		""" % [game_id, player_name.escape(), value])
	
func reset_score() -> void:
	score = 0
	emit_signal("score_changed", score)

func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)
	if score > high_score:
		high_score = score
		emit_signal("high_score_updated", high_score)