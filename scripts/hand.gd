extends Node2D;
class_name Hand;

@export var x_curve : Curve;
@export var y_curve : Curve;
@export var rot_curve : Curve;
@export var delay_curve : Curve;

@export var x_mult : float : get = _get_x_mult;
@export var y_mult : float : get = _get_y_mult;
@export var rot_mult : float : get = _get_rot_mult;

@onready var draw_pile : Node2D = %Draw;

var tween_split : Tween;
var tween_hover : Tween;

var is_hovering : bool;
var hovering_card : Card;
var hovering_siblings : Array;

var selected_cards : Array[Card] = [];
var legal_cards : Array[Card] = [];

func update_turn():
	selected_cards = [];
	legal_cards = [];
	if Client.player.is_turn:
		legal_cards = Player.get_legal_cards(Client.player.hand, selected_cards, Global.game);
	else:
		if Global.rules["off_play"]:
			pass; # get_offturn_legal_cards;
	
	update_hand();

func update_hand():
	var actual_nodes = get_children();
	
	var to_add = Client.player.hand.filter(func(c): return actual_nodes.all(func(n): return c != n));
	
	for card in to_add:
		card.connect("card_entered", _on_card_entered);
		card.connect("card_exited", _on_card_exited);
		card.connect("card_down", _on_card_down);
		card.connect("card_up", _on_card_up);
		card.position = draw_pile.to_local(global_position) * -1;
		add_child(card);
	
	arrange_hand();

func arrange_hand():
	var actual_size = Client.player.hand.size();
	if tween_split and tween_split.is_running: tween_split.kill();
		
	tween_split = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel();

	for idx in actual_size:
		var card : Card = Client.player.hand[idx];
		var ratio = 0.0;
		
		if actual_size == 1: ratio = 0.5;
		else: ratio = float(idx) / float((actual_size - 1));
			
		var final_x = x_curve.sample(ratio) * (actual_size * x_mult);
		var final_y = y_curve.sample(ratio) * (actual_size * y_mult);
		var final_rot = rot_curve.sample(ratio) * (actual_size * rot_mult);
			
		if selected_cards.has(card):
			tween_split.tween_property(card, "sprite:material:shader_parameter/width", 0, 0.4);
			tween_split.tween_property(card, "rotation", 0, 0.4);
			tween_split.tween_property(card, "position:y", final_y - 30, 0.4);
			card.z_index = 99;
		else:
			if not card == hovering_card: card.z_index = 0;
			tween_split.tween_property(card, "rotation", final_rot, 0.4);
			tween_split.tween_property(card, "position:x", final_x, 0.4);
			tween_split.tween_property(card, "position:y", final_y, 0.4);
			
			if legal_cards.has(card):
				tween_split.tween_property(card, "sprite:material:shader_parameter/width", 1, 0.4);
				tween_split.tween_property(card, "scale", Vector2.ONE * 1.1, 0.4);
			else:
				tween_split.tween_property(card, "sprite:material:shader_parameter/width", 0, 0.4);
				tween_split.tween_property(card, "scale", Vector2.ONE, 0.4);

func hover_card():
	tween_hover = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING);
	tween_hover.tween_property(hovering_card, "sprite:scale", Vector2(4.5, 4.5), 0.2);
	tween_hover.tween_property(hovering_card, "sprite:position", Vector2.UP * 5, 0.2);
	hovering_card.z_index = 99;

func select_card(card: Card) -> void:
	if selected_cards.size() > 0:
		var first_card = selected_cards[0];
		if selected_cards.has(card):
			if card == first_card:
				selected_cards = []
			else:
				selected_cards = selected_cards.filter(func(c):
					return c != card
				)
		else:
			if legal_cards.has(card):
				selected_cards.append(card);
	else:
		if legal_cards.has(card):
			selected_cards = [card];
	
	legal_cards = Player.get_legal_cards(Client.player.hand, selected_cards, Global.game);
	arrange_hand();

func _get_x_mult():
	var actual_size = Client.player.hand.size();
	
	if actual_size < 15: return x_mult;
	else: return 15;
	
func _get_y_mult():
	var actual_size = Client.player.hand.size();
	
	if actual_size < 15: return y_mult;
	elif actual_size < 30: return 2.25;
	else: return 1.5;

func _get_rot_mult():
	var actual_size = Client.player.hand.size();
	
	if actual_size < 20: return rot_mult;
	elif actual_size < 30: return 0.01;
	else: return 0;

func _on_card_entered(card: Card):
	if is_hovering: return;
	is_hovering = true;
	hovering_card = card;
	hover_card();

func _on_card_exited(card: Card):
	if card == hovering_card:
		if tween_hover and tween_hover.is_running(): 
			tween_hover.kill();
		is_hovering = false;
		hovering_card = null;
		tween_hover = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING);
		tween_hover.tween_property(card, "sprite:scale", Vector2(3.5, 3.5), 0.2);
		tween_hover.tween_property(card, "sprite:position", Vector2.ZERO, 0.2);
		card.z_index = 0;

func _on_card_down(card: Card):
	if legal_cards.has(card) or selected_cards.has(card):
		select_card(card);

func _on_card_up(card: Card):
	pass;

func _ready():
	pass;
