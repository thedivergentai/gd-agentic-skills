# complex_signal_sequencer.gd
# Managing multi-step async sequences using signals
extends Node

func run_intro():
	# Chain of awaits for a clean linear flow
	await $Fade.fade_out()
	await get_tree().process_frame # Ensure UI is updated
	
	$LevelLoader.load_map("Level1")
	await $LevelLoader.finished
	
	await $Fade.fade_in()
	$Player.enable()
