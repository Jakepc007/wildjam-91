extends Node
class_name SceneManager

@export var default_scene : PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _current_scene : Node

func _ready() -> void:
	Global.scene_manager = self
	switch_scene(default_scene)

func switch_scene(scene: PackedScene):
	if not scene:
		push_warning("SceneManager: null scene provided")
		return
	var new_scene = scene.instantiate()

	if _current_scene:
		remove_child(_current_scene)
	else:
		animation_player.play("fade_in")

	_current_scene = new_scene
	add_child(_current_scene)

func switch_scene_with_fade(scene: PackedScene):
	if not scene:
		return
	animation_player.play("fade_out")
	var on_fade_out = func on_fade_out(_anim, player):
		switch_scene(scene)
		player.play("fade_in")
	animation_player.animation_finished.connect(on_fade_out.bind(animation_player), Object.ConnectFlags.CONNECT_ONE_SHOT)

func remove_current_scene():
	if _current_scene:
		remove_child(_current_scene)
