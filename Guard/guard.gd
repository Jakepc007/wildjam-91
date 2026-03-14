extends CharacterBody2D
class_name Guard

@export var line_of_sight_detector : LineOfSightDetector
@export var debug_player : Node2D
@export var DEBUG_PRINT_TRANSITIONS : bool = false

enum States {
	WANDER,
	IDLE,
	CHASE
}

var _state : States :
	set(new_state):
		var old_state = _state
		if DEBUG_PRINT_TRANSITIONS:
			prints("guard state change",States.find_key(new_state))
		exit_actions(old_state,new_state)
		_state = new_state
		enter_actions(old_state,new_state)

var _time_in_idle : float
var _last_global_position_detected : Vector2
var _wander_target_location : Vector2

@export var time_to_stop : float = 2.0
@export var chase_speed : float = 300
@export var turn_speed : float = 2
@export var walk_speed : float = 150
@export var acceleration : float = 5



func _ready() -> void:
	_state = States.IDLE

func exit_actions(old_state : States, new_state : States):
	match old_state:
		States.WANDER:
			pass
		States.IDLE:
			pass
		States.CHASE:
			_wander_target_location = _last_global_position_detected
			pass

func enter_actions(old_state : States, new_state : States):
	match new_state:
		States.WANDER:
			pass
		States.IDLE:
			_time_in_idle = 0.0
			velocity = Vector2.ZERO
		States.CHASE:
			pass

func _physics_process(delta: float) -> void:
	match _state:
		States.WANDER:
			# check if at target location
			# if so, idle
			if (global_position - _wander_target_location). length() < 10:
				_state = States.IDLE
				move_and_slide()
				return
			velocity = (_wander_target_location - global_position).normalized()
			velocity = velocity * walk_speed
			pass
		States.IDLE:
			if player_detected():
				_state = States.CHASE
				move_and_slide()
				return
			_time_in_idle += delta
			if _time_in_idle > time_to_stop:
				#_state = States.WANDER
				pass
		States.CHASE:
			if not line_of_sight_detector.player_in_line_of_sight(debug_player.global_position):
				_state = States.WANDER
				move_and_slide()
				return
			# get vector to target
			_last_global_position_detected = debug_player.global_position
			var target_forward_direction = debug_player.global_position - global_position
			target_forward_direction = target_forward_direction.normalized()
			velocity = velocity.lerp(target_forward_direction * chase_speed, delta * acceleration)
			pass
	move_and_slide()


func player_detected() -> bool:
	if debug_player:
		return line_of_sight_detector.player_detected(debug_player.global_position)
	else:
		return false
