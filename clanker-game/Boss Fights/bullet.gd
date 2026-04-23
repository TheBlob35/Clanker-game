extends Area2D

var direction := Vector2.RIGHT
var speed := 150.0
var damage := 10
var source := "boss"

func _ready() -> void:
	if source == "boss":
		collision_layer = 16
		collision_mask = 5   # player (1) + walls (4)
	else:
		collision_layer = 8
		collision_mask = 6   # boss (2) + walls (4)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(5.0).timeout.connect(func():
		if is_instance_valid(self): queue_free())

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if source == "boss" and body.is_in_group("player"):
		body.take_damage(damage)
	elif source == "player" and body.is_in_group("boss"):
		body.take_damage(damage)
	queue_free()
