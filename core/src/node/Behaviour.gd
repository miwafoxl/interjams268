@abstract
@icon("res://core/res/Behaviour.svg")
class_name Behaviour extends Node

@warning_ignore("unused_signal")
signal event



## The [GameObject] will populate this field with the parent node in which
## this Behaviour is in.
var actor: Node
var enabled: bool = true ## Sets if the behaviour is currently active
var flags: Dictionary[String, Variant] = {} ## Read flags defined in the [GameObject].

#region MANAGING

## Sets this behaviour enabled. 
func set_enabled(enable: bool) -> void:
	enabled = enable

func set_flag(key: String, value: Variant, reinit: bool = false) -> bool:
	if reinit: init.call_deferred()
	return flags.set(key, value)

func remove_flag(key: String, reinit: bool = false) -> bool:
	if reinit: init.call_deferred()
	return flags.erase(key)

#endregion MANAGING
#region OVERRIDEABLES

## This method is called automatically by [GameObject] once it populates
## the [code]actors[/code] variable at runtime.
func init() -> void:
	pass

## This method is called automatically by [GameObject] where it will test
## whether if [code]action()[/code] can be ran.
@warning_ignore("unused_parameter")
func condition(delta: float) -> bool:
	return true

@warning_ignore("unused_parameter")
func condition_physics(delta: float ) -> bool:
	return true

## This method is called automatically by [GameObject], which provides
## action for a met criteria given by [code]condition()[/code].
@warning_ignore("unused_parameter")
func action(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func action_physics(delta: float) -> void:
	pass

#endregion OVERRIDEABLES
