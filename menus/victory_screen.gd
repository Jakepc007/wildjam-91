extends Control

@export var main_menu : PackedScene

func _ready() -> void:
	if Global.audio_manager:
		Global.audio_manager.play_track(AudioManager.Track.VICTORY)

func _on_main_menu_pressed() -> void:
	if Global.scene_manager:
		Global.scene_manager.switch_scene(main_menu)
