extends ColorRect

signal answered(is_correct)
signal AllPlayersMissed
signal RestartGame

#@export_file var questionsDB = AuthNetCredentials.questionDatabaseFile#"res://QuestionDB.json"

@onready var question_label: Label = $QuestionLabel
@onready var answers: Control = $Answers
@onready var player_message_label: Label = $PlayerMessageLabel
@onready var player_score_board: Label = $PlayerScoreBoard
@onready var restart: Button = $Restart


var available_questions = []
var questions = {}
var corret_answer = 0

var playerMissedQuestion: int = 0
var totalPlayers: PackedInt32Array
func _ready() -> void:
	
	var temp : String = "res://basic_addition_trivia_questions.json"
	var strFile: String = "res://" + AuthNetCredentials.getDBFILE()
	var file = FileAccess.open(temp, FileAccess.READ)
	#var file = FileAccess.open("res://harry_potter_trivia_questions.json", FileAccess.READ)
	
	var questionsAsText = file.get_as_text()
	player_message_label.text = ""
	questions = JSON.parse_string(questionsAsText)
	for question in questions:
		#Add this text to the button.
		available_questions.append(question)
		
	restart.visible = false
	restart.pressed.connect(RestartGamePressed)
	totalPlayers = multiplayer.get_peers()
	

	ConnectAnswerButtons()
	LockAnswers()
	
	
	
@rpc("authority", "call_remote")
func ClearPlayerScoreBoard() -> void:
	player_score_board.text = ""
	restart.visible = false
	
@rpc("call_local")
func AllPlayersWrong(message) -> void:
	player_message_label.text = message
	LockAnswers()
	pass
	
@rpc("call_local")
func UpdateWinner(playerName) -> void:	
	player_message_label.text = "%s won the round!!" % playerName
	playerMissedQuestion = 0
	LockAnswers()
	

@rpc("any_peer", "call_remote")
func PlayerMissed(playerName) -> void:
	player_message_label.text = "%s missed the question!!" % playerName	
	playerMissedQuestion+=1
	if playerMissedQuestion >= totalPlayers.size():
		playerMissedQuestion = 0
		AllPlayersMissed.emit()
		pass

@rpc("any_peer", "call_local")
func UpdateQuestion(questionIndex) -> void:
	#print("question INdex: " + str(questionIndex))
	var question = available_questions.pop_at(questionIndex)

	if not question == null:
		question_label.text = questions[question]['text']
		corret_answer = questions[question]['correct_answer_index']
		for i in range(0,4):
			var alt = questions[question]['alternatives'][i]
			answers.get_child(i).text = alt
		UnlockAnswers()
		#here is where we will hide the buttons for 5 seconds
		get_node("Answers").visible = false
		get_tree().create_timer(5).connect("timeout", Callable(func(): get_node("Answers").visible = true))
		
	else:
			for answer in answers.get_children():
				question_label.text = "No more quetions"
			LockAnswers()


@rpc("any_peer", "call_remote")
func LockAnswers() -> void:
	for answerButton in answers.get_children():
		answerButton.disabled = true


@rpc("authority","call_remote")
func UpdatePlayerScore(playerScores) -> void:
	#print("Update the players score")
	player_score_board.text = ""
	for key in playerScores:
		player_score_board.text += str(key) + "::" + str(playerScores[key])
		player_score_board.text += "\n"
		#print(str(key) + str(playerScores[key]))

@rpc("authority", "call_remote")
func Winner(userName) -> void:
	question_label.text = "%s has won the game!" % userName
	restart.visible = true
	
func UnlockAnswers() -> void:
	for answerButton in answers.get_children():
		answerButton.disabled = false
		player_message_label.text = ""

func ConnectAnswerButtons() -> void:
	for button in answers.get_children():
		button.pressed.connect(AnswerButton_Pressed.bind(button.get_index()))
	
func AnswerButton_Pressed(buttonIndex) -> void :
	EvaluateAnswer(buttonIndex)
	
func EvaluateAnswer(buttonIndex) -> void:
	#print("A button was pressed" + str(buttonIndex))
	var is_answer_correct = buttonIndex == corret_answer#This is the short had if statement similar to c#. Setting is_answer_correct to true or false, depending statement on the right hand side
	answered.emit(is_answer_correct)
	pass

func RestartGamePressed() -> void:
	RestartGame.emit()
	pass
