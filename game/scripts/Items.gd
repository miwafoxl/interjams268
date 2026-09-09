class_name Items extends Node

const DEFAULT_CAT: String = "fishgame"
const UNKNOWN_ITEM_TR: String = "GAME.ITEMS.UNKNOWN"

static var registered_items: Dictionary = {}
static var player_inventory: Dictionary = {}

enum Type {
	UNKNOWN,
	ITEM,
	CONSUMEABLE,
	WEAPON,
}

enum StackSize {
	UNKNOWN = 0,
	WEAPON = 1,
	ITEM = 99,
	COMSUMEABLE = 999,
}

static func get_item_translation(item_id: String) -> String:
	if not registered_items.has(item_id):
		return TranslationServer.translate(UNKNOWN_ITEM_TR)
	return TranslationServer.translate(registered_items[item_id]["translation"])

static func get_item_type(item_id: String) -> Type:
	if not registered_items.has(item_id):
		return Type.UNKNOWN
	match registered_items[item_id]["type"]:
		"item": return Type.ITEM
		"consumeable": return Type.CONSUMEABLE
		"weapon": return Type.WEAPON
		_: return Type.UNKNOWN
		
static func get_item_stack_size(item_id: String) -> int:
	if not registered_items.has(item_id):
		return StackSize.UNKNOWN
	match registered_items[item_id]["type"]:
		"item": return StackSize.ITEM
		"consumeable": return StackSize.COMSUMEABLE
		"weapon": return StackSize.WEAPON
		_: return StackSize.UNKNOWN

static func get_item_model_path(item_id: String) -> String:
	if not registered_items.has(item_id):
		return "" # TODO: Point to a ERROR model
	return registered_items[item_id]["model_path"]

static func is_item_registered(item_id: String) -> bool:
	return registered_items.has(item_id)

func register_item(cat: String, item_id: String, meta: Dictionary) -> void:
	var _item: String = "%s:%s" % [cat, item_id]
	if registered_items.has(_item):
		push_warning("[Items] Attempt to register already registered item '%s'" % _item)
		return
	registered_items.set(_item, meta)
	print("[Items] Registered item '%s' (%s)" % [_item, item_id.capitalize()])

func _ready() -> void:
	# PROGRESSION ITEMS
	register_item(DEFAULT_CAT, "raw_fish", {
		"translation": "GAME.ITEMS.RAW_FISH", 
		"type": "item","model_path": ""})
	register_item(DEFAULT_CAT, "fish_egg", {
		"translation": "GAME.ITEMS.FISH_EGG", "
		type": "item","model_path": ""})
	register_item(DEFAULT_CAT, "fish_bone", {
		"translation": "GAME.ITEMS.FISH_BONE", 
		"type": "item","model_path": ""})

	# GAMEPLAY POWERUPS
	register_item(DEFAULT_CAT, "fishy_business", {
		"translation": "GAME.ITEMS.FISHY_BUSINESS", 
		"type": "consumeable","model_path": ""})
	register_item(DEFAULT_CAT, "divinity_jellygods", {
		"translation": "GAME.ITEMS.DIVINITY_JELLYGODS", 
		"type": "consumeable", "model_path": ""})
	register_item(DEFAULT_CAT, "seaweed", {
		"translation": "GAME.ITEMS.SEAWEED", 
		"type": "consumeable", "model_path": ""})
	register_item(DEFAULT_CAT, "handful_worms", {
		"translation": "GAME.ITEMS.HANDFUL_WORMS", 
		"type": "consumeable", "model_path": ""})
	register_item(DEFAULT_CAT, "shrimp", {
		"translation": "GAME.ITEMS.SHRIMP", 
		"type": "consumeable", "model_path": ""})
	register_item(DEFAULT_CAT, "crab", {
		"translation": "GAME.ITEMS.CRAB", 
		"type": "consumeable", "model_path": ""})

	# WEAPONS
	register_item(DEFAULT_CAT, "tinpia", {
		"translation": "GAME.ITEMS.TINPIA", 
		"type": "weapon", "model_path": ""})
	register_item(DEFAULT_CAT, "moon", {
		"translation": "GAME.ITEMS.MOON", 
		"type": "weapon", "model_path": ""})
	register_item(DEFAULT_CAT, "machel", {
		"translation": "GAME.ITEMS.MACHEL", 
		"type": "weapon", "model_path": ""})
	register_item(DEFAULT_CAT, "palma", {
		"translation": "GAME.ITEMS.PALMA", 
		"type": "weapon", "model_path": ""})
	register_item(DEFAULT_CAT, "paku", {
		"translation": "GAME.ITEMS.PAKU", 
		"type": "weapon", "model_path": ""})
	register_item(DEFAULT_CAT, "trouble", {
		"translation": "GAME.ITEMS.TROUBLE", 
		"type": "weapon", "model_path": ""})
	register_item(DEFAULT_CAT, "atlantic_moon", {
		"translation": "GAME.ITEMS.ATLANTIC_MOON", 
		"type": "weapon", "model_path": ""})
