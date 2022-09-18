class_name Chuchu
extends Enemy
@onready var state_helper = $StateHelper
@onready var anime = $AnimationPlayer
var speed = 2
var jump_speed = 4
var jump_height = 10
var direction

func _ready():
	state_helper.reset("idle")

func _process(delta): 
	state_helper.process(self, delta) 

func _physics_process(delta): 
	state_helper.phy_process(self, delta) 

func physics_idle(_delta):
	anime.play("Normal")
	if (distance_to_player() < 4):
		state_helper.reset("coming")
	handle_velocity()

func physics_coming(_delta):
	anime.play("Normal")
	if (distance_to_player() > 2):
		direction = direction_to_player()
		velocity = direction * speed
	handle_velocity()

func physics_start_jump(_delta):
	velocity = direction * 0
	handle_velocity()

func physics_jump(_delta):
	velocity = direction * jump_speed
	handle_velocity()

func handle_velocity():
	velocity.y = -10
	move_and_slide()

func start_jump():
	anime.play("Jump", -1, 0.3)
	state_helper.reset("start_jump")

func handle_jump():
	velocity.y = jump_height
	state_helper.reset("jump")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Jump":
		state_helper.reset("coming")

func _on_start_jump_timer_timeout():
	if state_helper.has("coming"):
		start_jump()


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.on_hit()
