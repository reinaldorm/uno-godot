extends Node
class_name Game;

enum CardType { NUMBER, SKIP, REVERSE, DRAWTWO, WILDFOUR, WILD, NULL };

enum CardColor { RED, GREEN, BLUE, YELLOW, NULL };

class Config:
	var hand_size : int;
	var deck_size : int;
	func _init(
			deck_size = 1,
			hand_size = 7) -> void:
		self.hand_size = hand_size;
		self.deck_size = deck_size;

class Rules:
	var off_play : bool;
	var forced_draw : bool;
	var strict_mode : bool;
	var rush : bool;
	var zero_bomb : bool;
	func _init(
			off_play = false,
			forced_draw = false,
			strict_mode = false,
			rush = false,
			zero_bomb = false) -> void:
		self.off_play = off_play;
		self.forced_draw = forced_draw;
		self.strict_mode = strict_mode;
		self.rush = rush;
		self.zero_bomb = zero_bomb;

var card_scene : PackedScene = load("res://card/card.tscn");

var draw_pile : Array[Card] = [];
var discard_pile : Array[Card] = [];

var ongoing = false;
var players : Array[Player] = [];
var current_player : Player : get = _get_current_player;
var current_turn = 0;
var direction = 1;
var payload = 0;

var winner : Player;
var config : Config;
var rules : Rules;

func set_game(host: Player, c: Config = Config.new(), r: Rules = Rules.new()):
	config = c;
	rules = r;
	
	add_player(host);

func start_game(deck: Array[Card]):
	ongoing = true;
	draw_pile = deck;
	for player in players:
		player.set_player(draw_cards(7), player.is_host)

func add_player(player: Player) -> void:
	if players.size() >= 4: return;
	players.append(player);

func draw_cards(amount: int):
	var drawn_cards : Array[Card] = [];
	
	for i in amount: drawn_cards.append(discard_pile.pop_back());
	
	return drawn_cards;

func _get_current_player():
	return players[current_turn];
