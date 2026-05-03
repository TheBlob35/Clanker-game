extends Area2D

const UP_SPEED = 500.0
const HORIZONTAL_SPEED_RANGE = 100.0
const DOWN_SPEED = 400.0
const UP_TIME = 0.5
const BLAST_RADIUS = 75.0
const FALL_START_Y = -300.0

var damage := 30
var target_pos := Vector2.ZERO
var xSpeed := 0.0

var _timer := 0.0
var _falling := false
var _player: CharacterBody2D = null
var _warning: Node2D = null

const WARNING_SCRIPT = preload("res://Bosses/Boss 1/Mortar/mortar_warning.gd")

func _ready():
	xSpeed = randf_range(-HORIZONTAL_SPEED_RANGE, HORIZONTAL_SPEED_RANGE)
	_player = get_tree().get_first_node_in_group("player")

	_warning = Node2D.new()
	_warning.set_script(WARNING_SCRIPT)
	_warning.max_radius = BLAST_RADIUS
	get_parent().add_child(_warning)
	_warning.global_position = target_pos

func _physics_process(delta):
	_timer += delta
	if not _falling:
		position.y -= UP_SPEED * delta
		position.x -= xSpeed * delta
		rotation = Vector2(-xSpeed, -UP_SPEED).angle()
		if _timer >= UP_TIME:
			_falling = true
			global_position = Vector2(target_pos.x, FALL_START_Y)
	else:
		position.y += DOWN_SPEED * delta
		rotation = Vector2(0, DOWN_SPEED).angle()
		var fall_progress = (global_position.y - FALL_START_Y) / (target_pos.y - FALL_START_Y)
		if _warning:
			_warning.set_progress(fall_progress)
		if global_position.y >= target_pos.y:
			_impact()

func _impact():
	if _warning:
		_warning.queue_free()
	if _player and global_position.distance_to(_player.global_position) < BLAST_RADIUS:
		_player.take_damage(damage)
	queue_free()
