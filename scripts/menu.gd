extends CanvasLayer;

signal create_pressed;
signal join_pressed;

@onready var user_type = get_node("UserType");
@onready var user_id = get_node("UserID");
@onready var menu = get_node("Menu");

func _on_create_pressed():
	create_pressed.emit();

func _on_join_pressed():
	join_pressed.emit();
