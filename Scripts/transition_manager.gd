extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func change_scene(target_path: String) -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	await tween_out.finished
	get_tree().change_scene_to_file(target_path)
	
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	await tween_in.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
