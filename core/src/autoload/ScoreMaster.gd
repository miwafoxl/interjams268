class_name ScoreMaster extends Node

const LOG_VERBOSE: bool = true
const LOG_UNNAMED: String = "<unnamed>"
const DEFAULT_CONTEXT: String = "default"
const DEFAULT_GAMESCORE_ALIAS: String = "auto"

static var loaded_gamescores: Array[GameScore] = []
static var selected_gamescore: WeakRef = null

#region CONSOLE OUT

static func _log_standard(message: String) -> void:
	if not LOG_VERBOSE: return
	print("[Score]: %s" % message)

static func _log_warn(message: String) -> void:
	if not LOG_VERBOSE: return
	push_warning("[Score]: %s" % message)

static func _log_err(message: String) -> void:
	printerr("[Score]: %s" % message)

static func _print_gamescore(gamescore: GameScore = get_selected_gamescore()) -> void:
	print("GameScore alias: '%s'" % gamescore.alias)
	print("\tContexts: %s" % gamescore.context)
	print("\tPromises: %s" % gamescore.promises)


#endregion CONSOLE OUT
#region DEFINITIONS

enum ScoreValue {
	MISS,
	CLOSE_CALL,
	OK,
	GOOD,
	VERY_GOOD,
	PERFECT,
	MAX
}

const POINTS_PER_SCOREVALUE: Dictionary[ScoreValue, int] = {
	ScoreValue.MISS: 0,
	ScoreValue.CLOSE_CALL: 1,
	ScoreValue.OK: 5,
	ScoreValue.GOOD: 10,
	ScoreValue.VERY_GOOD: 25,
	ScoreValue.PERFECT: 50,
}

class GameScore:
	var alias: String = ""
	var context: Dictionary[String, PackedByteArray] = {} # Context Identf: [ScoreValue]
	var promises: Dictionary[String, PackedByteArray] = {} # Promise Identf: [ScoreValue]
	
#endregion DEFINITIONS
#region GAMESCORE

static func is_some_gamescore_loaded() -> bool:
	return loaded_gamescores.size() > 0

static func create_gamescore(alias: String = "") -> GameScore:
	var _gamescore: GameScore = GameScore.new()
	_gamescore.alias = alias
	_gamescore.context = {DEFAULT_CONTEXT: []}
	_log_standard("Created gamescore '%s'" % alias)
	return _gamescore

static func append_gamescore(gamescore: GameScore) -> void:
	loaded_gamescores.append(gamescore)

static func get_selected_gamescore() -> GameScore:
	if selected_gamescore == null:
		_log_warn("Can't return selected gamescore: none is selected")
		return null
	return selected_gamescore.get_ref()

static func get_gamescore_alias(gamescore: GameScore, placeholder_if_unnamed: bool = true) -> String:
	var _log_alias: String = gamescore.alias
	if _log_alias.is_empty() and placeholder_if_unnamed: 
		_log_alias = LOG_UNNAMED
	return _log_alias

static func select_gamescore_at_index(slot_index: int) -> bool:
	if not is_some_gamescore_loaded():
		_log_warn("Can't load gamescore in slot %s: no gamescores loaded" % slot_index)
		return false
	if slot_index > loaded_gamescores.size() - 1:
		_log_warn("Can't load gamescore in slot %s: index not loaded" % slot_index)
		return false
	selected_gamescore = weakref(loaded_gamescores[slot_index])
	var _log_alias: String = get_gamescore_alias(loaded_gamescores[slot_index], true)
	_log_standard("Selected gamescore at slot %s ('%s')" % [slot_index, loaded_gamescores[slot_index].alias])
	return true

static func select_gamescore_by_alias(alias: String) -> bool:
	if not is_some_gamescore_loaded():
		_log_warn("Can't load gamescore with alias '%s': no gamescores loaded" % alias)
		return false
	for i in loaded_gamescores.size():
		var _score: GameScore = loaded_gamescores[i]
		if _score.alias == alias:
			select_gamescore_at_index(i)
			return true
	_log_warn("Can't load gamescore with alias '%s': not found" % alias)
	return false

#endregion GAMESCORE
#region POINTS

static func count_points(scores: PackedByteArray) -> int:
	var _pts: int = 0
	for i: int in ScoreValue.MAX:
		if i == ScoreValue.MISS or i == ScoreValue.MAX: continue
		var _count: int = scores.count(i)
		_pts += (POINTS_PER_SCOREVALUE[i] * _count)
	return _pts

static func get_points(context: String = DEFAULT_CONTEXT) -> int:
	var _gscore: GameScore = get_selected_gamescore()
	var _gcontext: PackedByteArray = []
	var _pts: int = 0
	if _gscore == null:
		_log_warn("Can't get score: no selected gamescore")
		return false
	if not _gscore.context.has(context):
		_log_warn("Can't get score: no context '%s' found" % context)
		return false
	_gcontext = _gscore.context.get(context, _gcontext)
	return count_points(_gcontext)

