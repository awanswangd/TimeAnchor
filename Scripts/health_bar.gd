extends ProgressBar

@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $Timer

var health: int = 0 : set = _set_health

func _set_health(new_health: int) -> void:
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		queue_free()
	
	if damage_bar != null and timer != null:
		if health < prev_health:
			timer.start()
		else:
			damage_bar.value = health

func init_health(_health: int) -> void:
	max_value = _health
	
	if damage_bar != null:
		damage_bar.max_value = _health
		damage_bar.value = _health
	health = _health 

func _on_timer_timeout() -> void:
	if damage_bar != null:
		var tween = create_tween()
		tween.tween_property(damage_bar, "value", health, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
