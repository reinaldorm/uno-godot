extends Node2D;
class_name Draw;

signal draw_pressed;

var tween_handle : Tween;
var hovering : bool = false;

func _on_mouse_entered():
	hovering = true;
	if tween_handle: tween_handle.kill();
	
	tween_handle = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
	tween_handle.tween_property(self, "scale", Vector2.ONE * 1.25, 0.3);
	Input.set_custom_mouse_cursor(load("res://assets/cursor/select.png"));

func _on_mouse_exited():
	hovering = false;
	if tween_handle: tween_handle.kill();
	
	tween_handle = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
	tween_handle.tween_property(self, "scale", Vector2.ONE, 0.3);
	Input.set_custom_mouse_cursor(load("res://assets/cursor/default.png"));

func _on_mouse_down():
	draw_pressed.emit();
	if tween_handle: tween_handle.kill();
	
	tween_handle = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
	tween_handle.tween_property(self, "scale", Vector2.ONE * 1.1, 0.2);

func _on_mouse_up():
	if not hovering: return;
	if tween_handle: tween_handle.kill();
	
	tween_handle = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
	tween_handle.tween_property(self, "scale", Vector2.ONE * 1.25, 0.2);
