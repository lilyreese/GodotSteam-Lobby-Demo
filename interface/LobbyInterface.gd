class_name Lobby_Interface extends CanvasLayer

@export_group('Menus')
@export var connection_menu:Connection_Menu
@export var lobby_menu:Lobby_Menu

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_up_connections()
	
	connection_menu.show()
	lobby_menu.hide()

func _set_up_connections() -> void:
	MultiplayerInterface.lobby_connected.connect(_on_lobby_connected)
	MultiplayerInterface.lobby_disconnected.connect(_on_lobby_disconnected)

func _on_lobby_connected() -> void:
	connection_menu.hide()
	lobby_menu.show()

func _on_lobby_disconnected() -> void:
	connection_menu.show()
	lobby_menu.hide()
