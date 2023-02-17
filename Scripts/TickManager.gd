extends Node

signal tick(speed)
signal make_action
signal queue_action

var action_queue:Array
var remove_actions_from_queue:Array
var current_tick:int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("queue_action")
	connect("tick", self, "_on_Tick")

#func _on_Queue_action(action):
#	action_queue.append(action)
#
func queue(action):
	action_queue.append(action)
		
func _on_Tick(speed):
	print("tick" if current_tick % 2 == 0 else "tock")
	var tick_counter = 0
	var action_times_sum = speed
	while (action_times_sum >= 0 and not action_queue.empty()):
		for i in range(action_queue.size()):
			var action = action_queue[i]
			print(action)
			action.time -= 1
			if (action.time == 0):
				action.target.act()
				remove_actions_from_queue.append(i)
		for i in range(remove_actions_from_queue.size()):
			action_queue.pop_at(remove_actions_from_queue[i]-i)
		remove_actions_from_queue = []
		emit_signal("queue_action")
		tick_counter += 1
		action_times_sum -= 1
	current_tick += tick_counter
	
