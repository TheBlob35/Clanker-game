extends Area2D

const SPEED = 300.0
const LIFETIME = 4.0

var direction := Vector2.ZERO
var damage := 10

var _age := 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * SPEED * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
