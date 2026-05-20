extends ProgressBar

@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $Timer

var energy: int = 0 : set = _set_energy

func _set_energy(new_energy: int) -> void:
	var prev_energy = energy
	energy = min(max_value, new_energy)
	value = energy
	
	if damage_bar != null and timer != null:
		if energy < prev_energy:
			timer.start()
		else:
			damage_bar.value = energy

func init_energy(_energy: int) -> void:
	max_value = _energy
	
	if damage_bar != null:
		damage_bar.max_value = _energy
		damage_bar.value = _energy
	energy = _energy 

func _on_timer_timeout() -> void:
	if damage_bar != null:
		var tween = create_tween()
		tween.tween_property(damage_bar, "value", energy, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
