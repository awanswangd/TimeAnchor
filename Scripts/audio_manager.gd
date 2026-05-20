extends Node

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM" 
	add_child(bgm_player)

func play_bgm(stream: AudioStream) -> void:
	if stream == null: return
	
	# Kalau lagunya sama dan lagi jalan, jangan di-restart biar ga kedengaran aneh
	if bgm_player.stream == stream and bgm_player.playing:
		return 
		
	bgm_player.stream = stream
	bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()

func pause_bgm(is_paused: bool) -> void:
	bgm_player.stream_paused = is_paused


func play_sfx(stream: AudioStream, randomize_pitch: bool = false) -> void:
	if stream == null: return
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "SFX"
	if randomize_pitch:
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
		
	add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(func(): sfx_player.queue_free())
