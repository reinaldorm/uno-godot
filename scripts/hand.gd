extends Node2D;
class_name Hand;

@export var x_curve : Curve;
@export var y_curve : Curve;
@export var rot_curve : Curve;
@export var delay_curve : Curve;

@export var x_mult : float : get = _get_x_mult;
@export var y_mult : float : get = _get_y_mult;
@export var rot_mult : float : get = _get_rot_mult;

var tween_split : Tween;
var tween_hover : Tween;

var is_hovering : bool;
var hovering_card : Card;
var hovering_siblings : Array;

func update_hand():
	var to_add = Player.hand.filter(func(card): return not find_child(card.name));
	var to_remove = get_children().filter(func(c): return Player.hand.any(func(n): c != n));
	
	for card in to_remove: card.queue_free();
	
	for card in to_add:
		card.connect("card_entered", _on_card_entered);
		card.connect("card_exited", _on_card_exited);
		card.connect("card_down", _on_card_down);
		card.connect("card_up", _on_card_up);
		add_child(card);
	
	arrange_hand();

func arrange_hand():
	var actual_hand = Player.hand;
	var actual_size = Player.hand.size();
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

func _get_x_mult():
	var actual_size = Player.hand.size();
	
	if actual_size < 15:
		return x_mult;
	else: return 10;

func _get_y_mult():
	var actual_size = Player.hand.size();
	
	if actual_size < 15:
		return y_mult;
	else: return 1.25;

func _get_rot_mult():
	var actual_size = Player.hand.size();
	
	if actual_size < 20:
		return rot_mult;
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
	pass;

func _on_card_up(card: Card):
	pass;

func _ready():
	update_hand();
