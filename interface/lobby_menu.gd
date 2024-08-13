class_name Lobby_Menu extends Control

@export_category('Player Info')
@export var player_info_container_scene:PackedScene = preload("res://interface/player_info_container.tscn")
@export var lobby_members_container:VBoxContainer

func _ready() -> void:
	_set_up_connections()
	
func _set_up_connections() -> void:
	MultiplayerInterface.lobby_members_updated.connect(_on_lobby_members_updated)
	
func _on_lobby_members_updated() -> void:
	_clear_lobby_members_container()
	
	var lobby_members_list:Dictionary = MultiplayerInterface.lobby_members.duplicate()
	
	for member in lobby_members_list:
		var player_info_container:Player_Info_Container = player_info_container_scene.instantiate() as Player_Info_Container
		player_info_container.name_label.text = lobby_members_list[member].name
		
		lobby_members_container.add_child(player_info_container)
		
func _clear_lobby_members_container() -> void:
	for child in lobby_members_container.get_children():
		child.queue_free()
