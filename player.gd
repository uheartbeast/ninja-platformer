extends CharacterBody2D

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
	var x_input = Input.get_axis("ui_left", "ui_right")
	
	if not is_on_floor():
		velocity.y += 500 * delta
	
	velocity.x = x_input * 80
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = -200
	
	if Input.is_action_just_pressed("ui_accept"):
		animation_player_upper.play("attack")
	
	if x_input == 0:
		animation_player_lower.play("stand")
	else:
		anchor.scale.x = sign(x_input)
		animation_player_lower.play("run")
	
	if not is_on_floor():
		animation_player_lower.play("jump")
	
	move_and_slide()
