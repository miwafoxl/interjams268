class_name Progression extends Node

static var last_milestone_reached_index: int = 0
static var score_milestones: Array[int] = [
	3000, # Moon
	5000, # Machel
	7000, # Palma
	10000, # Paku
	15000, # Trouble
]

static var flags: Array = []
static var player_inventory: BInventory = BInventory.new()

#region FLAGS

static func check_flag(flag: String) -> bool:
	return flags.has(flag)

static func is_flag_set(flag: String, set_flag: bool = true) -> bool:
	if check_flag(flag):
		return false
	if set_flag:
		flags.append(flag)
	print("[Progression] Set flag '%s'" % flag)
	return true

static func is_flag_unset(flag: String, unset: bool = true) -> bool:
	if not check_flag(flag):
		return false
	if unset:
		var _idx: int = flags.find(flag)
		flags.remove_at(_idx)
		print("[Progression] Unset flag '%s'" % flag)
	return true
	

#endregion FLAGS
#region SCORE MILESTONES

static func check_score_milestone() -> bool:
	var _total: int = ScoreMaster.get_total_points()
	if _total >= score_milestones[last_milestone_reached_index + 1]:
		last_milestone_reached_index += 1
		return true
	return false

static func get_milestone_item_id() -> String:
	var _item_id: String = ""
	match last_milestone_reached_index:
		0:
			_item_id = "fishgame:moon"
		1:
			_item_id = "fishgame:machel"
		2:
			_item_id = "fishgame:palma"
		3:
			_item_id = "fishgame:paku"
		4:
			_item_id = "fishgame:trouble"
	return _item_id

#endregion SCORE MILESTONES
