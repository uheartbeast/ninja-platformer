extends Node2D

const SPEED = 100

var direction: Vector2 :
	set(value):
		direction = value.normalized()
		if is_instance_valid(animated_sprite_2d):
			animated_sprite_2d.rotation = direction.angle()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	hitbox.body_entered.connect(func(body: Node2D):
		queue_free()
	)
	hitbox.hit.connect(func(other_hurtbox: Hurtbox):
		queue_free()
	)
	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		reverse.call_deferred()
	)

func _process(delta: float) -> void:
	if animated_sprite_2d.frame == 0: return
	translate(direction * SPEED * delta)

func reverse() -> void:
	direction = direction.rotated(deg_to_rad(180))
	print(direction)
	hurtbox.is_invincible = true
	hitbox.set_collision_mask_value(4, false)
	hitbox.set_collision_mask_value(5, true)
