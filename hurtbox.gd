class_name Hurtbox extends Area2D

@export var is_invincible: = false :
	set(value):
		is_invincible = value
		var children = get_children()
		for child in children:
			if child is not CollisionShape2D and child is not CollisionPolygon2D: continue
			child.set_deferred("disabled", is_invincible)

signal hurt(other_hitbox: Hitbox)

func take_hit(other_hitbox: Hitbox) -> void:
	if is_invincible: return
	hurt.emit(other_hitbox)
