extends Node2D

@onready var test: BRotate = GameObject.get_behaviour_from($Icon3, "BRotate")
var reverse_all: bool = false

func _ready() -> void:
	test.event.connect(process_event)

func process_event(event: String) -> void:
	match event:
		"sound.rotating":
			SoundBlaster.queue_play("rotating")
		"sound.stopped":
			SoundBlaster.queue_play("stopped_rotating")

func _on_icon_but_pressed() -> void:
	test.rotating = $Icon

func _on_icon_2_but_pressed() -> void:
	test.rotating = $Icon2

func _on_icon_3_but_pressed() -> void:
	test.rotating = $Icon3

func _on_iconrev_pressed() -> void:
	if not reverse_all:
		$Icon3.set_local_flag("reverse", true, true)
		$Icon2.set_local_flag("reverse", true, true)
	else:
		$Icon3.remove_local_flag("reverse", true)
		$Icon2.remove_local_flag("reverse", true)
	reverse_all = not reverse_all
