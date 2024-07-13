extends Node

var id : String;
var is_turn = false;
var is_host = false;

var hand : Array[Card] = [];
var selected_cards: Array[Card] = [];
var legal_cards: Array[Card] = [];

func set_player(new_hand: Array[Card], is_first: bool = false) -> void:
	hand = new_hand;
	is_turn = is_first;
