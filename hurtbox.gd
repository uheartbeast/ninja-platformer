class_name Hurtbox extends Area2D

var is_invincible: = false

signal hurt(other_hitbox: Hitbox)

func take_hit(other_hitbox: Hitbox) -> void:
	if is_invincible: return
	hurt.emit(other_hitbox)
