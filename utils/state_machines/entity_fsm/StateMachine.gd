extends Node2D
class_name EntityFSM

var states: Dictionary = {}
var active_state: EntityState
var previous_state_tag: String = ""
var entity: KinematicBody2D

func init_states() -> void:
	for state in get_children():
		if state.tag:
			states[state.tag] = state
		else:
			states[state.name.to_lower()] = state
			
func init(ent: KinematicBody2D) -> void:
	entity = ent
	init_states()
	print(states)
	active_state = states.idle
	active_state.enter(entity)
	
func run() -> void:
	var next_state_tag = active_state.run(entity)
	if next_state_tag:
		change_state(next_state_tag)
		
func change_state(next_state_tag: String) -> void:
	var next_state = states[next_state_tag]
	if next_state:
		entity.previous_states.append(active_state.tag)
		active_state.exit(entity)
		active_state = next_state
		active_state.enter(entity)
		
