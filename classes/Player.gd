extends Node
class_name Player;

var id : String;
var username: String = "Default";
var is_turn = false;
var is_host = false;
var is_bot = false;

var hand : Array[Card] = [];
var selected_cards: Array[Card] = [];
var legal_cards: Array[Card] = [];

func set_player(new_hand: Array[Card], is_first: bool = false) -> void:
	hand = new_hand;
	is_turn = is_first;

func get_legal_cards(discard_pile: Array[Card]) -> void:
	var next_legal_cards: Array[Card] = []
	var last_card = Global.discard_pile[Global.discard_pile.size() - 1]

	if selected_cards.size() > 0:
		var all_cards_but_selected = hand.filter(func(card):
			return not selected_cards.has(card)
		)

		for card in all_cards_but_selected:
			if Global.payload:
				if card.type == Global.CardType.WILDFOUR:
					if card.type == selected_cards[0].type:
						next_legal_cards.append(card)
				elif card.type == Global.CardType.DRAWTWO:
					if last_card.type == Global.CardType.WILDFOUR:
						if card.color == selected_cards[0].color:
							next_legal_cards.append(card)
					else:
						next_legal_cards.append(card)
			else:
				if card.type != Global.CardType.NUMBER:
					if card.type == selected_cards[0].type:
						next_legal_cards.append(card)
				else:
					if card.number == selected_cards[0].number:
						next_legal_cards.append(card)
	else:
		if Global.payload:
			for card in hand:
				if card.type == Global.CardType.WILDFOUR:
					next_legal_cards.append(card)
				elif card.type == Global.CardType.DRAWTWO:
					if last_card.type == Global.CardType.WILDFOUR:
						if card.color == last_card.color:
							next_legal_cards.append(card)
					else:
						if card.type == last_card.type:
							next_legal_cards.append(card)
		else:
			for card in hand:
				if card.type == Global.CardType.WILD or card.type == Global.CardType.WILDFOUR:
					next_legal_cards.append(card)
				elif card.type != Global.CardType.NUMBER:
					if card.color == last_card.color:
						next_legal_cards.append(card)
					if card.type == last_card.type:
						next_legal_cards.append(card)
				else:
					if card.color == last_card.color:
						next_legal_cards.append(card)
					if card.number == last_card.number:
						next_legal_cards.append(card)

	legal_cards = next_legal_cards;
