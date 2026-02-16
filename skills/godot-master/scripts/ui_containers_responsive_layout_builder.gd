# godot-master/scripts/ui_containers_responsive_layout_builder.gd
extends Control

## UI Containers Expert Pattern
## Implements Dynamic SizeFlag Mastery and Programmatic Grid Building.

@onready var grid_container: GridContainer = $GridContainer

# 1. Programmatic Grid Building
func populate_shop_inventory(items: Array[Dictionary]) -> void:
    # Professional protocol: Clear existing children safely.
    for child in grid_container.get_children():
        child.queue_free()
        
    for item in items:
        var panel = _create_item_panel(item)
        grid_container.add_child(panel)

func _create_item_panel(data: Dictionary) -> PanelContainer:
    var panel = PanelContainer.new()
    
    # 2. Dynamic SizeFlag Mastery
    # Expert logic: Force the panel to fill available space in the grid.
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    panel.size_flags_vertical = SIZE_SHRINK_CENTER
    
    var label = Label.new()
    label.text = data.get("name", "Unknown Item")
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    
    panel.add_child(label)
    return panel

# 3. Layout-Recalculation Hooks
func force_refresh_layout() -> void:
    # Professional protocol: Explicitly trigger the container's sort 
    # if content changes size at runtime (e.g. after a text swap).
    var parent = grid_container.get_parent()
    if parent is Container:
        # Containers automatically sort, but some custom implementations 
        # need a manual nudge or frame wait.
        grid_container.queue_sort()

## EXPERT NOTE:
## Use 'Container-Safe Nesting': Wrap every GridContainer in a 
## 'MarginContainer' to ensure consistent padding without 
## calculating 'position' offsets manually.
## For 'ui-containers', use 'Aspect Ratio Scaling': Wrap important UI 
## elements in an 'AspectRatioContainer' (set to 16:9 or 1:1) to 
## prevent distortion on ultra-wide or vertical mobile displays.
## NEVER use 'position' or 'size' properties directly on children 
## of a Container; always use 'custom_minimum_size' and 'size_flags'. 
## Manual offsets are the #1 cause of broken UI on different resolutions.
