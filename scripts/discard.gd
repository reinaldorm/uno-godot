extends Node2D;

@onready var hand : Hand = %Hand;
var tween : Tween;

func update_discard(cards: Array[Card]):
	var card_amount = cards.size();

	var tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING);
	
	for idx in cards.size():
		var card = cards[idx] as Card;
		var delay = idx * 0.25;
		
		if card.is_inside_tree(): card.reparent(self);
		else: add_child(card);
		card.set_inactive();
		
		tween.tween_property(card, "position", Vector2.ZERO, 0.4).set_delay(delay);

func _ready():
	update_discard(Global.game.discard_pile);

func _process(delta):
	pass;

func _on_button_pressed():
	if hand.selected_cards.size() > 0:
		get_tree().call_group("game", "play_cards", hand.selected_cards);

func _on_mouse_entered():
	if tween and tween.is_running(): tween.kill();
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING).set_parallel();
	tween.tween_property(self, "scale", Vector2.ONE * 1.15, 0.2);

func _on_mouse_exited():
	if tween and tween.is_running(): tween.kill();
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING).set_parallel();
	tween.tween_property(self, "scale", Vector2.ONE, 0.2);
