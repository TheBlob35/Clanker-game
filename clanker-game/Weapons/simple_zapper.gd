extends Area2D

var damage := 1
var player: CharacterBody2D

@onready var raycast: RayCast2D = $RayCast2D
@onready var arc: Line2D = $Line2D

func _ready():
	body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player == null:
		return

	global_position = player.global_position
	rotation = (get_global_mouse_position() - global_position).angle() - PI / 2
	monitoring = Input.is_action_pressed("fire")

	if monitoring and raycast.is_colliding():
		_draw_arc(to_local(player.global_position), to_local(raycast.get_collision_point()))
	else:
		arc.clear_points()

func _draw_arc(start: Vector2, end: Vector2):
	var points := PackedVector2Array()
	var segments := 6
	for i in range(segments + 1):
		var t := float(i) / segments
		var point := start.lerp(end, t)
		if i > 0 and i < segments:
			var perp := (end - start).orthogonal().normalized()
			point += perp * randf_range(-12.0, 12.0)
		points.append(point)
	arc.points = points

func _on_body_entered(body):
	if body.is_in_group("boss"):
		body.take_damage(damage)
