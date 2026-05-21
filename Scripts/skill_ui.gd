extends MarginContainer

@onready var anchor_bar: TextureProgressBar = $HBoxContainer/AnchorBox/AnchorBar
@onready var dash_bar: TextureProgressBar = $HBoxContainer/DashBox/DashBar

func start_anchor_cooldown(cooldown_time: float) -> void:
	anchor_bar.max_value = 100
	anchor_bar.value = 100 
	
	var tween = create_tween()
	tween.tween_property(anchor_bar, "value", 0.0, cooldown_time)

func start_dash_cooldown(cooldown_time: float) -> void:
	dash_bar.max_value = 100
	dash_bar.value = 100 
	
	var tween = create_tween()
	tween.tween_property(dash_bar, "value", 0.0, cooldown_time)
