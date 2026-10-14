extends HBoxContainer
const DISH_IMAGE = preload("uid://cilpmb0b12mix")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_os_permissions() -> bool:
	if OS.get_name() == "Android":
		var already_granted = OS.request_permission("android.permission.READ_MEDIA_IMAGES")
		if already_granted:
			return true
	else:
		return true
	return false

func _on_button_pressed() -> void:
	#var perms_ok = await get_os_permissions()
	#if perms_ok:
	$FileDialog.popup()

func _load_existing_photos() -> void:
	for chld in $ScrollContainer2/Photos.get_children():
		chld.queue_free()
	var dir = DirAccess.open("user://")
	dir.make_dir_recursive("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos")
	var photosdir = DirAccess.open("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos")
	for pht in photosdir.get_files():
		var txtrect = DISH_IMAGE.instantiate()
		txtrect.curname = pht#find_child("Accept").pressed.connect(_remove_image.bind(pht))#.accept.pressed.connect(_remove_image.bind(pht))
		var loaddpng = Image.new()
		var txtimg = ImageTexture.create_from_image(loaddpng.load_from_file("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos/"+pht))
		txtrect.set_texture(txtimg)
		$ScrollContainer2/Photos.add_child(txtrect)
#ConfirmationDialog

func _remove_image(imgnm : String) -> void:
	var photosdir = DirAccess.open("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos")
	photosdir.remove(imgnm)
	$"../../../../../..".curdish["dishimages"].remove_at(int(imgnm.right(-4)))
	for pht in photosdir.get_files().size():
		photosdir.rename(photosdir.get_files()[pht],str(str(pht)+".png"))
	

func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	for pth in paths:
		var image_bytes: PackedByteArray = FileAccess.get_file_as_bytes(pth)
		#print(image_bytes)
		var txtrect = DISH_IMAGE.instantiate()
		var img = Image.new()
		Engine.print_error_messages = false
		var error = img.load_jpg_from_buffer(image_bytes)
		if error != OK:
			error = img.load_png_from_buffer(image_bytes)
		Engine.print_error_messages = true
		if Gvar.debug == true:
			$"../../TextEdit".visible = true
			$"../../TextEdit".text += str(pth.get_extension()) + "\n"
			$"../../TextEdit".text += str(pth) + "\n"
			$"../../TextEdit".text += str(error) + "\n"
		#if pth.get_extension() == "png":
			#error = img.load_png_from_buffer(image_bytes)
		#else:
			#error = img.load_jpg_from_buffer(image_bytes)
		#var error = img.load_jpg_from_buffer(image_bytes)
		#print(error)
		#var texture = ImageTexture.create_from_image(error)
		#var img : Image = Image.load_from_file(pth)
		
		if error == OK:
			var dir = DirAccess.open("user://")
			dir.make_dir_recursive("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos")
			var photosdir = DirAccess.open("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos")
			var imgname = "img.png"
			if $"../../../../../..".curdish.has("dishimages"):
				imgname = str($"../../../../../..".curdish["dishimages"].size())+".png"
				$"../../../../../..".curdish["dishimages"].append(imgname)
			else:
				imgname = "0.png"
				$"../../../../../..".curdish["dishimages"] = [imgname]
			var err = img.save_png("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos/"+imgname)
			#print(err)
			var savedpng = Image.new()
			#print(imgname)
			var txtimg = ImageTexture.create_from_image(savedpng.load_from_file("user://alldishes/"+str($"../../../../../..".curdish["dishid"])+"res/photos/"+imgname))
			txtrect.set_texture(txtimg)
			txtrect.curname = imgname
			$ScrollContainer2/Photos.add_child(txtrect)
			if Gvar.debug == true:
				$"../../TextEdit".text += str(txtimg) + "\n"
		
