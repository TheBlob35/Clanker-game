extends CharacterBody2D

enum Phase { ONE, TWO, THREE }
enum MoveState { SWEEP_A, SWEEP_B, CENTERING, RELOADING }

const PHASE_TWO_THRESHOLD = 0.66
const PHASE_THREE_THRESHOLD = 0.3

const MOVE_SPEED = 140.0
const ACCELERATION = 90.0
const GATLING_RATE = 2.5
const GATLING_BURST = 30
const GATLING_RELOAD = 5.0
const MORTAR_BURST_DELAY = 0.2
const MORTAR_INTERVAL = 1.2
const MORTAR_RELOAD = 4.0

var max_hp = 600
var current_hp = 600
var current_phase = Phase.TWO
var invulnerable = false
var initial_y: float
var initial_x: float

var player: CharacterBody2D = null
var _gatling_timer := 0.0
var _gatling_burst_count := 0
var _mortar_timer := 0.0
var _burst_count := 0

var _move_state = MoveState.RELOADING
var _sweep_dir := 1
var _sweep_time := 0.0
var _sweep_elapsed := 0.0
var _reload_elapsed := 0.0

@onready var barrel: Marker2D = $Marker2D
@onready var shield: Area2D = $Area2D

const BULLET = preload("res://Bosses/Boss 1/Bullet/bullet.tscn")
const MORTAR_BULLET = preload("res://Bosses/Boss 1/Mortar/mortar_bullet.tscn")

func _ready():
	player = get_tree().get_first_node_in_group("player")
	shield.get_node("Sprite2D").visible = false
	initial_y = global_position.y
	initial_x = global_position.x
 
func _physics_process(delta):
	if player == null:
		return

	global_position.y = initial_y

	match current_phase:
		Phase.ONE:
			_phase_one(delta)
		Phase.TWO:
			_phase_two(delta)
		Phase.THREE:
			_phase_three(delta)

# --- Phase 1: stationary, shoots directly at player ---

func _phase_one(delta):
	_gatling_timer += delta
	if _gatling_burst_count < GATLING_BURST:
		if _gatling_timer >= 1.0 / GATLING_RATE:
			_gatling_timer = 0.0
			_gatling_burst_count += 1
			_shoot_gatling()
	else:
		if _gatling_timer >= GATLING_RELOAD:
			_gatling_timer = 0.0
			_gatling_burst_count = 0
		
		
func _shoot_gatling():
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = barrel.global_position
	bullet.direction = (player.global_position - barrel.global_position).normalized()
	bullet.damage = 10

# --- Phase 2: sweeps left/right, fires mortars, shield while moving ---

func _phase_two(delta):
	match _move_state:

		MoveState.RELOADING:
			_set_shield(false)
			velocity.x = move_toward(velocity.x, 0.0, ACCELERATION * delta)
			move_and_slide()
			if abs(velocity.x) < 1.0:
				_reload_elapsed += delta
				if _reload_elapsed >= MORTAR_RELOAD:
					_start_sweep()

		MoveState.SWEEP_A:
			_set_shield(true)
			velocity.x = move_toward(velocity.x, _sweep_dir * MOVE_SPEED, ACCELERATION * delta)
			move_and_slide()
			_fire_mortar(delta)
			_sweep_elapsed += delta
			if _sweep_elapsed >= _sweep_time:
				_sweep_elapsed = 0.0
				_sweep_dir *= -1
				_move_state = MoveState.SWEEP_B

		MoveState.SWEEP_B:
			_set_shield(true)
			velocity.x = move_toward(velocity.x, _sweep_dir * MOVE_SPEED, ACCELERATION * delta)
			move_and_slide()
			_fire_mortar(delta)
			_sweep_elapsed += delta
			if _sweep_elapsed >= _sweep_time * 2.0:
				_sweep_elapsed = 0.0
				_move_state = MoveState.CENTERING

		MoveState.CENTERING:
			_set_shield(true)
			var dist = initial_x - global_position.x
			if abs(dist) < 6.0:
				global_position.x = initial_x
				velocity.x = 0.0
				_reload_elapsed = 0.0
				_move_state = MoveState.RELOADING
			else:
				velocity.x = move_toward(velocity.x, sign(dist) * MOVE_SPEED, ACCELERATION * delta)
				move_and_slide()

func _phase_three(delta):
	# TODO: movement (faster sweeps?)
	# TODO: attack pattern
	match _move_state:
		pass
	pass
	

func _start_sweep():
	_sweep_time = randf_range(2, 3.5)
	_sweep_dir = [-1, 1].pick_random()
	_sweep_elapsed = 0.0
	_mortar_timer = 0.0
	_burst_count = 0
	_move_state = MoveState.SWEEP_A

func _fire_mortar(delta):
	_mortar_timer += delta
	if _burst_count < 6:
		if _mortar_timer >= MORTAR_BURST_DELAY:
			_mortar_timer = 0.0
			_burst_count += 1
			_shoot_mortar()
	else:
		if _mortar_timer >= MORTAR_INTERVAL:
			_mortar_timer = 0.0
			_burst_count = 0

func _shoot_mortar():
	var bullet = MORTAR_BULLET.instantiate()
	bullet.target_pos = Vector2(
		randf_range(0, 1152),
		randf_range(390, 600)
	)
	
	bullet.damage = 30
	get_parent().add_child(bullet)
	bullet.global_position = barrel.global_position

func _set_shield(active: bool):
	invulnerable = active
	shield.get_node("Sprite2D").visible = active

# --- Health / phase transitions ---

func take_damage(amount: int):
	if invulnerable:
		return
	current_hp -= amount
	print("Boss HP: ", current_hp)
	if current_hp <= max_hp * (1.0 - PHASE_TWO_THRESHOLD) and current_phase == Phase.ONE:
		_enter_phase_two()
	if current_hp <= max_hp * (1.0 - PHASE_THREE_THRESHOLD) and current_phase == Phase.TWO:
		_enter_phase_three()
	if current_hp <= 0:
		die()

func _enter_phase_two():
	current_phase = Phase.TWO
	print("Phase 2!")
	# TODO: play transition animation/sound
	
	
func _enter_phase_three():
	current_phase = Phase.THREE
	# TODO: reset state, play transition animation/sound

func die():
	print("Boss defeated!")
	# TODO: trigger win condition
	queue_free()
