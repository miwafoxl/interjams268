class_name ScoreView extends Control

const FONT_SIZE_ZEROES: int = 30
const FONT_SIZE_NORMAL: int = 40
const MAX_FONT_SIZE_DIFF: int = 40
const FONT_SIZE_DIFF: int = 16
const RLABEL_START: String = "[font sln=0.2][font_size=%s]" % FONT_SIZE_NORMAL
const RLABEL_END: String = "[/font_size][/font]"
const ZEROPAD_BBCODE_START: String = "[color=gray][font_size=%s]" % FONT_SIZE_ZEROES
const ZEROPAD_BBCODE_END: String = "[/font_size][/color]"

@onready var rlabel: RichTextLabel = %RLABEL
@onready var rlabel_diff: RichTextLabel = %"RLABEL DIFF"
@onready var timer_diff: Timer = $DIFF
@export var animation_weight: float = 0.6 # Radians

var displayed_points: float = 0.0
var current_points: int = 0
var total_points: int = 0

var diff_points: int = 0
var diff_points_font_size: int = FONT_SIZE_DIFF

func display(pts: int) -> void:
	if abs(pts - total_points) > 10:
		diff_points = abs(pts - total_points)
		display_diff()
		timer_diff.start()
	total_points = pts

func display_diff() -> void:
	diff_points_font_size = MAX_FONT_SIZE_DIFF
	rlabel_diff.set_visible(true)
	await timer_diff.timeout
	rlabel_diff.set_visible(false)
	diff_points = 0
	
func process_text() -> void:
	var _text: String = "%07d" % displayed_points
	var _zeropad_end_pos: int = -1
	if diff_points > 0:
		diff_points_font_size = lerp(diff_points_font_size, FONT_SIZE_DIFF, 0.3)
		rlabel_diff.set_text("%s+ %s%s" % [
			"[font_size=%s]" % diff_points_font_size, 
			(diff_points), "[/font_size]"])
	if displayed_points > 0:
		rlabel.set_modulate(Color(1.0, 1.0, 1.0, 1))
		for i in _text.length():
			if not _text[i] == "0":
				_text = "%s%s%s%s" % [
					ZEROPAD_BBCODE_START, 
					_text.left(i), 
					ZEROPAD_BBCODE_END,
					_text.substr(i, _text.length() - 2)]
				break
	else:
		rlabel.set_modulate(Color(1.0, 1.0, 1.0, 0.5))
	rlabel.set_text("%s%s%s" % [RLABEL_START, _text, RLABEL_END])

func _process(_delta: float) -> void:
	process_text()
	if ceil(displayed_points) == total_points:
		displayed_points = total_points
		return
	displayed_points = lerpf(displayed_points, float(total_points), 1 - animation_weight)
	#current_poilnts = round(displayed_points)
	

func _ready() -> void:
	rlabel_diff.set_visible(false)
	process_text()
