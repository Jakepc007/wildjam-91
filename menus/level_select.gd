extends Control

var level_paths : Dictionary[int,String] = {
	1 : "",
	2 : "",
	3 : "",
	4 : "",
	5 : "",
	6 : "",
}

func _on_level_1_pressed() -> void:
	#Global.scene_manager.switch_scene_with_fade(level_paths[1], \
	#SceneManager.InTransitionEffects.WIPE_IN, SceneManager.OutTransitionEffects.WIPE_OUT)
	pass # Replace with function body.


func _on_level_2_pressed() -> void:
	pass # Replace with function body.


func _on_level_3_pressed() -> void:
	pass # Replace with function body.


func _on_level_4_pressed() -> void:
	pass # Replace with function body.


func _on_level_5_pressed() -> void:
	pass # Replace with function body.


func _on_level_6_pressed() -> void:
	pass # Replace with function body.
