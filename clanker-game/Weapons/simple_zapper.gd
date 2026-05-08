extends Area2D

var damage := 1
var player: CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player == null:
		return

	global_position = player.global_position
	rotation = (get_global_mouse_position() - global_position).angle() - PI / 2
	monitoring = Input.is_action_pressed("fire")

	if monitoring:
		for body in get_overlapping_bodies():
			if body.is_in_group("boss"):
				body.take_damage(damage)
