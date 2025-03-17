extends CharacterBody2D

func _physics_process(delta: float) -> void:
	var x_input = Input.get_axis("ui_left", "ui_right")
	
	velocity.x = x_input * 50
	
	move_and_slide()
