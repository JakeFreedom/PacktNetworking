extends TileMapLayer

signal player_won(winner)


@onready var black_team = $BlackTeam
@onready var white_team = $WhiteTeam
@export  var free_cell: PackedScene
@onready var free_cell_container = $FreeCells
const DIRECTIONS_CELLS_KING = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]
#const DIRECTIONS_CELLS_BLACK = [Vector2i(-20,-13), Vector2i(-10,-13)]
const DIRECTIONS_CELLS_BLACK = [Vector2i(-5,-5), Vector2i(5,-5)]
const DIRECTIONS_CELLS_WHITE = [Vector2i(5, 5), Vector2i(-5, 5)]


enum Teams{BLACK,WHITE}

var current_turn = Teams.BLACK
var meta_board = {}
var selected_piece = null


func _ready() -> void:
	if multiplayer.get_peers().size() > 0:
		if is_multiplayer_authority():
			#rpc("setup_team", Teams.BLACK, multiplayer.get_peers()[0])
			#rpc("setup_team", Teams.WHITE, multiplayer.get_peers()[1])
	
			pass

	disable_pieces()

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
	#var test: Vector2 = map_to_local(Vector2i(2,2))
	#print(test)
	#var p = get_node("BlackTeam/Piece10") as Node2D
	#p.position = test #position is relative to the board in pixel.. This example is finding 2,2 from the origin of the tilemap layer and converting that to pixel
	#Don't use global position as that will use the entire screen
	for cell in get_used_cells():
		meta_board[cell]=null

	


func map_pieces(team):
	#var index: int = 1
	for piece in team.get_children():
		var piece_position = local_to_map(piece.position)
		#print(team.name + "::"+ str(piece.name) +" "+ str(piece_position))
		meta_board[piece_position] = piece
		piece.selected.connect(_on_piece_selected.bind(piece))
		piece.SetPositionLable(piece_position)
		piece.deselected.connect(_on_PieceDeselected)
		
		
func _on_PieceDeselected()-> void:
	clear_free_cells()

func _on_piece_selected(piece: Node2D) -> void:
	#print(piece.name + str(local_to_map(piece.position)))
	if selected_piece == null:
		selected_piece = piece
		SelectPiece(piece)
	else:
		selected_piece.OnDeselected()
		selected_piece = piece
		SelectPiece(piece)


func SelectPiece(piece: Node2D)->void:
	clear_free_cells()
	selected_piece = piece
	#var selected_piece_cell = local_to_map(selected_piece.position)
	var available_cells = SearchAvailableCells(selected_piece)
	for cell in available_cells:
		AddFreeCell(cell)
	pass


func SearchAvailableCells(piece: Node2D)-> Array:
	var available_cells = []
	var directions = GetPieceDirections(piece)
	var currentCell = local_to_map(piece.position)
	var capturing = CanCapture(piece)

	
	for direction in directions:
		var cell = currentCell+direction
		#here is the logic to determine if this is a legal move or not
		#we need to check to see if the space is on the board
		#need to check to see if there is a piece on the cell(either our own or other player)
		if IsOnBoard(cell):
			if IsFreeCell(cell):
				#is it us
				if IsOurPiece(cell):
					print("our piece was detected")
					continue
				else:
					print("out piece was not detected")

				if IsOpponent(cell):
					print("opponent detected")
					var capturingCell = cell + direction
					if IsFreeCell(capturingCell):
						print("capturing free cell")
						available_cells.append(capturingCell)
			else:
				if IsOpponent(cell):
					print("opponent found")
					var capturingCell = cell + direction
					if IsFreeCell(capturingCell):
						print("capturing free cell")
						capturing = true
						available_cells.append(capturingCell)
					else:
						continue
				if IsOurPiece(cell):
					continue

				#available_cells.append(cell)
				

		if not capturing:
			print("not capturing")
			available_cells.append(cell)


		# for space in available_cells:
		# 	var freeCell =  free_cell.instantiate()
		# 	freeCell.position = map_to_local(space)
		# 	free_cell_container.add_child(freeCell)
		# 	if cell in meta_board:
		# 		#meta_board[cell] = null
		# 		print(available_cells.size())


		capturing = false
	return available_cells

func AddFreeCell(cell:Vector2i) -> void:
	#print("Add Free Cell")
	var freeCell = free_cell.instantiate()
	freeCell.Selected.connect(FreeCellSelected)
	freeCell.position = map_to_local(cell)
	free_cell_container.add_child(freeCell)

	#print(meta_board[cell])


