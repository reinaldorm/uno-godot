extends Node

enum AdversarySide { TOP, LEFT, RIGHT }
enum CardType { NUMBER, SKIP, REVERSE, DRAWTWO, WILDFOUR, WILD, NULL };
enum CardColor { RED, GREEN, BLUE, YELLOW, NULL };

var draw_pile : Array[Card] = [];
var discard_pile : Array[Card] = [];

var winner : Player;
var ongoing = false;
var players : Array[Player] = [];
var current_turn = 0;
var direction = 1;
var payload = 0;

var config = {
	"initial_hand": 7,
}

var rules = {
	"off_play": false,
	"forced_draw": false,
	"strict_mode": false,
	"rush": false,
	"zero_bomb": false,
};
