extends CharacterBody2D

@onready var anchor: Node2D = $Anchor
@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("ui_left", "ui_right")
	
	if not is_on_floor():
		velocity.y += 500 * delta
	
	velocity.x = x_input * 80
	
	if Input.is_action_just_pressed("ui_up"):
		velocity.y = -200
	
	if x_input == 0:
		animation_player_upper.play("stand")
		animation_player_lower.play("stand")
	else:
		anchor.scale.x = sign(x_input)
		animation_player_upper.play("run")
		animation_player_lower.play("run")
	
	if not is_on_floor():
		animation_player_upper.play("jump")
		animation_player_lower.play("jump")
	
	move_and_slide()
