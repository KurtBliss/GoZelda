class_name Enemy
extends CharacterBody3D

var health = 100

func distance_to_player() -> float:
	var dist_vect : Vector3 = global_position - ref.player.global_position
	return dist_vect.length()

func direction_to_player(ignore_y = true) -> Vector3:
	var vect : Vector3 =  ref.player.global_position - global_position
	if ignore_y:
		vect.y = 0
	return vect.normalized()

func on_hit(dmg):
	health -= dmg
	if health <= 0:
		queue_free()
