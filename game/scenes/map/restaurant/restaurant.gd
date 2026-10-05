extends Node3D

@onready var game_ui: GameUI = %"GAME UI"
@onready var player: GEntity = $PLAYER

func player_death() -> void:
	SceneMaster.swap_to_scene = "end_game"

func _ready() -> void:
	await player.b_inited
	player.add_player_controls()
	player.min_health_reached.connect(player_death, ConnectFlags.CONNECT_ONE_SHOT)
	if Progression.is_flag_set("restaurant.first_look"):
		game_ui.dialog_view.display([
			tr("DIALOG.RESTAURANT.FIRST_LOOK"),
		])
var tick: int = 0
func _process(_delta: float) -> void:
	tick += 1
	if tick > 1000:
		tick = 0
	if tick % 20 == 0:
		game_ui.score_view.display(ScoreMaster.get_total_points())
