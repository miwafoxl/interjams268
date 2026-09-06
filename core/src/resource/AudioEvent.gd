class_name AudioEvent extends Resource

@export var bus_name: AudioEventBus = AudioEventBus.MASTER
@export var priority: int = 1
@export var stream_list: AudioStreamPlaylist = null

enum AudioEventBus {
	MASTER, # Uncategorized
	MUSIC, # Music
	DIALOGUE, # Vocal taunts and dialogs
	EFFECT_LOFD, # Low-feedback SFX
	EFFECT_HIFD, # Hi-feedback SFX
}

func to_bus() -> StringName:
	match bus_name:
		AudioEventBus.MUSIC:
			return &"MUSIC"
		AudioEventBus.EFFECT_LOFD:
			return &"SFX LO"
		AudioEventBus.EFFECT_HIFD:
			return &"SFX HI"
		_:
			return &"Master"
