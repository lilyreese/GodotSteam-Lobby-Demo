class_name Lobby_Menu extends Control

@export_category('Player Info')
@export var player_info_container_scene:PackedScene
@export var lobby_members_container:VBoxContainer

@export_category('Lobby Info')
@export var lobby_name_label:Label

@export_category('Buttons')
@export var disconnect_button:Button
@export var send_button:Button
@export var message_line:LineEdit
@export var chat_box_label:Label

func _ready() -> void:
	_set_up_connections()
	
func _set_up_connections() -> void:
	#Interface Connections
	disconnect_button.pressed.connect(_on_disconnect_button_pressed)
	send_button.pressed.connect(_on_send_button_pressed)
	#Multiplayer Callbacks
	MultiplayerInterface.lobby_members_updated.connect(_on_lobby_members_updated)
	MultiplayerInterface.lobby_connected.connect(_on_lobby_connected)
	MultiplayerInterface.lobby_member_avatar_received.connect(_on_lobby_member_avatar_received)
	
	MultiplayerInterface.chat_message_received.connect(_on_chat_message_received)
	
func _on_lobby_members_updated() -> void:
	_update_lobby_members()

func _update_lobby_members() -> void:
	_clear_lobby_members_container()
	
	var lobby_members_list:Dictionary = MultiplayerInterface.lobby_members.duplicate()

	for member in lobby_members_list:
		var player_info_container:Player_Info_Container = player_info_container_scene.instantiate() as Player_Info_Container
		player_info_container.name_label.text = str(lobby_members_list[member].name, ' - ', lobby_members_list[member].peer_id)
		player_info_container.steam_id = member
		if member == MultiplayerInterface.steam_user_id:
			player_info_container.avatar_texture.texture = MultiplayerInterface.steam_avatar
			
		lobby_members_container.add_child(player_info_container)		
		
func _clear_lobby_members_container() -> void:
	for child in lobby_members_container.get_children():
		child.queue_free()

func _on_lobby_connected() -> void:
	lobby_name_label.text = MultiplayerInterface.lobby_name
	_update_lobby_members()
	
func _on_lobby_disconnected() -> void:
	_update_lobby_members()
	
func _on_lobby_member_avatar_received(_steam_id:int, avatar_texture:ImageTexture) -> void:
	_update_player_avatar(_steam_id, avatar_texture)
	
func _update_player_avatar(_steam_id:int, avatar_texture:ImageTexture) -> void:
	for player_info:Player_Info_Container in lobby_members_container.get_children():
		if player_info.steam_id == _steam_id:
			player_info.avatar_texture.texture = avatar_texture

func _on_disconnect_button_pressed() -> void:
	MultiplayerInterface.disconnect_from_lobby()

func _on_send_button_pressed() -> void:
	MultiplayerInterface.send_client_server_chat_message(message_line.text)

func _on_chat_message_received(player_name:String, message:String) -> void:
	chat_box_label.text = str(chat_box_label.text, '\n', player_name, ': ', message)
