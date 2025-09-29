extends Label

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = 5.0
	timer.timeout.connect(OnTimer_Timeout)
	hide()
	
	
	
func _process(delta: float) -> void:
	text = "Next Round starting in : %d seconds." % timer.time_left
	
func OnTimer_Timeout() -> void:
	set_process(true)
	hide()


@rpc("call_local")
func wait(waitTime) -> void:
	timer.start(waitTime)
	set_process(true)
	show()