static func get_total_points() -> int:
	var _gscore: GameScore = get_selected_gamescore()
	var _pts: int = 0
	if _gscore == null:
		_log_warn("Can't get score: no selected gamescore")
		return false
	for context: PackedByteArray in _gscore.context.values():
		_pts += count_points(context)
	return _pts

#endregion POINTS
#region UTILITY

static func accuracy(value: float) -> ScoreValue:
	var _divider: float = 1 / float(ScoreValue.MAX)
	return roundi(value / _divider) as ScoreValue

#endregion UTILITY
#region SCORING

static func score(value: ScoreValue, multiplier: int = 1, \
		context: String = DEFAULT_CONTEXT) -> bool:
	var _gcontext: PackedByteArray = []
	var _scoring: PackedByteArray = []
	var _gscore: GameScore = get_selected_gamescore()
	if _gscore == null:
		_log_warn("Can't place score: no selected gamescore")
		return false
	if (value >= ScoreValue.MAX) or (value < 0):
		_log_warn("Can't place score: illegal score value %s" % value)
		return false
	if _gscore.context.has(context):
		_gcontext = _gscore.context.get(context, _gcontext)
	_scoring.resize(multiplier)
	_scoring.fill(value)
	_gcontext.append_array(_scoring)
	return _gscore.context.set(context, _gcontext)

static func score_if(condition: bool, value: ScoreValue, multiplier: int = 1, \
		context: String = DEFAULT_CONTEXT) -> void:
	if condition: score(value, multiplier, context)

#region PROMISES

static func promise_score(promise_name: String, value: ScoreValue) -> bool:
	var _gscore: GameScore = get_selected_gamescore()
	var _promise: PackedByteArray = []
	if _gscore == null:
		_log_warn("Can't place score promise: no selected gamescore")
		return false
	if _gscore.promises.has(promise_name):
		_promise = _gscore.promises.get(promise_name, _promise)
	_promise.append(value)
	return _gscore.promises.set(promise_name, _promise)

static func promise_score_if(condition: bool, promise_name: String, \
		value: ScoreValue) -> void:
	if condition: promise_score(promise_name, value)

static func commit_promise(promise_name: String, \
		context: String = DEFAULT_CONTEXT) -> bool:
	var _gscore: GameScore = get_selected_gamescore()
	var _gcontext: PackedByteArray = []
	var _scoring: PackedByteArray = []
	if _gscore == null:
		_log_warn("Can't commit score promise: no selected gamescore")
		return false
	if not _gscore.promises.has(promise_name):
		_log_warn("Can't commit score promise: no promise '%s' found" % promise_name)
		return false
	if not _gscore.context.has(context):
		_log_warn("Can't commit score promise: no context '%s' found" % context)
		return false
	_gcontext = _gscore.context.get(context, _gcontext)
	_scoring = _gscore.promises.get(promise_name, _scoring)
	_gcontext.append_array(_scoring)
	_gscore.promises.erase(promise_name)
	return _gscore.context.set(context, _gcontext)

static func commit_promise_if(condition: bool, promise_name: String, \
		context: String = DEFAULT_CONTEXT) -> void:
	if condition: commit_promise(promise_name, context)

static func break_score_promise(promise_name: String) -> bool:
	var _gscore: GameScore = get_selected_gamescore()
	if _gscore == null:
		_log_warn("Can't break score promise: no selected gamescore")
		return false
	if not _gscore.promises.has(promise_name):
		_log_warn("Can't break score promise: no promise '%s' found" % promise_name)
		return false
	_gscore.promises.erase(promise_name)
	return true

#endregion PROMISES
#endregion SCORING
#region IMPORT/EXPORT

# ATTENTION: essa parte tem que deserializar e serializar e eu
# to com preguiça de fazer isso fr

#func decode_json(json: String) -> Dictionary:
	#var _json: JSON = JSON.new()
	#var _scores_dict: Dictionary
	#match _json.parse(json):
		#OK:
			#_scores_dict.assign(_json.get_data())
		#_:
			#if _log_warn("Can't decode JSON: unable to " + \
			#"parse json string (%s)" % _json.get_error_message())
			#return {}
	#return _scores_dict
#
#func export_json() -> String:
	#var _gscore: GameScore = get_selected_gamescore()
	#if _gscore == null:
		#if _log_warn("Can't export JSON: no selected gamescore")
		#return ""

static func load_scores(gamescores: Array[GameScore], append: bool = false) -> void:
	selected_gamescore = null
	if append:
		loaded_gamescores.append_array(gamescores)
	else:
		loaded_gamescores = gamescores.duplicate(true)

#endregion IMPORT/EXPORT

func _ready() -> void:
	append_gamescore(create_gamescore(DEFAULT_GAMESCORE_ALIAS))
	select_gamescore_at_index(0)
