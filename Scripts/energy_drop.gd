extends Area2D

@export var energy_amount: int = 1
@export var sfx_pickup: AudioStream # Tambahan variabel untuk SFX bensin

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.current_energy += energy_amount
		if body.current_energy > body.starting_energy:
			body.current_energy = body.starting_energy
			
		body.energy_changed.emit(body.current_energy)
		
		# Mainkan SFX jika file audionya sudah dimasukkan di Inspector
		if sfx_pickup != null:
			AudioManager.play_sfx(sfx_pickup, true)
			
		queue_free()
