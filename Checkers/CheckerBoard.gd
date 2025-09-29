extends TileMapLayer

signal player_won(winner)


@onready var black_team = $BlackTeam
@onready var white_team = $WhiteTeam
@onready var free_cell = $FreeCell

const DIRECTIONS_CELLS_KING = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]
const DIRECTIONS_CELLS_BLACK = [Vector2i(-1, -1), Vector2i(1, -1)]
const DIRECTIONS_CELLS_WHITE = [Vector2i(1, 1), Vector2i(-1, 1)]


enum Teams{BLACK,WHITE}

var current_turn = Teams.WHITE
var meta_board = {}
var selected_piece = null


func _ready() -> void:
	if multiplayer.get_peers().size() > 0:
		if is_multiplayer_authority():
			#rpc("setup_team", Teams.BLACK, multiplayer.get_peers()[0])
			#rpc("setup_team", Teams.WHITE, multiplayer.get_peers()[1])
			pass


	create_meta_board()
	map_pieces(black_team)
	map_pieces(white_team)
		#rpc("Toggle_Turn")

@rpc("authority", "call_local")
func setup_team(team,peer)-> void:
	if team == Teams.BLACK:
		black_team.set_multiplayer_authority(peer)
	else:
		white_team.set_multiplayer_authority(peer)

func create_meta_board() -> void:
	var test: Vector2 = local_to_map(Vector2i(9,9))
	var p = get_node("BlackTeam/Piece10") as Node2D
	p.global_position = test
	print(test)
	for cell in get_used_cells():
		meta_board[cell]=null


func map_pieces(team):
	for piece in team.get_children():
		var piece_position = local_to_map(piece.position)
		meta_board[piece_position] = piece_position
		piece.selected.connect(_on_piece_selected.bind(piece))



func _on_piece_selected(piece) -> void:
	pass
