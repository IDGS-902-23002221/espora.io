extends Area3D

signal consumido

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("consumir_nutriente"):
		body.consumir_nutriente()
		consumido.emit()
		queue_free()
