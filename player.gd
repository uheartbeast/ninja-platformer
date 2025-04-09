extends CharacterBody2D

enum STATE { MOVE, CLIMB }

@export var state: = STATE.CLIMB

@export var max_speed: = 120
@export var acceleration: = 10000
@export var air_acceleration: = 2000
@export var friction: = 10000
@export var air_friction: = 500
@export var up_gravity: = 500
@export var down_gravity: = 600
@export var jump_amount: = 200

var coyote_time: = 0.0

@onready var anchor: Node2D = $Anchor
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower
@onready var ray_cast_upper: RayCast2D = $Anchor/RayCastUpper
@onready var ray_cast_lower: RayCast2D = $Anchor/RayCastLower
@onready var hurtbox: Hurtbox = $Anchor/Hurtbox

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
	
	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		queue_free()
	)
	

func _physics_process(delta: float) -> void:
	match state:
		STATE.MOVE:
			coyote_time -= delta
			
			var x_input = Input.get_axis("move_left", "move_right")
			
			apply_gravity(delta)
			
			if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time > 0):
				jump()
			
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
			
			if should_wall_climb():
				animation_player_upper.play("hang")
				state = STATE.CLIMB
			
		STATE.CLIMB:
			var wall_normal = get_wall_normal()
			
			var y_axis = Input.get_axis("move_up", "move_down")
			var x_axis = Input.get_axis("move_left", "move_right")
			velocity.y = y_axis * max_speed * 0.8
			
			move_and_slide()
			
			if y_axis != 0:
				animation_player_lower.play("climb")
			else:
				animation_player_lower.play("hang")
			
			var request_detach: bool = (sign(x_axis) == wall_normal.x)
			
			var request_wall_jump: bool = (
				(request_detach or Input.is_action_just_pressed("jump"))
				and not Input.is_action_pressed("move_down")
			)
			
			if request_wall_jump:
				velocity.x = wall_normal.x * max_speed
				anchor.scale.x = sign(velocity.x)
				jump()
				state = STATE.MOVE
			
			if not should_wall_climb() or request_detach:
				if Input.is_action_pressed("move_up"): jump()
				state = STATE.MOVE

func jump() -> void:
	velocity.y = -jump_amount

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

func should_wall_climb() -> bool:
	return (
		ray_cast_upper.is_colliding()
		and ray_cast_lower.is_colliding()
		and not is_on_floor()
	)
