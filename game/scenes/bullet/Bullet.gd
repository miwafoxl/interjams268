class_name GBullet extends GameObject

# TODO: Enable spammer when bplayerinput allows and test

var is_from_player: bool = false
var bullet: B3DBullet = null
var vector: Vector3 = Vector3.FORWARD
var special_properties: Dictionary = {}

@export var damage: int = 10
@export var speed: float = 1.0 # How fast it travels
@export var gravity: float = 1.0 # How fast it falls

func after_init() -> void:
	bullet = get_behaviour("B3DBullet")
	bullet.speed = speed
	if not bullet.event.is_connected(bullet_event):
		bullet.event.connect(bullet_event)
	bullet.vector = vector

func set_vector(custom: Vector3) -> void:
	vector = custom

func set_player_bullet(player_bullet: bool = true) -> void:
	is_from_player = player_bullet
	
func set_special_properties(properties: Dictionary) -> void:
	if bullet == null:
		special_properties = properties

func bullet_event(event: String, ...args) -> void:
	match event:
		"collision":
			var _collision: KinematicCollision3D = args[0]
			var _collider: Object = _collision.get_collider()
			if _collider is GEntity:
				var _entity: GEntity = _collider
				_entity.change_hp(-damage)
				if is_from_player:
					ScoreMaster.score(ScoreMaster.ScoreValue.GOOD, 1, "game")
			elif _collider is RigidBody3D:
				var _prop: GProp = _collider.get_parent()
				_prop.collide(vector * damage, _prop.rigid.to_local(_collision.get_position()))
			queue_free()
