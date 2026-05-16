extends Node

# Tarik node TileMapLayer milikmu dari panel Scene (kiri) 
# ke dalam kotak kosong di Inspector (kanan) nantinya.
@export var arena_tilemap: TileMapLayer

# Waktu (dalam detik) seberapa cepat lantai hancur
@export var decay_speed: float = 0.5 

var decay_timer: Timer

func _ready() -> void:
	# Kita membuat Timer secara otomatis lewat kode
	decay_timer = Timer.new()
	decay_timer.wait_time = decay_speed
	decay_timer.autostart = true
	
	# Hubungkan sinyal timeout ke fungsi penghancur lantai
	decay_timer.timeout.connect(destroy_random_floor)
	
	# Masukkan timer ke dalam sistem
	add_child(decay_timer)

func destroy_random_floor() -> void:
	if arena_tilemap == null:
		return
		
	# Ambil semua koordinat lantai yang saat ini masih ada
	var active_cells = arena_tilemap.get_used_cells()
	
	if active_cells.size() > 0:
		# Pilih satu koordinat secara acak
		var random_index = randi() % active_cells.size()
		var target_cell = active_cells[random_index]
		
		# Hapus lantai tersebut (set index ke -1 berarti dikosongkan)
		arena_tilemap.set_cell(target_cell, -1)
