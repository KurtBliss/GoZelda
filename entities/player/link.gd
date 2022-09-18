class_name Player
extends CharacterBody3D

@export var speed := 7.0
@export var jump_strength := 20.0
@export var gravity := 50.0
var move_direction := Vector3.ZERO
var last_move_direction := Vector3.ZERO
var direction_string = "Down"

@onready var _model : Sprite3D = $Sprite3D
@onready var _spring_arm : LinksSpringArm3D = $SpringArm3D
@onready var _camera : Camera3D = $SpringArm3D/Camera3D
@onready var _anime : AnimationPlayer = $AnimationPlayer
@onready var state_helper = $StateHelper

func _ready():
	state_helper.reset("movement")
	ref.player = self

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
	
	if move_direction.length() > 0: 
		last_move_direction = move_direction#.normalized()
			
	#_anime.playback_speed = move_direction.length()	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	velocity.y -= gravity * delta
	move_and_slide()
	_spring_arm.global_position = global_position
	if Input.is_action_pressed("lock"):
		direction_string = "Up"
		
		if Input.is_action_just_pressed("lock"):
			#_spring_arm.rotation.y = _model.rotation.y + deg_to_rad(180)
			var angle = Vector2(last_move_direction.z, \
				last_move_direction.x).angle()
			_spring_arm.rotation.y = angle + deg_to_rad(180)
		if move_direction.length() > 0:
			_anime.play("WalkUp")
		else:
			_anime.play("StandUp")
	elif move_direction.length() > 0:
		play_walk_anime()
	else:
		play_stand_anime()
	handle_attack()

func handle_attack():
	if !Input.is_action_just_pressed("attack") or !PlayerData.has_sword:
		return
	state_helper.reset("attack")
	play_swing_anime()

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
	_model.rotation.y = cam.angle() #- (cam.angle_to(move) * 0.5)
	if _anime.current_animation.contains("Up") or _anime.current_animation.contains("Down"):
		if Input.is_action_pressed("right") and Input.is_action_pressed("up"):
			_model.rotation.y -= deg_to_rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("up"):
			_model.rotation.y += deg_to_rad(45)
		if Input.is_action_pressed("right") and Input.is_action_pressed("down"):
			_model.rotation.y += deg_to_rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("down"):
			_model.rotation.y -= deg_to_rad(45)
	else:
		if Input.is_action_pressed("right") and Input.is_action_pressed("up"):
			_model.rotation.y += deg_to_rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("up"):
			_model.rotation.y -= deg_to_rad(45)
		if Input.is_action_pressed("right") and Input.is_action_pressed("down"):
			_model.rotation.y -= deg_to_rad(45)
		if Input.is_action_pressed("left") and Input.is_action_pressed("down"):
			_model.rotation.y += deg_to_rad(45)	
	

func play_stand_anime():
	if direction_string == "Right":
			_anime.play("StandRight")
	elif direction_string == "Left":
		_anime.play("StandLeft")
	elif direction_string == "Up":
		_anime.play("StandUp")
	else:
		_anime.play("StandDown")

func play_walk_anime():
	if Input.is_action_pressed("right"):
		if !Input.is_action_pressed("down") && !Input.is_action_pressed("up"): 
			_anime.play("WalkRight")
			direction_string = "Right"
	elif Input.is_action_pressed("left"): 
		if !Input.is_action_pressed("down") && !Input.is_action_pressed("up"): 
			_anime.play("WalkLeft")
			direction_string = "Left"
	elif Input.is_action_pressed("down"): 
		if !Input.is_action_pressed("left") && !Input.is_action_pressed("right"): 
			_anime.play("WalkDown")
			direction_string = "Down"
	elif Input.is_action_pressed("up"): 
		if !Input.is_action_pressed("left") && !Input.is_action_pressed("right"):
			_anime.play("WalkUp")
			direction_string = "Up"

func play_swing_anime():
	if direction_string == "Right":
		_anime.play("SwingRight", -1, 1)
	elif direction_string == "Left":
		_anime.play("SwingLeft", -1, 1)
	elif direction_string == "Up":
		_anime.play("SwingUp", -1, 1)
	else:
		_anime.play("SwingDown", -1, 1)

func on_hit():
	print("player: on_hit()")

func _on_animation_player_animation_finished(anim_name):
	if str(anim_name).count("Swing") > 0:
		state_helper.reset("movement")
		play_stand_anime()


func _on_sword_area_entered(area):
	if area.has_method("on_hit"):
		area.call("on_hit")
	if area is RupeeArea3D:
		PlayerData.rupees += 1
		if PlayerData.rupees > PlayerData.rupees_max:
			PlayerData.rupees = PlayerData.rupees_max


func _on_pickup_area_area_entered(area):
	if area is RupeeArea3D:
		PlayerData.rupees += 1
		if PlayerData.rupees > PlayerData.rupees_max:
			PlayerData.rupees = PlayerData.rupees_max
		if area.has_method("on_hit"):
			area.call("on_hit")



func _on_sword_body_entered(body):
	if body is Enemy:
		print(body)
		body.on_hit(35)
	if body is Chuchu:
		print("Chuchu")
	if body is CharacterBody3D:
		print("CharBody!")
	
