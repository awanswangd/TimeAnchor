extends Area2D

@export var energy_amount: int = 1 # Jumlah bensin yang didapat

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.current_energy += energy_amount
		body.energy_changed.emit(body.current_energy)
		print("Dapat Bensin! Energi sekarang: ", body.current_energy)
		queue_free()
