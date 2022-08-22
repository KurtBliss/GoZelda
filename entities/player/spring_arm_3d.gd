class_name LinksSpringArm3D
extends SpringArm3D

@export var mouse_sensitivity := 0.025

func _ready():
	top_level = true

func move_camera(move_vector):
	rotation.x -= move_vector.y * mouse_sensitivity
	rotation.x = clamp(rotation.x, deg2rad(-90.0), deg2rad(30.0))
	
	rotation.y -= move_vector.x * mouse_sensitivity
	rotation.y = wrapf(rotation.y, deg2rad(0.0), deg2rad(360.0))
