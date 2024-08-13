class_name Multiplayer_Interface extends Node

signal player_info_updated()
signal lobby_list_updated(lobby_list:Dictionary)
signal lobby_members_updated()

const APP_ID:int = 480 

var lobby_id:int = 0
var lobby_name:String = ''
var lobby_members:Dictionary = {}

var peer:SteamMultiplayerPeer = SteamMultiplayerPeer.new()

var steam_user_id:int = 0
var steam_username:String = '':
	set = _set_steam_username
var steam_avatar:ImageTexture:
	set = _set_steam_avatar

func _ready() -> void:
	_set_up_connections()
	
	_initialize_steam()

func _initialize_steam() -> void:
	var steam_init_response:Dictionary = Steam.steamInitEx(false, APP_ID, true)
	
	if steam_init_response['status'] != Steam.STEAM_API_INIT_RESULT_OK:
		print('Error on initializing Steam Network. Error number: %s' % steam_init_response['status'])
		return
	
	print('Successfully initialized Steam Network.')
	
	_update_player_info()
	
func _update_player_info() -> void:
	steam_username = Steam.getPersonaName()
	steam_user_id = Steam.getSteamID()
	
	Steam.getPlayerAvatar()
	
func _set_up_connections() -> void:
	# Peer Signals
	peer.lobby_joined.connect(_on_lobby_joined)
	peer.lobby_created.connect(_on_lobby_created)
	
	# Callback Signals
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	
func create_lobby_as_host(_lobby_name:String) -> void:
	lobby_name = _lobby_name
	_initialize_steam_lobby()	
	
# If Host	
func _initialize_steam_lobby() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)

func _on_lobby_created(_connect:int, _lobby_id:int) -> void:
	if _connect != 1:
		print("Couldn't create lobby")
		return
	
	multiplayer.multiplayer_peer = peer
		
	lobby_id = _lobby_id
	
	Steam.setLobbyData(lobby_id, 'name', lobby_name)
		
	print('%s Lobby created with ID %s.' % [lobby_name, lobby_id])

# If Client
func join_lobby_as_client(_lobby_id:int) -> void:
	_join_steam_lobby(_lobby_id)
	
func _join_steam_lobby(_lobby_id:int) -> void:
	peer.connect_lobby(_lobby_id)
	
func _on_lobby_joined(_lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		return
		
	multiplayer.multiplayer_peer = peer
	
	lobby_id = _lobby_id
	lobby_name = Steam.getLobbyData(lobby_id, 'name')

	print('Succesfully joined lobby %s' % lobby_name)

func _on_avatar_loaded(avatar_id: int, size: int, data: Array) -> void:
	var avatar_image:Image = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, data)

	if size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	
	steam_avatar = avatar_texture

func _set_steam_username(value:String) -> void:
	steam_username = value
	player_info_updated.emit()

func _set_steam_avatar(value:ImageTexture) -> void:
	steam_avatar = value
	player_info_updated.emit()

func refresh_lobby_list(string_filter:String = '') -> void:
	if string_filter != '':
		Steam.addRequestLobbyListStringFilter('name', string_filter,Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies:Array) -> void:
	if lobbies.is_empty() or !lobbies:
		return

	var lobby_list:Dictionary = {}
	for lobby in lobbies:
		var _lobby_name:String = Steam.getLobbyData(lobby, 'name')
		var _lobby_num_members:int = Steam.getNumLobbyMembers(lobby)
		
		lobby_list[lobby] = {'name':_lobby_name, 'num_members':_lobby_num_members}
		
	lobby_list_updated.emit(lobby_list)
	
func _on_lobby_chat_update(_lobby_id: int, changer_id: int, making_change_id: int, chat_state: int) -> void:
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		_update_lobby_members()
	
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		_update_lobby_members()

func _update_lobby_members() -> void:
	lobby_members.clear()
	if lobby_id == 0:
		return
		
	var num_of_members:int = Steam.getNumLobbyMembers(lobby_id)
	
	for member in range(0, num_of_members):
		var member_steam_id:int = Steam.getLobbyMemberByIndex(lobby_id, member)
		var member_steam_name:String = Steam.getFriendPersonaName(member_steam_id)
		
		lobby_members[member_steam_id] = {'name':member_steam_name}
