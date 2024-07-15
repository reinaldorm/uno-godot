extends Node2D

@export var table_scene : PackedScene;
@export var card_scene : PackedScene;

func join_session(is_host: bool = false) -> void:
	var client_player = Player.new();
	
	if is_host:
		Global.game = Game.new().set_game(client_player);
	else:
		# setup client player
		pass;

	Client.player = client_player;
	Client.player.is_host = is_host;
	
	start_game();

func create_deck(times: int) -> Array[Card]:
	var new_pile : Array[Card] = [];
	
	for i in times:
		# four zero cards of each color
		for color in 4:
			var c = card_scene.instantiate() as Card;
			c.set_number(color, 0);
			new_pile.append(c)

		# two of each number per color
		for color in 4:
			for number in 9:
				for j in 2:
					var c = card_scene.instantiate() as Card;
					c.set_number(color, number);
					new_pile.append(c)

		# two of each special (skip, block, draw two) per color
		for color in 4:
			for type in [Global.CardType.SKIP, Global.CardType.REVERSE, Global.CardType.DRAWTWO]:
				for j in 2:
					var special = card_scene.instantiate() as Card;
					special.set_colored_special(type, color);
					new_pile.append(special)

		# four wild and wild draw four cards
		for j in 4:
			var wild = card_scene.instantiate() as Card;
			var wildfour = card_scene.instantiate() as Card;
			wild.set_special(Global.CardType.WILD);
			wildfour.set_special(Global.CardType.WILDFOUR);
			new_pile.append(wild);
			new_pile.append(wildfour);
	
	new_pile.shuffle();
	
	return new_pile;

func start_game() -> void:
	print(Global.game);
	for bot in 4 - Global.game.players.size():
		var bot_player = Player.new();
		bot_player.is_bot = true;
		bot_player.username = "Bot " + str(bot);
		Global.game.add_player(bot_player);
	
	var deck = create_deck(Global.game.config.deck_size);
	Global.game.start_game(deck);
	
	var table = table_scene.instantiate();
	add_child(table);

func new_turn(from: int, steps : int = 1, reverse : int = 0) -> void: 
	if reverse > 0:
		for i in reverse:
			Global.game.direction = -Global.game.direction;

	var nextIndex = (from + steps * Global.game.direction) % Global.game.players.size();
	
	while nextIndex < 0:
		nextIndex += Global.game.players.size();	
	
	Global.game.current_turn = nextIndex;
	
	for player in Global.game.players:
		player.is_turn = player == Global.game.current_player;

func play_cards(cards: Array[Card], color = null):
	var cards_size = cards.size();
	
	match cards[0].type:
		Game.CardType.WILD:
			new_turn(Global.game.current_turn);
			cards[cards_size - 1].color = color;
		Game.CardType.WILDFOUR:
			Global.game.payload += 4 * cards_size;
			new_turn(Global.game.current_turn);
			cards[cards_size - 1].color = color;
		Game.CardType.SKIP:
			if Global.game.players.size() == 2:
				new_turn(Global.game.current_turn, 0);
			else:
				new_turn(Global.game.current_turn, cards_size + 1);
		Game.CardType.REVERSE:
			if Global.game.players.size() == 2:
				new_turn(Global.game.current_turn, 0, cards_size);
			else:
				new_turn(Global.game.current_turn, 1, cards_size);
		Game.CardType.DRAWTWO:
			Global.game.payload += 2 * cards_size;
			new_turn(Global.game.current_turn);
		Game.CardType.NUMBER:
			new_turn(Global.game.current_turn);
			
	Global.game.discard_pile.append_array(cards);
	Global.game.current_player.hand = Global.game.current_player.hand.filter(
		func(c): return cards.all(
			func(d): return c != d ));
	
	get_tree().call_group("discard", "update_discard", cards);
	get_tree().call_group("player", "update_turn");

func draw_cards(amount: int) -> Array[Card]:
	var drawn_cards : Array[Card] = [];
	
	for i in amount:
		drawn_cards.append(Global.draw_pile.pop_back());
		
	return drawn_cards;

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		Client.player.hand.append_array(draw_cards(1));
		get_tree().call_group("hand", "update_hand");
	if Input.is_action_just_pressed("ui_down"):
		Client.player.hand.pop_back();
		get_tree().call_group("hand", "update_hand");
