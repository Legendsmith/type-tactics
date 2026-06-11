class_name GameInterface
extends Control
signal alert

enum Alert {
	NONE_ACTION
}

func show_alert(data:Dictionary):
	alert.emit(data)
