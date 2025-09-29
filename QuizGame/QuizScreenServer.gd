extends Control


#Get access to the database file
@export_file("*.json") var dbFile = "res://FakeDatabase.json"
@export var turnDelayInSeconds = 5.0


@onready var db = JSON.parse_string((FileAccess.open(dbFile,FileAccess.READ).get_as_text()))
@onready var quiz_panel: ColorRect = $QuizPanel
@onready var timer: Timer = $Timer
@onready var wait_label: Label = $WaitLabel

var playersScore = {}

func _ready() -> void:
	timer.wait_time = 3.0
	timer.timeout.connect(OnTimerTimeOut)
	
	GenerateNewQuestions()
	await(timer.timeout)

func _process(delta: float) -> void:
	wait_label.text = "Round starting in %d seconds " % timer.time_left
	
	
@rpc("any_peer")
func DoesThisWork() -> void:
	#print("Does this work called from " + str(multiplayer.get_remote_sender_id()))
	quiz_panel.rpc("AllPlayersWrong", "All Players Missed")
	timer.start(turnDelayInSeconds)
	wait_label.rpc("wait", turnDelayInSeconds)
	
@rpc("any_peer", "call_remote")
func Missed(playerName) -> void:
	quiz_panel.rpc("PlayerMissed", db[playerName]["name"])
	quiz_panel.rpc_id(multiplayer.get_remote_sender_id(),"LockAnswers")
	#timer.start(turnDelayInSeconds)
	#wait_label.rpc("wait", turnDelayInSeconds)	

@rpc("any_peer")
func Answered(user) -> void:
	var userName = db[user]["name"]
	var currentUserScore
	var winner: bool = false
	quiz_panel.rpc("UpdateWinner", userName)
	#here is where we can make a call to the Quiz Panel to update the score
	#get players current score
	if playersScore.has(userName):
		#Get current score
		currentUserScore = playersScore[userName]
		currentUserScore+=1
		#Check for a winner -- 1st player to 10
		if currentUserScore >= 10:
			quiz_panel.rpc("UpdatePlayerScore", playersScore)
			quiz_panel.rpc("Winner", userName)
			timer.stop()
			winner = true
		playersScore.set(userName, currentUserScore)
	else:
		#Add player to the list
		playersScore.set(userName, 1)
	if not winner:
		quiz_panel.rpc("UpdatePlayerScore", playersScore)
		timer.start(turnDelayInSeconds)
		wait_label.rpc("wait", turnDelayInSeconds)
	else:
		#restart the game
		#show some button to restart
		playersScore.clear()
		pass
	
@rpc("any_peer")
func RestartGame() -> void:
	#Call back to the quiz panel and trigger restart game
	quiz_panel.rpc("ClearPlayerScoreBoard")
	timer.start(turnDelayInSeconds)
	wait_label.rpc("wait", turnDelayInSeconds)
	pass

func OnTimerTimeOut() -> void:
	GenerateNewQuestions()

func GenerateNewQuestions() -> void:
	var max_index = quiz_panel.available_questions.size()-1
	var question_index = randi_range(0, max_index) #this should pull a question from 0 to 3
	#call the quiz panel on all the clients
	quiz_panel.rpc("UpdateQuestion", question_index)
	#call the quiz panel on there server
	quiz_panel.UpdateQuestion(question_index)
