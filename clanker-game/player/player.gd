extends CharacterBody2D

const SPEED = 100

var max_hp: int
var current_hp: int
var damage: int
var crit_chance: float

var current_weapon := "Simple Zapper"

func _ready():
	max_hp = 3
	current_hp = max_hp
	damage = get_meta("Damage")
	crit_chance = get_meta("Crit")
	add_to_group("player")

func _physics_process(_delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("Right"):
		print("höger")
		$AnimatedSprite2D.play("idle-when-left_right")
		direction.x += 1
	if Input.is_action_pressed("Left"):
		$AnimatedSprite2D.play("idle-when-left_right")
		direction.x -= 1
		print("vänster")
	if Input.is_action_pressed("Down"):
		$AnimatedSprite2D.play("idle-when-down")
		direction.y += 1
		print("Ner")
	if Input.is_action_pressed("Up"):
		$AnimatedSprite2D.play("idle-when-up")
		direction.y -= 1
		print("Upp")

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		_update_animation(direction)

	velocity = direction * SPEED
	move_and_slide()

func _update_animation(dir: Vector2):
	# Flip sprite for left/right; swap to direction-specific anims once populated
	if abs(dir.x) >= abs(dir.y):
		$AnimatedSprite2D.flip_h = dir.x < 0
	$AnimatedSprite2D.play("idle-when-left_right")

func take_damage(amount: int):
	current_hp -= amount
	print("HP: ", current_hp)
	if current_hp <= 0:
		die()

func die():
	get_tree().reload_current_scene()
