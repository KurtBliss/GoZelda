class_name StateHelper #Devzze: 6-14-22
extends Node 
 
#"""
#usage example:
#
#onready var state_helper = $StateHelper
#
#func _process(delta): 
#	state_helper.process(self, delta) 
#func _physics_process(delta): 
#	state_helper.phy_process(self, delta) 
#func process_init(_delta):
#	state_helper.reset("idle")
#
#func process_idle(_delta):
#	pass
#
#func physics_idle(_delta):
#	pass
#"""
 
# Default state will just had the process_init function
@export var states = ["init"]
 
# This will be added to the state's prefix when set
@export var prefix = "process_"
@export var phy_prefix = "physics_"
 
#   Functions to call all processes for the state
#
# Call processes of state
func process(helpfor = self, delta = 0):
	for state in states:
		var call_method = prefix + state
		if helpfor.has_method(call_method):
			helpfor.call(call_method, delta)
 
# Call physic processes of state
func phy_process(helpfor, delta = 0):
	for state in states:
		var call_method = phy_prefix + state
		if helpfor.has_method(call_method):
			helpfor.call(call_method, delta)
 
#   Use these functions to change the state!
#
# Remove all processes from state
func reset(state = []):
	if state is Array:
		states = state
	else:
		states = [state]
 
# Add new process to state
func add(process_state):
	if process_state is Array:
		for process_i in process_state:
			add(process_i)
	else:
		if states.has(process_state):
			return
		states.append(process_state)
 
# Remove process from state
func remove(process_state):
	if process_state is Array:
		for process_i in process_state:
			remove(process_i)
	else:
		var f = states.find(process_state)
		if f == -1: return
		states.remove(f)
 
func has(process_state):
	return states.has(process_state)

