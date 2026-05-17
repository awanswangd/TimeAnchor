extends MarginContainer

@onready var anchor_bar: TextureProgressBar = $HBoxContainer/AnchorBox/AnchorBar
@onready var dash_bar: TextureProgressBar = $HBoxContainer/DashBox/DashBar

func start_anchor_cooldown() -> void:
	var cooldown_time = 3.0 
	
	anchor_bar.max_value = 100
	anchor_bar.value = 100 
	
	var tween = create_tween()
	tween.tween_property(anchor_bar, "value", 0.0, cooldown_time)

func start_dash_cooldown() -> void:
	var cooldown_time = 2.5 
	
	dash_bar.max_value = 100
	dash_bar.value = 100 
	
	var tween = create_tween()
	tween.tween_property(dash_bar, "value", 0.0, cooldown_time)
