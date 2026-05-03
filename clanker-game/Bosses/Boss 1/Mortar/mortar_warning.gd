extends Node2D

var max_radius := 75.0
var progress := 0.0

func _draw():
	var r = lerp(8.0, max_radius, progress)
	var fill_color = Color(1.0, lerp(0.85, 0.0, progress), 0.0, lerp(0.15, 0.55, progress))
	draw_circle(Vector2.ZERO, r, fill_color)

func set_progress(p: float):
	progress = clamp(p, 0.0, 1.0)
	queue_redraw()
