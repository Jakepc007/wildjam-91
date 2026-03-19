extends Node
class_name SceneManager

@export var default_scene_path : String

@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum InTransitionEffects {
	FADE_IN,
	WIPE_IN
}

enum OutTransitionEffects {
	FADE_OUT,
	WIPE_OUT,
}
const _in_transition_anims : Dictionary[InTransitionEffects, String] = {
	InTransitionEffects.FADE_IN : "fade_in",
	InTransitionEffects.WIPE_IN : "wipe_in"
}
const _out_transition_anims : Dictionary[OutTransitionEffects, String] = {
	OutTransitionEffects.FADE_OUT : "fade_out",
	OutTransitionEffects.WIPE_OUT : "wipe_out"
}
var _current_scene : Node

func _ready() -> void:
	Global.scene_manager = self
	switch_scene(default_scene_path)

func switch_scene(scene_path : String):
	var new_scene = load(scene_path)
	if not new_scene:
		push_warning("scene not found: " + scene_path)
		return
	new_scene = new_scene.instantiate()
	
	if _current_scene:
		remove_child(_current_scene)
	else:
		animation_player.play("fade_in")

	_current_scene = new_scene
	add_child(_current_scene)
	pass


func switch_scene_with_fade(scene_path : String, \
							in_effect : InTransitionEffects = InTransitionEffects.FADE_IN,\
							out_effect : OutTransitionEffects = OutTransitionEffects.FADE_OUT):
	var in_anim
	var out_anim
	if _in_transition_anims.has(in_effect):
		in_anim = _in_transition_anims[in_effect]
	else:
		in_anim = _in_transition_anims[InTransitionEffects.FADE_IN]
	if _out_transition_anims.has(out_effect):
		out_anim = _out_transition_anims[out_effect]
	else:
		out_anim = _out_transition_anims[OutTransitionEffects.FADE_OUT]
	
	
	var new_scene = load(scene_path)
	if not new_scene:
		push_warning("scene not found: " + scene_path)
		return
	new_scene = new_scene.instantiate()
	animation_player.play(out_anim)
	var on_fade_out = func on_fade_out(_anim,player):
		switch_scene(scene_path)
		player.play(in_anim)
	animation_player.animation_finished.connect(on_fade_out.bind(animation_player),Object.ConnectFlags.CONNECT_ONE_SHOT)

func remove_current_scene():
	if _current_scene:
		remove_child(_current_scene)
