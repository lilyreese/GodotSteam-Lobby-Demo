class_name Connection_Menu extends Control

@export_category('Player Info')
@export var player_info_container:Player_Info_Container

@export_category('Connection Buttons')

@export var lobby_name_line_edit:LineEdit
@export var host_button:Button
@export var join_button:Button

@export_category('Lobby List')
@export var refresh_lobby_list_button:Button
@export var server_list_container:VBoxContainer
@export var lobby_search_line_edit:LineEdit

func _ready() -> void:
	_set_up_connections()
	MultiplayerInterface.player_info_updated.connect(_on_player_info_updated)
	_update_player_username()
	_update_player_avatar()
	
func _set_up_connections() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	refresh_lobby_list_button.pressed.connect(_on_refresh_lobby_list_button_pressed)
	
	MultiplayerInterface.lobby_list_updated.connect(_on_lobby_list_updated)

func _on_player_info_updated() -> void:
	_update_player_username()
	_update_player_avatar()
	
func _update_player_username() -> void:
	player_info_container.name_label.text = MultiplayerInterface.steam_username

func _update_player_avatar() -> void:
	player_info_container.avatar_texture.texture = MultiplayerInterface.steam_avatar

func _on_host_button_pressed() -> void:
	var lobby_name:String = lobby_name_line_edit.text
	if lobby_name.is_empty():
		print("Empty lobby name")
		return
	MultiplayerInterface.create_lobby_as_host(lobby_name)
	
func _on_join_button_pressed() -> void:
	pass

func _on_refresh_lobby_list_button_pressed() -> void:
	MultiplayerInterface.refresh_lobby_list(lobby_search_line_edit.text)
	
func _on_lobby_list_updated(lobby_list:Dictionary) -> void:
	_clear_lobby_list()
	for lobby in lobby_list:
		var lobby_button: Button = Button.new()
		lobby_button.text = '%s - %s Players' % [lobby_list[lobby].name, lobby_list[lobby].num_members]
		
		lobby_button.pressed.connect(MultiplayerInterface.join_lobby_as_client.bind(lobby))
		
		server_list_container.add_child(lobby_button)

func _clear_lobby_list() -> void:
	for child in server_list_container.get_children():
		child.queue_free()
