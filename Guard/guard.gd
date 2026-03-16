extends CharacterBody2D
class_name Guard
@export_category("SETUP")
@export var patrol_points : Array[Node2D] ## the guard will visit these nodes in order while patrolling
@export var chase_speed : float = 150
@export var patrol_speed : float = 100
@export var walk_speed : float = 150
@export var acceleration : float = 5
@export var investigation_time : float = 3.0 ## The duration which the guard will spend at an investigation spot before returning to patrol
@export var player_collision_layer : int = 2 ## the player's collision layer. shouldn't need to mess with this
@export_category("INTERNAL") ## don't mess with these
@export var line_of_sight_detector : LineOfSightDetector ## don't mess with these
@export var navigation_agent_2d : NavigationAgent2D ## don't mess with these
@onready var catch_area: Area2D = $CatchArea
@onready var alert_sprite: Sprite2D = $AlertSprite
@onready var curious_sprite: Sprite2D = $CuriousSprite
@onready var detection_area: Area2D = $DetectionArea
@export_category("DEBUG")
@export var DEBUG_PRINT_TRANSITIONS : bool = false ## prints the guard's state transitions to the console
@export var debug_player : Node2D ## temporary, the target which the guard follows/chases
@onready var chase_collision_shape: CollisionShape2D = $DetectionArea/ChaseShape
signal player_spotted() ## sent out when the player enter's this guards awareness
signal player_caught() ## sent out when the player has been touches by the guard

enum States {
	CHASE,
	PATROL,
	INVESTIGATE_SPOT,
	STARTLE,
}

var _state : States :
	set(new_state):
		if new_state == _state: #igore unecessary transitions
			return
		var old_state = _state
		if DEBUG_PRINT_TRANSITIONS:
			prints("guard state change",States.find_key(new_state))
		exit_actions(old_state,new_state) 
		_state = new_state
		enter_actions(old_state,new_state) 

var _last_global_position_detected : Vector2 ## the last global position at which the guard saw the player
var _investigate_target_location : Vector2 ## the point the guard will go to when entering investigate state
var _current_patrol_point_idx : int
var _default_navigation_target_radius : float 
var _time_spent_investigating : float ## time spent at the investigation target
var _time_in_state : float ## a timer that keeps track of how long you've been in a state

func _ready() -> void:
	_current_patrol_point_idx = 0
	_state = States.PATROL
	_default_navigation_target_radius = navigation_agent_2d.target_desired_distance

## matches the old guard state and performs its exit logic
func exit_actions(old_state : States, new_state : States):
	match old_state:
		States.CHASE:
			_investigate_target_location = _last_global_position_detected
			chase_collision_shape.disabled = true
		States.INVESTIGATE_SPOT:
			navigation_agent_2d.target_desired_distance = _default_navigation_target_radius
			curious_sprite.visible = false
			chase_collision_shape.disabled = true
		States.STARTLE:
			alert_sprite.visible = false

## matches the new guard state and performs its entry logic
func enter_actions(old_state : States, new_state : States):
	_time_in_state = 0.0
	match new_state:
		States.PATROL:
			# if no patrol points are set, put one wherever the guard is
			if patrol_points.is_empty(): 
				var temp_patrol_point := Node2D.new()
				temp_patrol_point.global_position = self.global_position
				temp_patrol_point.top_level = true
				add_child(temp_patrol_point)
				patrol_points.append(temp_patrol_point)
				push_warning("guard " + str(self.get_path()) + "has no patrol route")
			set_navigation_target(patrol_points[0].global_position)
		States.INVESTIGATE_SPOT:
			curious_sprite.visible = true
			_time_spent_investigating = 0
			navigation_agent_2d.target_desired_distance *= 2 # increased to avoid jittering with other guards
			set_navigation_target(_investigate_target_location)
			chase_collision_shape.disabled = false
		States.STARTLE:
			alert_sprite.visible = true
		States.CHASE:
			line_of_sight_lost_time = 0.0
			chase_collision_shape.disabled = false

func player_in_catch_radius() -> bool:
	return catch_area.get_overlapping_bodies().size() > 0

var line_of_sight_lost_time : float
func _physics_process(delta: float) -> void:
	_time_in_state += delta
	match _state:
		States.CHASE:
			if player_in_catch_radius():
				player_caught.emit()
			if not line_of_sight_detector.player_in_line_of_sight(get_player_global_position()):
				line_of_sight_lost_time += delta
				if line_of_sight_lost_time > 2:
					_state = States.INVESTIGATE_SPOT
					move_and_slide()
					return
			else:
				line_of_sight_lost_time = 0.0
			# get vector to target
			_last_global_position_detected = get_player_global_position()
			set_navigation_target(get_player_global_position())
			move_with_navigation_agent(chase_speed)
		States.INVESTIGATE_SPOT:
			if line_of_sight_detector.player_detected(get_player_global_position()):
				_state = States.STARTLE
				move_and_slide()
				return
			if navigation_agent_2d.is_navigation_finished():
				velocity = Vector2.ZERO
				_time_spent_investigating += delta
				if _time_spent_investigating > investigation_time:
					_state = States.PATROL
					move_and_slide()
					return
			else:
				move_with_navigation_agent(patrol_speed)

		States.PATROL:
			if line_of_sight_detector.player_detected(get_player_global_position()):
				_state = States.STARTLE
				move_and_slide()
				return
			patrol_update()
		States.STARTLE:
			velocity = Vector2.ZERO
			move_and_slide()
			if _time_in_state > 0.6:
				_state = States.CHASE
	move_and_slide()

func point_area_at_player():
	var direction := get_player_global_position() - global_position
	detection_area.rotation = atan2(direction.y,direction.x)
	pass

func get_player_global_position() -> Vector2:
	return debug_player.global_position

func patrol_update():
	if navigation_agent_2d.is_navigation_finished():
		_current_patrol_point_idx = (_current_patrol_point_idx + 1) % patrol_points.size()
		set_navigation_target(patrol_points[_current_patrol_point_idx].global_position)

	move_with_navigation_agent(patrol_speed)

func move_with_navigation_agent(speed : float):
	if navigation_agent_2d.is_navigation_finished():
		return
	# Get the next point in the path
	var current_pos = global_position
	var next_path_pos = navigation_agent_2d.get_next_path_position()
	
	# Calculate velocity
	var new_velocity = (next_path_pos - current_pos).normalized() * speed
	velocity = new_velocity
	move_and_slide()

func set_navigation_target(target_point: Vector2):
	navigation_agent_2d.target_position = target_point

func player_detected() -> bool:
	if debug_player:
		return line_of_sight_detector.player_detected(get_player_global_position())
	else:
		return false
