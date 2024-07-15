extends Node2D;
class_name Adversary;

var player : Player;
var was_turn : bool = false;

var tween_scale : Tween;

func update_turn():
	if player.is_turn:
		was_turn = true;
		
		if tween_scale and tween_scale.is_running(): tween_scale.kill();
		
		tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
		tween_scale.tween_property(self, "scale", Vector2.ONE * 1.25, 1);
		tween_scale.finished.connect(play_turn);
	else:
		if was_turn:
			if tween_scale and tween_scale.is_running(): tween_scale.kill();
			
			tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC);
			tween_scale.tween_property(self, "scale", Vector2.ONE, 0.4);
			was_turn = false;

func play_turn():
	if not player.is_bot: return;

func set_adversary(p: Player):
	%Username.text = %Username.text.format({ "text": p.username });
	player = p;
	show();

func _ready():
	scale = Vector2.ZERO;
	hide();
	
func _process(delta):
	pass;
