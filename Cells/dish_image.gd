extends TextureRect

var curname = "img.png"
@onready var accept: Button = $MarginContainer/Button/Window/VBoxContainer/HBoxContainer/Accept

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	#$MarginContainer/Button/ConfirmationDialog.popup()
	$MarginContainer/Button/Window.popup()


func _on_confirmation_dialog_confirmed() -> void:
	self.queue_free()

func _remove_image(imgnm : String) -> void:
	var photosdir = DirAccess.open("user://alldishes/"+str($"../../../../../../../../..".curdish["dishid"])+"res/photos")
	if photosdir == null:
		return
	photosdir.remove(imgnm)
	#$"../../../../../../../../..".curdish["dishimages"].remove_at(int(imgnm.right(-4)))
	for pht in photosdir.get_files().size():
		photosdir.rename(photosdir.get_files()[pht],str(str(pht)+".png"))
	$"../../../../../../../../..".curdish["dishimages"].assign(photosdir.get_files())
	$"../../.."._load_existing_photos()

func _on_accept_pressed() -> void:
	_remove_image(curname)
	#self.queue_free()
	


func _on_decline_pressed() -> void:
	$MarginContainer/Button/Window.hide()
