extends Control
@onready var quiz_panel: ColorRect = $QuizPanel


func _ready() -> void:
	quiz_panel.answered.connect(_on_quiz_panel_answered)
	quiz_panel.AllPlayersMissed.connect(AllPlayersMissed)
	quiz_panel.RestartGame.connect(RestartGameSignal)
	
func _on_quiz_panel_answered(is_answer_correct):
	#print("answered called" + str(is_answer_correct))
	if is_answer_correct:
		rpc_id(multiplayer.get_remote_sender_id(),
			#get_multiplayer_authority(),
				"Answered",
				AuthNetCredentials.user
			)
	else:
		rpc_id(multiplayer.get_remote_sender_id(),
			#get_multiplayer_authority(),
				"Missed",
				AuthNetCredentials.user
			)

func RestartGameSignal() -> void:
	rpc("RestartGame")
	
func AllPlayersMissed() -> void:
	rpc("DoesThisWork")
	
@rpc
func RestartGame() -> void:
	pass

@rpc
func Answered(user):
	pass


@rpc
func Missed(user):
	pass

@rpc
func DoesThisWork() -> void:
	pass
