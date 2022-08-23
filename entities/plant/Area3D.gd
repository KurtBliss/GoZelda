class_name PlantArea3D
extends Area3D

func on_hit():
	get_parent().queue_free()
