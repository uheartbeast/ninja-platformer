extends CharacterBody2D

@onready var animation_player_upper: AnimationPlayer = $AnimationPlayerUpper
@onready var animation_player_lower: AnimationPlayer = $AnimationPlayerLower

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("ui_left", "ui_right")
	
	velocity.x = x_input * 80
	
	if x_input == 0:
		animation_player_upper.play("stand")
		animation_player_lower.play("stand")
	else:
		animation_player_upper.play("run")
		animation_player_lower.play("run")
	
	
	move_and_slide()
