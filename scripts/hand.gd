extends Node2D;
class_name Hand;

@export var x_curve : Curve;
@export var y_curve : Curve;
@export var rot_curve : Curve;
@export var delay_curve : Curve;

@export var x_mult : float : get = _get_x_mult;
@export var y_mult : float : get = _get_y_mult;
@export var rot_mult : float : get = _get_rot_mult;

@onready var draw_pile : Node2D = get_tree().get_first_node_in_group("draw");

var actual_hand : Array[Card] = [];

var tween_split : Tween;
var tween_hover : Tween;

var is_hovering : bool;
var hovering_card : Card;
var hovering_siblings : Array;

func update_hand():
	var actual_nodes = get_children();
	actual_hand = Player.hand;
	
	var to_add = actual_hand.filter(func(c): return actual_nodes.all(func(n): return c != n));
	var to_remove = actual_nodes.filter(func(c): return actual_hand.all(func(n): return c != n));
	
	for card in to_remove: card.queue_free();
	for card in to_add:
		card.connect("card_entered", _on_card_entered);
		card.connect("card_exited", _on_card_exited);
		card.connect("card_down", _on_card_down);
		card.connect("card_up", _on_card_up);
		card.position = draw_pile.to_local(global_position) * -1;
		add_child(card);
	
	arrange_hand();

func arrange_hand():
	var actual_size = actual_hand.size();
	if tween_split and tween_split.is_running:
		tween_split.kill();
		
	tween_split = create_tween();
	tween_split.set_ease(Tween.EASE_OUT);
	tween_split.set_trans(Tween.TRANS_SPRING);
	tween_split.set_parallel();

	for idx in actual_size:
		var card : Card = actual_hand[idx];
		var ratio = 0.0;
	
		if actual_size == 1: 
			ratio = 0.5;
		else:
			ratio = float(idx) / float((actual_size - 1));
		
		var final_x = x_curve.sample(ratio) * (actual_size * x_mult);
		var final_y = y_curve.sample(ratio) * (actual_size * y_mult);
		var final_rot = rot_curve.sample(ratio) * (actual_size * rot_mult);
		
		tween_split.tween_property(card, "rotation", final_rot, 0.4);
		tween_split.tween_property(card, "position:x", final_x, 0.4);
		tween_split.tween_property(card, "position:y", final_y, 0.4);

func hover_card():
	tween_hover = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING);
	tween_hover.tween_property(hovering_card, "sprite:scale", Vector2(4.5, 4.5), 0.2);
	tween_hover.tween_property(hovering_card, "sprite:position", Vector2.UP * 5, 0.2);
	hovering_card.z_index = 99;

func get_legal_cards() -> Array[Card]:
	var next_available_cards: Array[Card] = []
	var last_card = Global.discard_pile[Global.discard_pile.size() - 1]

	if Player.selected_cards.size() > 0:
		var all_cards_but_selected = actual_hand.filter(func(card):
			return not Player.selected_cards.has(card)
		)

		for card in all_cards_but_selected:
			if Global.payload:
				if card.type == Global.CardType.WILDFOUR:
					if card.type == Player.selected_cards[0].type:
						next_available_cards.append(card)
				elif card.type == Global.CardType.DRAWTWO:
					if last_card.type == Global.CardType.WILDFOUR:
						if card.color == Player.selected_cards[0].color:
							next_available_cards.append(card)
					else:
						next_available_cards.append(card)
			else:
				if card.type != Global.CardType.NUMBER:
					if card.type == Player.selected_cards[0].type:
						next_available_cards.append(card)
				else:
					if card.number == Player.selected_cards[0].number:
						next_available_cards.append(card)
	else:
		if Global.payload:
			for card in actual_hand:
				if card.type == Global.CardType.WILDFOUR:
					next_available_cards.append(card)
				elif card.type == Global.CardType.DRAWTWO:
					if last_card.type == Global.CardType.WILDFOUR:
						if card.color == last_card.color:
							next_available_cards.append(card)
					else:
						if card.type == last_card.type:
							next_available_cards.append(card)
		else:
			for card in actual_hand:
				if card.type == Global.CardType.WILD or card.type == Global.CardType.WILDFOUR:
					next_available_cards.append(card)
				elif card.type != Global.CardType.NUMBER:
					if card.color == last_card.color:
						next_available_cards.append(card)
					if card.type == last_card.type:
						next_available_cards.append(card)
				else:
					if card.color == last_card.color:
						next_available_cards.append(card)
					if card.number == last_card.number:
						next_available_cards.append(card)

	return next_available_cards

func select_card(card: Card) -> void:
	if Player.selected_cards.size() > 0:
		var first_card = Player.selected_cards[0];
		if Player.selected_cards.has(card):
			if card == first_card:
				Player.selected_cards = []
			else:
				Player.selected_cards = Player.selected_cards.filter(func(c):
					return c != card
				)
		else:
			if Player.legal_cards.has(card):
				Player.selected_cards.append(card);
	else:
		if Player.legal_cards.has(card):
			Player.selected_cards = [card];

func _get_x_mult():
	var actual_size = actual_hand.size();
	
	if actual_size < 15: return x_mult;
	else: return 15;
	
func _get_y_mult():
	var actual_size = actual_hand.size();
	
	if actual_size < 15: return y_mult;
	elif actual_size < 30: return 2.25;
	else: return 1.5;

func _get_rot_mult():
	var actual_size = actual_hand.size();
	
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
	select_card(card);

func _on_card_up(card: Card):
	pass;

func _ready():
	update_hand();
	if Player.is_turn:
		Player.legal_cards = get_legal_cards();
