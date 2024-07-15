extends Node2D;
class_name Table;

@export var adversaries : Array[Adversary];
@onready var hand : Hand = %Hand;

var tween : Tween;

func move_table(): 
	var half_rect_size = get_viewport_rect().size / 2;
	var mouse_pos = get_global_mouse_position();
	var mouse_offset = mouse_pos - half_rect_size;
	var offset_x = remap(mouse_offset.x, -half_rect_size.x, half_rect_size.x, -25, 25);
	var offset_y = remap(mouse_offset.y, -half_rect_size.y, half_rect_size.y, -25, 25);
	var offset = Vector2(-offset_x, -offset_y);
	position = lerp(position, offset, 0.05);

func play_intro():
	if tween and tween.is_running(): tween.kill();
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
	
	for idx in adversaries.size():
		var adversary = adversaries[idx];
		if adversary.player:
			tween.tween_property(adversary, "scale", Vector2.ONE, 1.5).set_delay(idx * 0.25);
			tween.set_parallel(adversary != adversaries[adversaries.size() - 1]);
	
	tween.finished.connect(_on_intro_over);

func _process(_delta) -> void:
	move_table();
	if Input.is_action_just_pressed("ui_accept"):
		hand.show();

func _ready():
	var client_index = Global.game.players.find(Client.player);
	for idx in Global.game.players.size() - 1:
		var next_player_index = wrap(client_index + (idx + 1), 0, Global.game.players.size());
		var slot = adversaries[idx];
		slot.set_adversary(Global.game.players[next_player_index]);
	
	play_intro();

func _on_intro_over():
	hand.update_turn();
