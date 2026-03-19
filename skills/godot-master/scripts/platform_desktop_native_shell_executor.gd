class_name NativeShellExecutor
extends Node

## Expert native shell integration via OS.execute_with_pipe.
## Allows running CLI tools and capturing their output for editor integrations.

func run_shell_command(command: String, args: PackedStringArray) -> String:
	var output = []
	var err = OS.execute(command, args, output, true)
	if err == OK:
		return "".join(output)
	return "Error: " + str(err)

## Warning: Use caution with shell execution to avoid security vulnerabilities.
