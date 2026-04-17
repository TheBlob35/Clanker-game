extends CharacterBody2D

const SPEED = 100


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
	
	velocity = direction * SPEED

	move_and_slide()
	
	
var max_hp = 100
var current_hp = 100

func take_damage(amount):
	current_hp -= amount
	print("HP: ", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	get_tree().quit()
