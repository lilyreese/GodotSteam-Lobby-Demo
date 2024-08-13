class_name Lobby_Interface extends CanvasLayer

@export_group('Menus')
@export var connection_menu:Connection_Menu
@export var lobby_menu:Lobby_Menu

# Called when the node enters the scene tree for the first time.
func _ready():
	connection_menu.show()
	lobby_menu.hide()


