class_name GWindow extends GameObject

@onready var moveable_part: Node3D = %DOWN
@onready var cooldown_timer: Timer = $CD
@onready var score_timer: Timer = $"SCORE CD"
@onready var pos_open_mark: Vector3 = %"POS OPEN".position
@onready var pos_closed_mark: Vector3 = %"POS CLOSED".position

@export var open: bool = false
var animation_weight: float = 0.8 # Radianss

var interact: B3DInteractable = null

func interact_event(event: String, ..._args) -> void:
	match event:
		"toggle" when open:
			open = false
			cooldown_timer.start()
			if score_timer.is_stopped():
				ScoreMaster.score(ScoreMaster.ScoreValue.GOOD)
				score_timer.start()

func toggle_open() -> void:
	if not open:
		open = true
		interact.enable()

func after_reinit() -> void:
	interact = get_behaviour("B3DInteractable")
	if not interact.event.is_connected(interact_event):
		interact.event.connect(interact_event)
	if open:
		interact.enable()

@warning_ignore("unused_parameter")
func process(delta: float) -> void:
	if open:
		moveable_part.set_position(moveable_part.position.lerp(pos_open_mark, 1 - animation_weight))
	else:
		moveable_part.set_position(moveable_part.position.lerp(pos_closed_mark, 1 - animation_weight))
