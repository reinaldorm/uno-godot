extends Node2D

@export var table_scene : PackedScene;
@export var card_scene : PackedScene;

var draw_pile : Array[Card] = [];
var discard_pile : Array[Card] = [];

var winner : Player;
var ongoing = false;
var players : Array[Player] = [];
var current_turn = 0;
var direction = 1;
var payload = 0;

var config = {
	"initial_hand": 10,
}

var rules = {
	"offPlay": false,
	"forcedDraw": false,
	"strictMode": false,
	"rush": false,
	"zeroBomb": false,
};

var table : Table;

func join_session() -> void:
	players.append(Player);
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
	draw_pile = create_deck();
	discard_pile.append(first_card);
	
	for player in players:
		var first_hand = draw_cards(config["initial_hand"]);
		var is_first = Player.is_host;
		player.set_player(first_hand, is_first);
	
	table = table_scene.instantiate().set_table();
	add_child(table);

func new_turn(from: int, steps : int = 1, reverse : int = 0) -> void: 
	if reverse > 0:
		for i in reverse:
			direction = -direction;

	var nextIndex = (from + steps * direction) % players.size();
	
	while nextIndex < 0:
		nextIndex += players.size();	
	
	current_turn = nextIndex;

func play_cards(cards: Array[Card], color = null):
	var cards_size = cards.size();
	
	match cards[0].type:
		Global.CardType.WILD:
			new_turn(current_turn);
			cards[cards_size - 1].color = color;
		Global.CardType.WILDFOUR:
			payload += 4 * cards_size;
			new_turn(current_turn);
			cards[cards_size - 1].color = color;
		Global.CardType.SKIP:
			if players.size() == 2:
				new_turn(current_turn, 0);
			else:
				new_turn(current_turn, cards_size + 1);
		Global.CardType.REVERSE:
			if players.size() == 2:
				new_turn(current_turn, 0, cards_size);
			else:
				new_turn(current_turn, 1, cards_size);
		Global.CardType.DRAWTWO:
			payload += 2 * cards_size;
			new_turn(current_turn);
		Global.CardType.NUMBER:
			new_turn(current_turn);

func draw_cards(amount: int) -> Array[Card]:
	var drawn_cards : Array[Card] = [];
	
	for i in amount:
		drawn_cards.append(draw_pile.pop_back());
		
	return drawn_cards;

	#player.statistics["total_held"] = max(player.statistics["total_held"], player.hand.size())

func _on_draw_pressed():
	pass;

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		Player.hand.append_array(draw_cards(5));
		table.update_hand();
