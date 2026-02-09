class_name AuthComponent extends Node

signal login_success(user_data: Dictionary)
signal login_failed(error_message: String)

func login(username: String, password: String) -> void:
    if username.is_empty() or password.is_empty():
        login_failed.emit("Username and password cannot be empty.")
        return
        
    # Simulate async network request
    await get_tree().create_timer(1.0).timeout
    
    if username == "admin" and password == "password":
        login_success.emit({"id": 1, "username": "admin", "role": "admin"})
    else:
        login_failed.emit("Invalid credentials.")

func logout() -> void:
    # Cleanup session
    pass
