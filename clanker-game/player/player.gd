extends CharacterBody2D

const SPEED = 100

var max_hp = 100
var current_hp = 100

func _ready():
	add_to_group("player")
	$AnimatedSprite2D.play("idle-when-down")

func _physics_process(_delta):
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
		_update_animation(direction)

	velocity = direction * SPEED
	move_and_slide()

func _update_animation(dir: Vector2):
	# Flip sprite for left/right; swap to direction-specific anims once populated
	if abs(dir.x) >= abs(dir.y):
		$AnimatedSprite2D.flip_h = dir.x < 0
	$AnimatedSprite2D.play("idle-when-down")

func take_damage(amount: int):
	current_hp -= amount
	print("HP: ", current_hp)
	if current_hp <= 0:
		die()

func die():
	get_tree().reload_current_scene()
