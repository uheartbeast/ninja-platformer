extends CharacterBody2D

enum STATE { MOVE, CLIMB }

@export var state: = STATE.CLIMB

@export var max_speed: = 120
@export var acceleration: = 1000
@export var air_acceleration: = 2000
@export var friction: = 1000
@export var air_friction: = 500
@export var up_gravity: = 500
@export var down_gravity: = 600
@export var jump_amount: = 200

var coyote_time: = 0.0

@onready var anchor: Node2D = $Anchor
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower

func _ready() -> void:
	animation_player_lower.current_animation_changed.connect(func(animation_name: String):
		if animation_player_upper.current_animation == "attack": return
		animation_player_upper.play(animation_name)
	)
	
	animation_player_upper.animation_finished.connect(func(animation_name: String):
		if animation_name != "attack": return
		animation_player_upper.play(animation_player_lower.current_animation)
		animation_player_upper.seek(animation_player_lower.current_animation_position)
	)
	

func _physics_process(delta: float) -> void:
	match state:
		STATE.MOVE:
			coyote_time -= delta
			
			var x_input = Input.get_axis("move_left", "move_right")
			
			apply_gravity(delta)
			
			if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time > 0):
				velocity.y = -jump_amount
			
			if Input.is_action_just_pressed("attack"):
				animation_player_upper.play("attack")
			
			if x_input == 0:
				apply_friction(delta)
				animation_player_lower.play("stand")
			else:
				accelerate_horizontally(x_input, delta)
				anchor.scale.x = sign(x_input)
				animation_player_lower.play("run")
			
			if not is_on_floor():
				animation_player_lower.play("jump")
			
			var was_on_floor: = is_on_floor()
			move_and_slide()
			if was_on_floor and not is_on_floor() and velocity.y >= 0:
				coyote_time = 0.1
			
		STATE.CLIMB:
			pass

func accelerate_horizontally(horizontal_direction: float, delta: float) -> void:
	var acceleration_amount: = acceleration
	if not is_on_floor(): acceleration_amount = air_acceleration
	velocity.x = move_toward(velocity.x, max_speed * horizontal_direction, acceleration_amount * delta * abs(horizontal_direction))

func apply_friction(delta) -> void:
	var friction_amount: = friction
	if not is_on_floor(): friction_amount = air_friction
	velocity.x = move_toward(velocity.x, 0.0, friction_amount * delta)

func apply_gravity(delta) -> void:
	if not is_on_floor():
		if velocity.y <= 0:
			velocity.y += up_gravity * delta
		else:
			velocity.y += down_gravity * delta
