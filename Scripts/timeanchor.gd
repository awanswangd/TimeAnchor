extends StaticBody2D

# [Variabel Lama yang sudah ada]
@export var radius: int = 2 
@export var floor_id: int = 0 

# [TAMBAHAN BARU 1: Ganti angka 64 sesuai ukuran kotak TileMap-mu di Phase 1]
var tile_size: float = 64.0 

# [TAMBAHAN BARU 2: Rujukan ke node visual agar gampang diakses]
@onready var aura_visual: Sprite2D = $AuraArea/AuraVisual

func _ready() -> void:
	# Memanggil fungsi baru ini sesaat setelah jangkar ditanam
	setup_aura_visual_size()
	
	# [Fungsi Lama yang sudah ada]
	restore_surrounding_tiles()

# --- Fungsi Baru: Kalkulasi Ukuran Aura ---
func setup_aura_visual_size() -> void:
	if aura_visual == null or aura_visual.texture == null:
		return
		
	# 1. Hitung total diameter area aman dalam satuan pixel
	# Rumus: (Radius kiri + 1 Kotak Pusat + Radius kanan) * Ukuran Kotak
	var safe_diameter_in_pixels = (radius * 2 + 1) * tile_size
	
	# 2. Ambil ukuran asli gambar PNG kita (misal 512)
	var original_texture_size = aura_visual.texture.get_size().x
	
	# 3. Hitung rasio skala (Target Ukuran / Ukuran Asli)
	# Ini untuk mencari berapa kali lipat gambar harus dibesarkan/dikecilkan
	var required_scale = safe_diameter_in_pixels / original_texture_size
	
	# 4. Terapkan skala ke node AuraVisual (X dan Y harus sama agar tetap lingkaran)
	aura_visual.scale = Vector2(required_scale, required_scale)

# ... [Fungsi restore_surrounding_tiles lama tetap ada di bawah sini] ...

func _on_aura_area_body_entered(body: Node2D) -> void:
	if body.has_method("apply_time_warp"):
		body.apply_time_warp(true)

func _on_aura_area_body_exited(body: Node2D) -> void:
	if body.has_method("apply_time_warp"):
		body.apply_time_warp(false)

func restore_surrounding_tiles() -> void:
	# Mengambil rujukan ke lantai secara otomatis menggunakan Group yang baru kita buat
	var tilemap = get_tree().get_first_node_in_group("arena")
	if tilemap == null:
		print("ERROR: Tilemap tidak ditemukan! Pastikan TileMapLayer sudah masuk grup 'arena'.")
		return
		
	# Mengubah titik kordinat jangkar menjadi kordinat grid kotak-kotak
	var local_pos = tilemap.to_local(global_position)
	var center_grid_pos = tilemap.local_to_map(local_pos)
	
	# Memindai kotak di sekitar jangkar sesuai dengan jangkauan radius
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var target_cell = center_grid_pos + Vector2i(x, y)
			
			# Cek apakah koordinat tersebut saat ini adalah Void (ID: -1)
			var current_id = tilemap.get_cell_source_id(target_cell)
			if current_id == -1:
				# KEMBALIKAN WAKTU! Ubah lantai yang kosong menjadi lantai utuh lagi
				# Parameter Vector2i(0, 0) adalah koordinat atlas standar di TileSet
				tilemap.set_cell(target_cell, floor_id, Vector2i(0, 0))
				
				# (Kamu bisa menambahkan animasi atau partikel di sini nanti)
