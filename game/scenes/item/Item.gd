class_name GItem extends GameObject

@export var item_id: String = "fishgame:trouble"
@export var item_q: int = 1
@export var item_meta: Dictionary = {}
@export var cooldown_sec: float = 0.0


var interact: B3DInteractable = null

func after_init() -> void:
	interact = get_behaviour("B3DInteractable")
	if cooldown_sec > 0.0:
		%TIMER.set_wait_time(cooldown_sec)
	if not interact.event.is_connected(event):
		interact.event.connect(event)

func start_cooldown() -> void:
	%TIMER.start()
	%HAZE.set_visible(false)
	%TIMER.timeout.connect(finished_cooldown, ConnectFlags.CONNECT_ONE_SHOT)

func finished_cooldown() -> void:
	interact.enable()
	%HAZE.set_visible(true)
	
func event(ev: String, ...args) -> void:
	match ev:
		"pickup":
			var _bodies: Array[Node3D] = args[0] # B3DInteractable:trigger()
			var _entity: GEntity = null
			for _body: Variant in _bodies:
				if _body is GEntity:
					_entity = _body
					break
			if _entity.give_item(item_id, item_meta, item_q):
				if cooldown_sec > 0.0:
					start_cooldown()
				else:
					queue_free()
