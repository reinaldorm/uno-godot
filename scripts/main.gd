extends Node2D

@export var table_scene : PackedScene;
@export var card_scene : PackedScene;

func join_session(is_host: bool = false) -> void:
	var client_player = Player.new();
	Global.players.append(client_player);
	Client.player = client_player;
	Client.player.is_host = is_host;
	
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
	
	for bot in 4 - Global.players.size():
		var bot_player = Player.new();
		bot_player.is_bot = true;
		bot_player.username = "Bot " + str(bot);
		Global.players.append(bot_player);
	
	for player in Global.players:
		var first_hand = draw_cards(Global.config["initial_hand"]);
		player.set_player(first_hand, player.is_host); 
	
	var table = table_scene.instantiate();
	add_child(table);

func new_turn(from: int, steps : int = 1, reverse : int = 0) -> void: 
	if reverse > 0:
		for i in reverse:
			Global.direction = -Global.direction;

	var nextIndex = (from + steps * Global.direction) % Global.players.size();
	
	while nextIndex < 0:
		nextIndex += Global.players.size();	
	
	Global.current_turn = nextIndex;
	
	for player in Global.players:
		player.is_turn = player == Global.players[Global.current_turn];

func play_cards(cards: Array[Card], color = null):
	var cards_size = cards.size();
	var playing_player = Global.players[Global.current_turn];
	
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
			
	playing_player.hand = playing_player.hand.filter(func(c): return cards.all(func(d): return c != d ));
	Global.discard_pile.append_array(cards);
	
	get_tree().call_group("player", "update_turn");
	get_tree().call_group("discard", "update_discard", cards);

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
		Client.player.hand.append_array(draw_cards(1));
		get_tree().call_group("hand", "update_hand");
	if Input.is_action_just_pressed("ui_down"):
		Client.player.hand.pop_back();
		get_tree().call_group("hand", "update_hand");
