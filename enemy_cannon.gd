extends Node2D

@onready var hurtbox: Hurtbox = $Hurtbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		queue_free()
	)
