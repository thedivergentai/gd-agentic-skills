class_name AndroidRuntimePermissions
extends Node

## Expert Android runtime permission handler.
## Correctly requests and checks for hardware permissions to avoid store rejections.

const STORAGE_PERMISSION = "android.permission.WRITE_EXTERNAL_STORAGE"
const CAMERA_PERMISSION = "android.permission.CAMERA"

func request_access_to_camera() -> void:
	if OS.get_name() != "Android": return
	
	if not OS.get_granted_permissions().has(CAMERA_PERMISSION):
		OS.request_permission(CAMERA_PERMISSION)
		_check_permission_status.call_deferred(CAMERA_PERMISSION)

func _check_permission_status(permission: String) -> void:
	if OS.get_granted_permissions().has(permission):
		print("Mobile: Permission granted: ", permission)
	else:
		print("Mobile: Permission denied: ", permission)
