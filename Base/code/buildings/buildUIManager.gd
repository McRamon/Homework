extends CanvasLayer

signal confirmed
signal cancelled

@onready var dialog: ConfirmationDialog = $ConfirmDialog

func show_confirm_dialog(text: String):
	dialog.dialog_text = text
	dialog.popup_centered()

func _ready():
	# Подключаем сигналы от ConfirmDialog
	dialog.confirmed.connect(_on_ConfirmDialog_confirmed)
	dialog.canceled.connect(_on_ConfirmDialog_canceled)

func _on_ConfirmDialog_confirmed():
	print("🔔 Сигнал confirmed отправлен")
	emit_signal("confirmed")

func _on_ConfirmDialog_canceled():
	print("🔔 Сигнал cancelled отправлен")
	emit_signal("cancelled")
