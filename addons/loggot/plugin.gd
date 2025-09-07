@tool
extends EditorPlugin

const AUTOLOAD_NAME = "Loggot"


func _enable_plugin():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/loggot/loggot.gd")


func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_NAME)
