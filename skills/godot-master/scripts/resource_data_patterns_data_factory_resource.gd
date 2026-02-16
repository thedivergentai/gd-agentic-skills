# godot-master/scripts/resource_data_patterns_data_factory_resource.gd
@tool
extends Resource
class_name DataFactoryResource

## Resource Data Expert Pattern
## Implements Static Factory methods and Inspector validation.

@export var item_id: String = "ITEM_000":
    set(value):
        item_id = value
        # 1. Data Validation Scripts
        # Expert logic: Enforce naming conventions in the inspector.
        if not item_id.begins_with("ITEM_"):
            push_warning("Item ID should start with 'ITEM_' for project consistency.")

@export var base_value: int = 10:
    set(value):
        base_value = clampi(value, 0, 9999) # Enforce non-negative

# 2. Static Factory Methods
# Professional pattern: Ensure consistent initialization project-wide.
static func create_item(id: String, val: int) -> DataFactoryResource:
    var new_item = DataFactoryResource.new()
    new_item.item_id = id
    new_item.base_value = val
    return new_item

# 3. Recursive Resource Flattening
# Pattern for deep cloning complex nested data.
func clone() -> DataFactoryResource:
    var new_clone = self.duplicate(true)
    # Perform additional deep-initialization if needed
    return new_clone

## EXPERT NOTE:
## Use 'Custom Inspector Plugins': Create an 'EditorInspectorPlugin' 
## to add 'Preview' buttons directly to this Resource in the inspector.
## NEVER modify shared Resources at runtime without calling '.duplicate()'. 
## Modification of a shared .tres file in one scene will affect ALL 
## other scenes using that same file, leading to 'Ghost Bugs'.
## Use 'ResourceSaver' to persist modified resources to binary .res 
## files for 3-5x faster loading than .tres text format.
