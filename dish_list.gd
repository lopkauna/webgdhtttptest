extends CanvasLayer
var curcatid : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for catg in Gvar.allcats:
		$MarginContainer/VBoxContainer/HBoxContainer/MenuButton.add_item(catg)
	for delchld in $MarginContainer/VBoxContainer/ScrollContainer/DishList.get_children():
		delchld.queue_free()
	for dish in Gvar.alldishes:
		if dish.has("dishname"):
			if curcatid != 0 and curcatid != dish["dishcategory"]:
				continue
			var btn = Button.new()
			btn.text = dish["dishname"][0]
			$MarginContainer/VBoxContainer/ScrollContainer/DishList.add_child(btn)
			btn.pressed.connect(_seldish.bind(dish))


func _on_button_pressed() -> void:
	$".".visible = false
	$"../MainMenu".visible = true


func _on_button_2_pressed() -> void:
	for dshchk in Gvar.alldishes.size():
		if Gvar.alldishes[dshchk].is_empty():
			$"../DishCard".curdish.assign($"../DishCard".cleardish)
			$"../DishCard".curdish["dishid"] = dshchk
			break
		if dshchk+1 == Gvar.alldishes.size():
			$"../DishCard".curdish.assign($"../DishCard".cleardish)
			$"../DishCard".curdish["dishid"] = dshchk+1
			Gvar.alldishes.resize(dshchk+1)
			break
	$".".visible = false
	$"../DishCard".visible = true

func _seldish(ndish : Dictionary):
	$"../DishCard".curdish.assign(ndish)
	$".".visible = false
	$"../DishCard".visible = true

func _on_visibility_changed() -> void:
	if visible:
		$MarginContainer/VBoxContainer/HBoxContainer/MenuButton.clear()
		#$MarginContainer/VBoxContainer/HBoxContainer/MenuButton.add_item("Выбрать категорию")
		for catg in Gvar.allcats:
			$MarginContainer/VBoxContainer/HBoxContainer/MenuButton.add_item(catg)
		for delchld in $MarginContainer/VBoxContainer/ScrollContainer/DishList.get_children():
			delchld.queue_free()
		for dish in Gvar.alldishes:
			if dish.has("dishname"):
				if curcatid != 0 and curcatid != dish["dishcategory"]:
					continue
				var btn = Button.new()
				btn.text = dish["dishname"][0]
				if dish["dishname"].size() == 1:
					if dish["dishname"][0] == "":
						btn.text = "Без названия"
				$MarginContainer/VBoxContainer/ScrollContainer/DishList.add_child(btn)
				btn.pressed.connect(_seldish.bind(dish))
		var btnn = Button.new()
		btnn.text = "Добавить Новое блюдо"
		btnn.pressed.connect(_on_button_2_pressed)
		$MarginContainer/VBoxContainer/ScrollContainer/DishList.add_child(btnn)
