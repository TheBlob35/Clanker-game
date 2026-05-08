extends Node2D

const WEAPONS = {
	"Simple Zapper": preload("res://Weapons/simple_zapper.tscn")
}

func _ready() -> void:
	$Player/Camera2D.enabled = false
	var player = $Player
	var weapon_scene = WEAPONS.get(player.current_weapon)
	if weapon_scene:
		var weapon = weapon_scene.instantiate()
		add_child(weapon)
