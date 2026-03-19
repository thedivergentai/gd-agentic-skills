# character_select_grid.gd
extends GridContainer
class_name CharacterSelectGrid

# Gamepad UI Navigation Flow
# Programmatically sets focus neighbors for seamless D-pad navigation.

func setup_focus_routing() -> void:
    var buttons := get_children()
    # Assume 2 columns for this example.
    for i in buttons.size():
        var btn := buttons[i] as Control
        btn.focus_mode = Control.FOCUS_ALL
        
        # Route left/right.
        if i % 2 == 0 and i + 1 < buttons.size():
            btn.set_focus_neighbor(SIDE_RIGHT, buttons[i + 1].get_path())
        elif i % 2 != 0:
            btn.set_focus_neighbor(SIDE_LEFT, buttons[i - 1].get_path())
            
        # Route up/down.
        if i >= 2:
            btn.set_focus_neighbor(SIDE_TOP, buttons[i - 2].get_path())
        if i + 2 < buttons.size():
            btn.set_focus_neighbor(SIDE_BOTTOM, buttons[i + 2].get_path())
            
    if not buttons.is_empty():
        (buttons[0] as Control).grab_focus()
