extends Node2D;
class_name Table;

@export var hand : Hand;
@export var adversaries : Array[Adversary];

func move_table():
	var half_rect_size = get_viewport_rect().size / 2;
	var mouse_pos = get_global_mouse_position();
	var mouse_offset = mouse_pos - half_rect_size;
	var offset_x = remap(mouse_offset.x, -half_rect_size.x, half_rect_size.x, -25, 25);
	var offset_y = remap(mouse_offset.y, -half_rect_size.y, half_rect_size.y, -25, 25);
	var offset = Vector2(-offset_x, -offset_y);
	position = lerp(position, offset, 0.1);

func _process(_delta) -> void:
	move_table();

func _ready():
	var client_index = Global.players.find(Client.player);
	
	for idx in Global.players.size() - 1:
		var next_player_index = (client_index + (idx + 1)) % adversaries.size();
		var slot = adversaries[next_player_index];
		slot.set_adversary(Global.players[idx]);
