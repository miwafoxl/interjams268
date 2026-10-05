class_name DialogueView extends Control

const RLABEL_START: String = "[font_size=14]"
const RLABEL_END: String = "[/font_size]"
const TYPING_SPEED: int = 4
const PROMPT_TYPING_CONTINUE: String = "[...]"
const PROMPT_DIALOG_TITLE: String = ":: "

@export var pages: Array[String] = []
@export var inserts: Array[Dictionary] = [] # Page Idx -> {Char Idx: text to insert}
@export var auto: bool = true
@export var free_after_fade: bool = true
@export_range(0.0, 16.0, 0.25) var wait_time: float = 4.0

@onready var rlabel: RichTextLabel = %RLABEL
@onready var rlabel_title: RichTextLabel = %RTITLE
@onready var button: Button = %CONFIRM
@onready var auto_timer: Timer = %AUTO

var current_page: int = 0
var current_insert: Dictionary = {}
var type_length: int = 0
var chars_typed: int = 0
var type: String = ""
var title: String = ""
var typed: String = ""
var fade: bool = false

func display(page_list: Array[String], page_inserts: Array[Dictionary] = []) -> void:
	pages = page_list
	inserts = page_inserts
	current_page = 0
	typed = ""
	fade = false
	select_page()

func select_page(page: int = 0) -> void:
	if pages.is_empty(): 
		fade = true
		return
	type = pages[page]
	type_length = type.length()
	if page < inserts.size():
		current_insert = inserts[page]
	if not type.begins_with(PROMPT_TYPING_CONTINUE):
		typed = ""
	if type.get_slice_count(PROMPT_DIALOG_TITLE) == 2:
		title = type.get_slice(PROMPT_DIALOG_TITLE, 0)
		type = type.get_slice(PROMPT_DIALOG_TITLE, 1)
		rlabel_title.set_text(title)
		rlabel_title.set_visible(true)
	else:
		rlabel_title.set_visible(false)
	type = type.replace(PROMPT_TYPING_CONTINUE, "")
	chars_typed = 0
	type_progress()

func confirm() -> void:
	current_page += 1
	if current_page >= pages.size():
		finished(); return
	select_page(current_page)

func finished() -> void:
	fade = true

func type_progress() -> void:
	if chars_typed == type_length and auto and auto_timer.is_stopped():
		type_insert()
		auto_timer.start()
	typed += type.substr(chars_typed, TYPING_SPEED)
	chars_typed = mini(chars_typed + TYPING_SPEED, type_length)
	type_insert()
	rlabel.set_text("%s%s%s" % [RLABEL_START, typed, RLABEL_END])

func type_skip() -> void:
	typed += type.substr(chars_typed, type_length - chars_typed)
	chars_typed = type_length

func type_insert() -> void:
	if not current_insert.is_empty():
		for _index: int in current_insert.keys():
			var _insert: String = current_insert.get(_index)
			if chars_typed >= _index or chars_typed == type_length:
				typed = typed.insert(_index, _insert)
				current_insert.erase(_index)

var tick: int = 0
func _process(_delta: float) -> void:
	tick += 1
	if tick > 1000:
		tick = 0
	if fade:
		set_modulate(modulate.lerp(Color.TRANSPARENT, 0.4))
		if free_after_fade and modulate.a < 0.1:
			queue_free()
	else:
		set_modulate(modulate.lerp(Color.WHITE, 0.4))
		if tick % 2 == 0:
			type_progress()
		if Input.is_action_pressed("confirm"):
			type_skip()

func _ready() -> void:
	set_modulate(Color.TRANSPARENT)
	auto_timer.set_wait_time(wait_time)
	if not button.pressed.is_connected(confirm):
		button.pressed.connect(confirm)
	if not auto_timer.timeout.is_connected(confirm):
		auto_timer.timeout.connect(confirm)
	if auto:
		%CONFIRM.set_visible(false)
	select_page()
