# skills/autoload-architecture/code/service_locator.gd
extends Node

## Service Locator Expert Pattern
## Registry gateway for decoupled system discovery and mocking.

var _services = {}

func register_service(id: String, provider: Node) -> void:
    # 1. Dynamic Registry
    _services[id] = provider
    print("Service Registered: ", id)

func get_service(id: String) -> Node:
    # 2. Access Guard
    if not _services.has(id):
        push_error("Service not found: ", id)
        return null
    return _services[id]

func unregister_service(id: String) -> void:
    _services.erase(id)

## WHY THIS WAY?
## Instead of calling 'AudioManager.play()', you call
## 'ServiceLocator.get_service("audio").play()'. This allows you
## to swap the 'AudioManager' for a 'MockAudioManager' during 
## testing without changing a single line of game code.
