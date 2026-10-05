class_name GameUI extends Control

@onready var score_view: ScoreView = %"SCORE VIEW"
@onready var dialog_view: DialogueView = %"DIALOGUE VIEW"

static var can_interact: bool = false

func _process(_delta: float) -> void:
	if can_interact and not %"INTERACT PROMPT".visible:
		%"INTERACT PROMPT".set_visible(true)
	elif not can_interact and %"INTERACT PROMPT".visible:
		%"INTERACT PROMPT".set_visible(false)
