extends CanvasLayer

@onready var rich_text_label = $RichTextLabel
@onready var button = $Button
@onready var scroll_bar: VScrollBar = rich_text_label.get_v_scroll_bar()
@onready var parallax_layer = $ParallaxBackground/ParallaxLayer

@export var scroll_start = 3

signal scroll_completed

var _completed = false
var speed = 1
var _scroll_delta = 0
var auto_scroll = true
var animation_started = false

func _ready():
	button.hide()
	rich_text_label.connect("meta_clicked", _richtextlabel_on_meta_clicked)
	rich_text_label.connect("mouse_entered", _on_mouse_entered)
	rich_text_label.connect("mouse_exited", _on_mouse_exited)
	scroll_bar.step = 0.01

func _richtextlabel_on_meta_clicked(meta):
	OS.shell_open(str(meta))  # Abre un enlace externo

func _process(delta):
	if auto_scroll and not _completed:
		# Detectar si la barra espaciadora está presionada
		if Input.is_key_pressed(KEY_SPACE):
			speed = 20
		else:
			speed = 5
		
		if _scroll_delta < scroll_start:
			_scroll_delta += delta * speed
		else:
			var old_scroll_value = scroll_bar.value
			scroll_bar.value += 0.1 * speed
			if parallax_layer:
				parallax_layer.motion_offset.y -= 0.05 * speed
			
			if !_completed and scroll_bar.value == old_scroll_value:
				_completed = true
				_show_back()
		
		if not animation_started:
			animation_started = true  # Marcar que la animación ha comenzado

func _show_back():
	button.show()
	
func _on_mouse_entered():
	if animation_started:  # Solo pausar si la animación ya ha comenzado
		auto_scroll = false  # Pausar el desplazamiento automático

func _on_mouse_exited():
	if animation_started:  # Solo reanudar si la animación ya ha comenzado
		auto_scroll = true  # Reanudar el desplazamiento automático

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
