extends Node
class_name FEAGI_RunTime_SequencePlayerManager
## Handles all sequence players, allows for easy calling of them.

signal sequence_autostarted(sequence_name: StringName)
signal sequence_finished(sequence_name: StringName)

## Sets up all sequences as child nodes. This function assumes this node is parented
func FEAGI_setup(sequences: Dictionary) -> void:
	for sequence_name in sequences:
		var sequence_player: FEAGI_RunTime_Sequenceplayer = FEAGI_RunTime_Sequenceplayer.new()
		var sequence: FEAGI_EmuPredefinedInputSequence = sequences.get(sequence_name)
		if !sequence:
			push_error("FEAGI: Unable to read sequence %s!" % sequence_name)
			continue
		
		sequence_player.name = sequence_name
		add_child(sequence_player)
		sequence_player.setup(sequence_name, sequence) # NOTE: if a sequence is autoplaying, this will set off its own timer before it starts playing
		sequence_player.started_playing_automatically.connect(func(seq_name: StringName): sequence_autostarted.emit(seq_name))
		sequence_player.done_playing.connect(func(seq_name: StringName): sequence_finished.emit(seq_name))


## Plays a given saved sequence by name
func play_sequence(sequence_name: StringName) -> Error:
	for child in get_children():
		if child.name != sequence_name:
			continue
		if child is not FEAGI_RunTime_Sequenceplayer:
			#?
			continue
		if (child as FEAGI_RunTime_Sequenceplayer).is_playing:
			push_error("FEAGI: Unable to play sequence %s as its already playing!" % sequence_name)
			return Error.ERR_ALREADY_IN_USE
		(child as FEAGI_RunTime_Sequenceplayer).play()
		return Error.OK
	push_error("FEAGI: Unable to find sequence of name %s!" % sequence_name)
	return Error.ERR_DOES_NOT_EXIST
