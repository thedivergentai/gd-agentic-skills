class_name MobileIAPFlowBoilerplate
extends Node

## Expert boilerplate for In-App Purchases (IAP).
## Abstracts GooglePlayBilling and AppleInAppStore functionality.

var _payment: Object = null

func _ready() -> void:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		_payment = Engine.get_singleton("GodotGooglePlayBilling")
		_payment.startConnection()
	elif Engine.has_singleton("InAppStore"):
		_payment = Engine.get_singleton("InAppStore")

func purchase_product(product_id: String) -> void:
	if not _payment:
		push_error("MobileIAP: No payment singleton found.")
		return
	
	# Platform specific purchase logic...
	if _payment.has_method("purchase"):
		_payment.purchase({"product_id": product_id})

## Expert: Always perform server-side receipt validation for production games.
