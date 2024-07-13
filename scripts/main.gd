extends Node2D

@export var table_scene : PackedScene;
@export var card_scene : PackedScene;

var table : Table;

func join_session() -> void:
	Global.players.append(Player);
	start_game();

func create_deck() -> Array[Card]:
	var new_pile : Array[Card] = [];
	# four zero cards of each color
	for color in 4:
		var c = card_scene.instantiate() as Card;
		c.set_number(color, 0);
		new_pile.append(c)

	# two of each number per color
	for color in 4:
		for number in 9:
			for i in 2:
				var c = card_scene.instantiate() as Card;
				c.set_number(color, number);
				new_pile.append(c)

	# two of each special (skip, block, draw two) per color
	for color in 4:
		for type in [Global.CardType.SKIP, Global.CardType.REVERSE, Global.CardType.DRAWTWO]:
			for i in 2:
				var special = card_scene.instantiate() as Card;
				special.set_colored_special(type, color);
				new_pile.append(special)

	# four wild and wild draw four cards
	for i in 4:
		var wild = card_scene.instantiate() as Card;
		var wildfour = card_scene.instantiate() as Card;
		wild.set_special(Global.CardType.WILD);
		wildfour.set_special(Global.CardType.WILDFOUR);
		new_pile.append(wild);
		new_pile.append(wildfour);
	
	new_pile.shuffle();
	return new_pile;

func create_adversary(side: Global.AdversarySide) -> void:
	match side:
		Global.AdversarySide.TOP:
			print('create adversary on top');
		Global.AdversarySide.LEFT:
			print('create adversary on the left');
		Global.AdversarySide.RIGHT:
			print('create adversary on the right');

func start_game() -> void:
	var first_card = card_scene.instantiate() as Card;
	
	first_card.set_number(0, 0);
	Global.draw_pile = create_deck();
	Global.discard_pile.append(first_card);
	
	for player in Global.players:
		var first_hand = draw_cards(Global.config["initial_hand"]);
		var is_first = Player.is_host;
		player.set_player(first_hand, is_first);
	
	table = table_scene.instantiate().set_table();
	add_child(table);

func new_turn(from: int, steps : int = 1, reverse : int = 0) -> void: 
	if reverse > 0:
		for i in reverse:
			Global.direction = -Global.direction;

	var nextIndex = (from + steps * Global.direction) % Global.players.size();
	
	while nextIndex < 0:
		nextIndex += Global.players.size();	
	
	Global.current_turn = nextIndex;

func play_cards(cards: Array[Card], color = null):
	var cards_size = cards.size();
	
	match cards[0].type:
		Global.CardType.WILD:
			new_turn(Global.current_turn);
			cards[cards_size - 1].color = color;
		Global.CardType.WILDFOUR:
			Global.payload += 4 * cards_size;
			new_turn(Global.current_turn);
			cards[cards_size - 1].color = color;
		Global.CardType.SKIP:
			if Global.players.size() == 2:
				new_turn(Global.current_turn, 0);
			else:
				new_turn(Global.current_turn, cards_size + 1);
		Global.CardType.REVERSE:
			if Global.players.size() == 2:
				new_turn(Global.current_turn, 0, cards_size);
			else:
				new_turn(Global.current_turn, 1, cards_size);
		Global.CardType.DRAWTWO:
			Global.payload += 2 * cards_size;
			new_turn(Global.current_turn);
		Global.CardType.NUMBER:
			new_turn(Global.current_turn);

func draw_cards(amount: int) -> Array[Card]:
	var drawn_cards : Array[Card] = [];
	
	for i in amount:
		drawn_cards.append(Global.draw_pile.pop_back());
		
	return drawn_cards;

	#player.statistics["total_held"] = max(player.statistics["total_held"], player.hand.size())

func _on_draw_pressed():
	pass;

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		Player.hand.append_array(draw_cards(1));
		table.update_hand();
	if Input.is_action_just_pressed("ui_down"):
		Player.hand.pop_back();
		table.update_hand();
