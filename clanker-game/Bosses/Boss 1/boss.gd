extends CharacterBody2D

var max_hp = 500
var current_hp = 500

# TODO: add boss phases, movement patterns, attacks

func _ready():
	pass

func take_damage(amount):
	current_hp -= amount
	print("Boss HP: ", current_hp)

	if current_hp <= 0:
		die()

func die():
	print("Boss defeated!")
	# TODO: trigger win condition, cutscene, etc.
	queue_free()
