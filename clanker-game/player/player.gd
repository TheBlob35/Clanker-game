extends CharacterBody2D

const SPEED = 50
#const DASH_SPEED = 500.0
#const DASH_TIME = 0.12
#const DASH_DELAY = 1.5

#var dash_time_left := 0.0
#var dash_cooldown := 0.0
#var dash_direction := Vector2.ZERO

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("Right"):
		direction.x += 1
	if Input.is_action_pressed("Left"):
		direction.x -= 1
	if Input.is_action_pressed("Down"):
		direction.y += 1
	if Input.is_action_pressed("Up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	#dash_time_left -= delta
	#dash_cooldown -= delta

	#if Input.is_action_just_pressed("ui_accept") and dash_cooldown <= 0 and direction != Vector2.ZERO:
		#dash_time_left = DASH_TIME
		#dash_cooldown = DASH_DELAY
		#dash_direction = direction

	#if dash_time_left > 0:
		#velocity = dash_direction * DASH_SPEED
	#else:
	
	velocity = direction * SPEED

	move_and_slide()
	
	
var max_hp = 100
var current_hp = 100

func take_damage(amount):
	current_hp -= amount
	print("HP: ", current_hp)  # optional, useful for testing
	
	if current_hp <= 0:
		die()

func die():
	get_tree().quit()  # or load a game over screen, respawn, etc.
