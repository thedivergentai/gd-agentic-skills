class_name CompDependencyInjector
extends Node

## Expert Runtime Dependency Injection.
## Use when components are added dynamically and need references.

func inject(deps: Dictionary) -> void:
	for key in deps:
		if key in self:
			set(key, deps[key])

## Rule: Use injection to avoid 'get_node' or 'get_parent' inside dynamic components.
