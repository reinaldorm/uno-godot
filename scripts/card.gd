extends Node2D;
class_name Card;

signal card_entered;
signal card_exited;
signal card_down;
signal card_up;

@onready var sprite : Sprite2D = %Sprite2D;
@onready var button : Button = %Button;

var type : Game.CardType = Game.CardType.NULL;
var color : Game.CardColor = Game.CardColor.NULL;
var number : int = -1;

var texture_path : String = "";
var inactive : bool = false;

func set_number(c: Game.CardColor, n: int):
	type = Game.CardType.NUMBER;
	color = c;
	number = n;
	texture_path = "colored/numbered/{color}/{number}.png".format({ "color": color, "number": number });

func set_colored_special(t: Game.CardType, c: Game.CardColor):
	type = t;
	color = c;
	texture_path = "colored/special/{color}/{type}.png".format({ "color": color, "type": type });

func set_special(t: Game.CardType):
	type = t;
	texture_path = "exotic/{type}.png".format({ "type": type });

func set_inactive():
	z_index = 0;
	inactive = true;

func disable_button():
	button.disabled = true;

func _on_mouse_down():
	if not inactive: card_down.emit(self);

func _on_mouse_up():
	if not inactive: card_up.emit(self);

func _on_mouse_entered():
	if not inactive: card_entered.emit(self);

func _on_mouse_exited():
	if not inactive: card_exited.emit(self);

func _ready():
	sprite.texture = load("res://assets/cards/{path}".format({ "path": texture_path }));
