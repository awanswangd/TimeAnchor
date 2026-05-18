extends CanvasLayer

@onready var name_label: Label = $DialogBox/NameLabel
@onready var text_label: Label = $DialogBox/TextLabel
#Masukkan teks ceritanya pake Format: Nama|Isi Teks

var dialog_queue: Array = []

func _ready() -> void:
	get_tree().paused = true
	var ui = get_tree().get_first_node_in_group("ui_manager")
	if ui != null and ui.has_method("hide_hud"):
		ui.hide_hud()
	next_dialog_line()

func next_dialog_line() -> void:
	if dialog_queue.size() > 0:
		var current_line = dialog_queue.pop_front()
		
		var parts = current_line.split("|")
		if parts.size() == 2:
			name_label.text = parts[0]
			text_label.text = parts[1]
		else:
			name_label.text = "???"
			text_label.text = current_line
	else:
		end_dialog()

func end_dialog() -> void:
	$DialogBox.hide()
	await get_tree().create_timer(0.1).timeout
	var ui = get_tree().get_first_node_in_group("ui_manager")
	if ui != null and ui.has_method("show_hud"):
		ui.show_hud()
	get_tree().paused = false
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("detonate") or event.is_action_pressed("place_anchor"):
		get_viewport().set_input_as_handled()
		next_dialog_line()
