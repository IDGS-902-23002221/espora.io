extends Area3D

signal consumido

# Multiplicador de crecimiento; el dorado usa MULT_NUTRIENTE_DORADO.
var multiplicador_crecimiento: float = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("consumir_nutriente"):
		body.consumir_nutriente(multiplicador_crecimiento)
		consumido.emit()
		queue_free()
