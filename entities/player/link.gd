extends CharacterBody3D

@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0
var move_direction := Vector3.ZERO
var last_move_direction := Vector3.ZERO

@onready var _model : Sprite3D = $Sprite3D
@onready var _spring_arm : LinksSpringArm3D = $SpringArm3D
@onready var _camera : Camera3D = $SpringArm3D/Camera3D
@onready var _anime : AnimationPlayer = $AnimationPlayer
@onready var state_helper = $StateHelper

func _ready():
	state_helper.reset("movement")

func _process(delta): 
	state_helper.process(self, delta) 

func _physics_process(delta): 
	state_helper.phy_process(self, delta) 

func physics_movement(delta: float) -> void:
	update_movement_direction()
	update_model_rotation()
	var move_vector := Vector2(move_direction.x, 0)
	if !Input.is_action_pressed("lock"):
		_spring_arm.move_camera(move_vector)
	else:
		print("lock")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	_anime.playback_speed = move_direction.length()	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta
	move_and_slide()
	if velocity.length() > 0.2:
		var look_direction = Vector2(velocity.z, velocity.x)
		#_model.rotation.y = look_direction.angle()
	_spring_arm.global_position = global_position
	if Input.is_action_pressed("lock"):
		if Input.is_action_just_pressed("lock"):
			_spring_arm.rotation.y = _model.rotation.y + deg2rad(180)
		if move_direction.length() > 0:
			_anime.play("WalkUp")
		else:
			_anime.play("StandUp")
	elif move_direction.length() > 0:
		play_walk_anime()
	else:
		play_stand_anime()
	if Input.is_action_just_pressed("attack"):
		pass

func update_movement_direction():
	move_direction.x = Input.get_action_strength("right")
	move_direction.x -= Input.get_action_strength("left")
	move_direction.z = Input.get_action_strength("down")
	move_direction.z -= Input.get_action_strength("up")	

func update_model_rotation():
	_model.rotation.x = 0
	var cam_x = (_camera.global_position - global_position).z
	var cam_y = (_camera.global_position - global_position).x
	var cam = Vector2(cam_x, cam_y)
	var move = Vector2(last_move_direction.z, last_move_direction.x)
	_model.rotation.y = cam.angle() #- (cam.angle_to(move) * 0.5)
	if _anime.current_animation.contains("Up") or _anime.current_animation.contains("Down"):
		if Input.is_action_pressed("right") and Input.is_action_pressed("up"):
			_model.rotation.y -= deg2rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("up"):
			_model.rotation.y += deg2rad(45)
		if Input.is_action_pressed("right") and Input.is_action_pressed("down"):
			_model.rotation.y += deg2rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("down"):
			_model.rotation.y -= deg2rad(45)
	else:
		if Input.is_action_pressed("right") and Input.is_action_pressed("up"):
			_model.rotation.y += deg2rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("up"):
			_model.rotation.y -= deg2rad(45)
		if Input.is_action_pressed("right") and Input.is_action_pressed("down"):
			_model.rotation.y -= deg2rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("down"):
			_model.rotation.y += deg2rad(45)	
	if move_direction.length() > 0: 
		last_move_direction = move_direction#.normalized()

func play_stand_anime():
	if _anime.current_animation.contains("Right"):
			_anime.play("StandRight")
	if _anime.current_animation.contains("Left"):
		_anime.play("StandLeft")
	if _anime.current_animation.contains("Up"):
		_anime.play("StandUp")
	if _anime.current_animation.contains("Down"):
		_anime.play("StandDown")

func play_walk_anime():
	if Input.is_action_pressed("right"):
		if !Input.is_action_pressed("down") && !Input.is_action_pressed("up"): 
			_anime.play("WalkRight")
	elif Input.is_action_pressed("left"): 
		if !Input.is_action_pressed("down") && !Input.is_action_pressed("up"): 
			_anime.play("WalkLeft")
	elif Input.is_action_pressed("down"): 
		if !Input.is_action_pressed("left") && !Input.is_action_pressed("right"): 
			_anime.play("WalkDown")
	elif Input.is_action_pressed("up"): 
		if !Input.is_action_pressed("left") && !Input.is_action_pressed("right"):
			_anime.play("WalkUp")