func FreeCellSelected(positionq: Vector2)-> void:
	selected_piece.process_mode = Node.PROCESS_MODE_DISABLED
	selected_piece.OnDeselected()
	clear_free_cells()
	disable_pieces()
	# if current_turn == Teams.BLACK:
	# 	selected_piece.position.x = positionq#.x + 480
	# 	selected_piece.position.y = positionq#.y + 250
	# 	#map_to_local(Vector2(position.x+0, position.y+0))
	# else:
	UpdateCells(local_to_map(selected_piece.position), positionq)
	selected_piece.SetPositionLable(local_to_map(positionq))
	selected_piece.position = positionq



	#this will need to be an rpc call but for now its local
	toggle_local_turn()

func GetPieceDirections(piece: Node2D)-> Array:
	var directions = []

	if piece.team == Teams.BLACK:
		directions = DIRECTIONS_CELLS_BLACK
	else:
		directions = DIRECTIONS_CELLS_WHITE

	if piece.is_king:
		directions = DIRECTIONS_CELLS_KING

	return directions


func toggle_local_turn() -> void:
	print("toggle fucking turn"+str(current_turn))
	if current_turn == Teams.BLACK:
		current_turn = Teams.WHITE
		enable_pieces(white_team)
	else:
		current_turn = Teams.BLACK
		enable_pieces(black_team)

@rpc("any_peer", "call_local")	
func UpdateCells(previousCell, targetCell)-> void:
	meta_board[local_to_map(targetCell)] = meta_board[previousCell]
	meta_board[previousCell] = null
	print(meta_board)



#RPC Methods
@rpc("any_peer", "call_local")
func toggle_turn() -> void:
	clear_free_cells()
	var winner = get_winner()
	if winner:
		player_won.emit(get_winner())
		return
	if current_turn == Teams.BLACK:#swap turns
		current_turn = Teams.WHITE
		if not multiplayer.get_peers().size() > 0:
			enable_pieces(white_team)
		elif white_team.get_multiplayer_authority() == multiplayer.get_unique_id():
			enable_pieces(white_team)
	else:
		current_turn = Teams.BLACK
		if not multiplayer.get_peers().size()>0:
			enable_pieces(black_team)
		elif black_team.get_multiplayer_authority() == multiplayer.get_unique_id():
			enable_pieces((black_team))


func get_winner() -> Teams:
	#disable_pieces()
	#disable_pieces()
	var winner = null
	if black_team.get_children().size() < 1:
		winner = "White"
	elif white_team.get_children().size() < 1:
		winner = "Black"
	
	return winner



func clear_free_cells() -> void:
	for child in free_cell_container.get_children():
		child.queue_free()

func IsOnBoard(piece:Vector2i)-> bool:
	#print("Is on Board" + str(piece))
	return piece in meta_board
	# if piece in meta_board:
	# 	return true
	# else:
	# 	return false

func IsOpponent(piece: Vector2i) -> bool:
	print(current_turn)

	if meta_board[piece] != null:
		print(meta_board[piece].team)
		if meta_board[piece].team != current_turn:
			return true

	return false

func IsFreeCell(piece: Vector2i)-> bool:
	if not IsOnBoard(piece):
		return false

	return meta_board[piece] == null

func IsOurPiece(piece: Vector2i) -> bool:
	if not meta_board[piece] == null:
		return meta_board[piece].team == current_turn

	return false

func CanCapture(piece: Node2D) -> bool:
	var directions = GetPieceDirections(piece)
	var capturing = false
	var cell_content
	for direction in directions:
		var current_cell = local_to_map(piece.position)
		var neighbor_cell = current_cell + direction

		#print(current_cell)
		print(neighbor_cell)
		if not IsOnBoard(neighbor_cell):
			print("Cell is on the board")
			continue
		
		if IsFreeCell(neighbor_cell):
			print("It is a free cell")
			continue
		
		cell_content = meta_board[neighbor_cell]
		
		if not IsOpponent(neighbor_cell):
			print("Its not an opponent")
			continue
		
		var capturing_cell = neighbor_cell + direction
		if not IsOnBoard(capturing_cell):
			print("Capturing cell is on the board")
			continue
		
		cell_content = meta_board[capturing_cell]
		
		if IsFreeCell(capturing_cell):
			capturing = true

	print("Capturing" + str(capturing))
	return capturing
	
#we will finish this when we are closer to actually having turns to lock the other player out
func enable_pieces(_team: Node2D) -> void:
	for piece in _team.get_children():
		piece.process_mode = Node.PROCESS_MODE_ALWAYS


#not sure this is need, we can just call get_tree().process = false or what ever it is.
func disable_pieces() -> void:
	if current_turn == Teams.WHITE:
		for piece in black_team.get_children():
			piece.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		for piece in white_team.get_children():
			piece.process_mode = Node.PROCESS_MODE_DISABLED
	
	pass
