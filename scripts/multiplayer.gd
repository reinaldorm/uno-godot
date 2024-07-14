extends Node;

@export var menu : CanvasLayer;

var multiplayer_peer = ENetMultiplayerPeer.new();

const PORT = 9999;
const ADDRESS = "127.0.0.1";

func _on_menu_create_pressed():
	multiplayer_peer.create_server(PORT, 4);
	multiplayer.multiplayer_peer = multiplayer_peer;
	_debug_menu("Server");
	get_parent().join_session(true);

func _on_menu_join_pressed():
	multiplayer_peer.create_client(ADDRESS, PORT);
	multiplayer.multiplayer_peer = multiplayer_peer;
	_debug_menu("Client");
	get_parent().join_session();

func _debug_menu(type: String):
	menu.menu.visible = false;
	menu.user_type.text = type;
	menu.user_id.text = str(multiplayer_peer.get_unique_id());
