class_name GProp extends GameObject

@onready var rigid: RigidBody3D = %RIGID

func collide(force: Vector3, at: Vector3 = Vector3.ZERO) -> void:
	rigid.apply_impulse(force, at)
	
# Runs only once, when the GameObject has done all its tasks and it's
# ready to perform the behaviours.
func after_init() -> void:
	rigid.set_collision_mask(103)

# Runs everytime the behaviours are restarted. When a flag is added, or
# a behaviour is added at runtime.
func after_reinit() -> void:
	pass

# Runs every frame after starting all behaviours. Do not override _process()
# or _physics_process() as they will override GameObject own overrides. Use
# process(delta) and physics_process(delta) when using GameObjects.
@warning_ignore("unused_parameter")
func process(delta: float) -> void:
	pass
