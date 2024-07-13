extends Node2D;
class_name Card;

signal card_entered;
signal card_exited;
signal card_down;
signal card_up;

@onready var sprite : Sprite2D = get_node("Sprite2D");
@onready var button : Button = get_node("Button");

var type : Global.CardType = Global.CardType.NULL;
var color : Global.CardColor = Global.CardColor.NULL;
var number : int = -1;

var texture_path : String = "";

func set_number(c: Global.CardColor, n: int):
	type = Global.CardType.NUMBER;
	color = c;
	number = n;
	texture_path = "colored/numbered/{color}/{number}.png".format({ "color": color, "number": number });

func set_colored_special(t: Global.CardType, c: Global.CardColor):
	type = t;
	color = c;
	texture_path = "colored/special/{color}/{type}.png".format({ "color": color, "type": type });

func set_special(t: Global.CardType):
	type = t;
	texture_path = "exotic/{type}.png".format({ "type": type });

func _on_mouse_down():
	card_down.emit(self);

func _on_mouse_up():
	card_up.emit(self);

func _on_mouse_entered():
	card_entered.emit(self);

func _on_mouse_exited():
	card_exited.emit(self);

func _ready():
	sprite.texture = load("res://assets/cards/{path}".format({ "path": texture_path }));
