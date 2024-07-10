extends CanvasLayer

var points = 0

signal newRiotCreated
signal updatePoints(points)

func _on_generate_currency(value: int):
    set_points(points + value)
    updatePoints.emit(points)    

func _on_structure_purchased(cost: int, structure: String):
    set_points(points - cost)
    updatePoints.emit(points)
    if structure.to_lower() == "riot":
        newRiotCreated.emit()

func set_points(new_points: int):
    points = new_points
    for structure in $ResistanceMenu.get_children():
        if points < structure.current_cost:
            structure.disable_button()
        else:
            structure.enable_button()