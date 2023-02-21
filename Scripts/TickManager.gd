extends Node

signal tick(speed)
signal make_action
signal queue_action
signal update_log

var action_queue:Array
var remove_actions_from_queue:Array
var current_tick:int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("queue_action")
	connect("tick", self, "_on_Tick")

func queue(action):
	action_queue.append(action)
	
func _on_Tick(speed, player):
	print("TICK" if current_tick % 2 == 0 else "TOCK")
	var tick_counter = 0
	var action_times_sum = speed
	while (action_times_sum >= 0 and not action_queue.empty()):
		yield(get_tree().create_timer(0.2), "timeout")
		for i in range(action_queue.size()):
			var action = action_queue[i]
			action.time -= 1
			if (action.time <= 0):
				if is_instance_valid(action.target):
					if !action.target.is_queued_for_deletion():
						action.target.act()
				remove_actions_from_queue.append(i)
				
		for i in range(remove_actions_from_queue.size()):
			action_queue.pop_at(remove_actions_from_queue[i]-i)
		remove_actions_from_queue = []
		emit_signal("queue_action")
		tick_counter += 1
		action_times_sum -= 1
	current_tick += tick_counter
	player.tick_completed()

func send_log_entry(name, action, result = ""):
	var default_string = "[color=red][b]%s[/b][/color] [color=green]%s[/color] [color=blue]%s[/color]\n" % [name, action, result]
	emit_signal("update_log", default_string)
