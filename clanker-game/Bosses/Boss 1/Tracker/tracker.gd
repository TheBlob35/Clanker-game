extends Area2D

const SPEED = 150.0
const LIFETIME = 5.5

var direction := Vector2.ZERO
var damage := 10

const TURN_SPEED = 1.5

var _age := 0.0
var _player: CharacterBody2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if _player:
		var desired = (_player.global_position - global_position).normalized()
		direction = direction.lerp(desired, TURN_SPEED * delta)
	position += direction * SPEED * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		# TODO: Animation for bullet exploding

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
