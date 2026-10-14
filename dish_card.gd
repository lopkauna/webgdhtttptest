extends CanvasLayer

const NUMBER_CELL = preload("uid://bge3serxcuc83")
const VALUE_CELL = preload("uid://b20pk56haj2uy")
const EXTERMINATE_CELL = preload("uid://ce5610rvnyhfg")


var cleardish : Dictionary = {
	"dishid" = 0,
	"dishname" = [""],
	"dishcategory" = 0,
	"dishtabl" = [],
	"dishrecept" = "",
	"dishimages" = []
}

var curdish : Dictionary = {
	"dishid" = 0,
	"dishname" = [""],
	"dishcategory" = 0,
	"dishtabl" = [],
	"dishrecept" = "",
	"dishimages" = []
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_add_assigned_row(cleardish["dishtabl"])
	if Gvar.debug == true:
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/TextEdit.visible = true
	else:
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/TextEdit.visible = false
	for catg in Gvar.allcats:
		$MarginContainer/VBoxContainer/HBoxContainer/DishCategory.add_item(catg)
	if FileAccess.file_exists("user://alldishes/"+str(curdish["dishid"])+"res/"+str(curdish["dishid"])+".txt"):
		var dishfile = FileAccess.open("user://alldishes/"+str(curdish["dishid"])+"res/"+str(curdish["dishid"])+".txt", FileAccess.READ)
		var dishinfo : Dictionary = {}
		dishinfo.assign(str_to_var(dishfile.get_as_text()))
		$MarginContainer/VBoxContainer/DishName.text = dishinfo["dishname"][0]
		$MarginContainer/VBoxContainer/HBoxContainer/DishCategory.select(dishinfo["dishcategory"])

func _on_button_pressed() -> void:
	var ndish : Dictionary = {
	}
	if curdish.has("dishid"):
		ndish["dishid"] = curdish["dishid"]
	else:
		for dshchk in Gvar.alldishes.size():
			if Gvar.alldishes[dshchk].is_empty():
				ndish["dishid"] = dshchk
				break
	if curdish.has("dishname"):
		ndish["dishname"] = curdish["dishname"]
		#if curdish["dishname"].size() == 1:
			#if curdish["dishname"][0] == "":
				#ndish["dishname"] = ["Без названия"]
	else:
		ndish["dishname"] = [""]
	if curdish.has("dishcategory"):
		ndish["dishcategory"] = curdish["dishcategory"]
	else:
		ndish["dishcategory"] = 0
	if curdish.has("dishtabl"):
		ndish["dishtabl"] = [""]
		ndish["dishtabl"].assign(curdish["dishtabl"])
	else:
		ndish["dishtabl"] = []
	if curdish.has("dishrecept"):
		ndish["dishrecept"] = curdish["dishrecept"]
	else:
		ndish["dishrecept"] = ""
	if curdish.has("dishimages"):
		ndish["dishimages"] = curdish["dishimages"]
	else:
		ndish["dishimages"] = []
	Gvar._add_dish(ndish)
	clearpage()
	$".".visible = false
	$"../DishList".visible = true

func clearpage():
	$MarginContainer/VBoxContainer/DishName.text = ""
	$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer2/DishRecepie.text = ""
	$MarginContainer/VBoxContainer/HBoxContainer/DishCategory.select(0)
	var grd = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer/VBoxContainer/GridContainer
	for chlcn in grd.get_child_count():
		if chlcn > 5:
			grd.get_child(chlcn).queue_free()
	var photos: HBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer2/MarginContainer/ScrollContainer2/Photos
	for chld in photos.get_children():
		chld.queue_free()
	

func tbdatachange(cellid:int,newdata):
	if curdish["dishtabl"].size() < cellid+1:
		curdish["dishtabl"].resize(cellid+1)
	curdish["dishtabl"][cellid] = str(newdata.get_child(0).get_child(0).text)

func _add_assigned_row(tbldata : Array) -> void:
	curdish["dishtabl"].clear()
	if tbldata.is_empty():
		return
	var grd = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer/VBoxContainer/GridContainer
	for cl in tbldata.size():
		if fmod(cl,4) == 0: #start of line add num
			var num = NUMBER_CELL.instantiate()
			#num.get_child(0).text = str(grd.get_child_count()/grd.columns-1)
			num.get_child(0).text = str(curdish["dishtabl"].size()/4+1)
			grd.add_child(num)
			var val1 = VALUE_CELL.instantiate()
			var val2 = VALUE_CELL.instantiate()
			var val3 = VALUE_CELL.instantiate()
			var val4 = VALUE_CELL.instantiate()
			var ext = EXTERMINATE_CELL.instantiate()
			var btn : Button = ext.get_child(0)
			btn.pressed.connect(_delete_row.bind([num,val1,val2,val3,val4,ext]))
			#ext.get_child(0).text = "X"
			if tbldata.size() < cl+4 :
				tbldata.resize(cl+4)
			grd.add_child(val1)
			val1.get_child(0).get_child(0).placeholder_text = "Укажите сырье"
			val1.get_child(0).get_child(0).text = tbldata[cl]
			val1.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl,val1))
			grd.add_child(val2)
			val2.get_child(0).get_child(0).text = tbldata[cl+1]
			val2.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl+1,val2))
			grd.add_child(val3)
			val3.get_child(0).get_child(0).text = tbldata[cl+2]
			val3.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl+2,val3))
			grd.add_child(val4)
			val4.get_child(0).get_child(0).text = tbldata[cl+3]
			val4.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl+3,val4))
			grd.add_child(ext)
	recalcrowsnum()

func _on_button_add_row_pressed() -> void:
	var num = NUMBER_CELL.instantiate()
	var grd = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer/VBoxContainer/GridContainer
	num.get_child(0).text = str(grd.get_child_count()/grd.columns)
	grd.add_child(num)
	var val1 = VALUE_CELL.instantiate()
	var val2 = VALUE_CELL.instantiate()
	var val3 = VALUE_CELL.instantiate()
	var val4 = VALUE_CELL.instantiate()
	var ext = EXTERMINATE_CELL.instantiate()
	var btn : Button = ext.get_child(0)
	btn.pressed.connect(_delete_row.bind([num,val1,val2,val3,val4,ext]))
	#ext.get_child(0).text = "X"
	grd.add_child(val1)
	val1.get_child(0).get_child(0).placeholder_text = "Укажите сырье"
	grd.add_child(val2)
	grd.add_child(val3)
	grd.add_child(val4)
	grd.add_child(ext)
	recalcrowsnum()

func _delete_row(nds):
	for nd in nds.size():
		nds[nd].queue_free()
	recalcrowsnum()

func recalcrowsnum():
	curdish["dishtabl"].clear()
	var grd = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer/VBoxContainer/GridContainer
	var diff = 0
	for chld in grd.get_children().size():
		if fmod(chld+1,6) == 0 and chld > 5:
			grd.get_children()[chld-5].get_child(0).text = str((chld/grd.columns)-diff)
			if grd.get_children()[chld-5].is_queued_for_deletion():
				diff += 1
				continue
			var cl = (chld-(2*((chld-diff)))/grd.columns)-4
			var val1 = grd.get_children()[chld-4]
			if curdish["dishtabl"].size() < cl:
				curdish["dishtabl"].resize(cl)
			curdish["dishtabl"][cl-4] = val1.get_child(0).get_child(0).text
			if val1.get_child(0).get_child(0).text_changed.is_connected(tbdatachange):
				val1.get_child(0).get_child(0).text_changed.disconnect(tbdatachange)
			val1.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl-4,val1))
			var val2 = grd.get_children()[chld-3]
			curdish["dishtabl"][cl-3] = val2.get_child(0).get_child(0).text
			if val2.get_child(0).get_child(0).text_changed.is_connected(tbdatachange):
				val2.get_child(0).get_child(0).text_changed.disconnect(tbdatachange)
			val2.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl-3,val2))
			var val3 = grd.get_children()[chld-2]
			curdish["dishtabl"][cl-2] = val3.get_child(0).get_child(0).text
			if val3.get_child(0).get_child(0).text_changed.is_connected(tbdatachange):
				val3.get_child(0).get_child(0).text_changed.disconnect(tbdatachange)
			val3.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl-2,val3))
			var val4 = grd.get_children()[chld-1]
			curdish["dishtabl"][cl-1] = val4.get_child(0).get_child(0).text
			if val4.get_child(0).get_child(0).text_changed.is_connected(tbdatachange):
				val4.get_child(0).get_child(0).text_changed.disconnect(tbdatachange)
			val4.get_child(0).get_child(0).text_changed.connect(tbdatachange.bind(cl-1,val4))

func _on_visibility_changed() -> void:
	if visible:
		clearpage()
		#$MarginContainer/VBoxContainer/DishName.text = curdish["dishname"][0]
		
		curdish["dishtabl"].assign(cleardish["dishtabl"])
		for catg in Gvar.allcats:
			$MarginContainer/VBoxContainer/HBoxContainer/DishCategory.add_item(catg)
		$MarginContainer/VBoxContainer/HBoxContainer/DishCategory.select(curdish["dishcategory"])
		if FileAccess.file_exists("user://alldishes/"+str(curdish["dishid"])+"res/"+str(curdish["dishid"])+".txt"):
			var dishfile = FileAccess.open("user://alldishes/"+str(curdish["dishid"])+"res/"+str(curdish["dishid"])+".txt", FileAccess.READ)
			var dishinfo : Dictionary = {}
			dishinfo.assign(str_to_var(dishfile.get_as_text()))
			$MarginContainer/VBoxContainer/DishName.text = dishinfo["dishname"][0]
			$MarginContainer/VBoxContainer/HBoxContainer/DishCategory.select(dishinfo["dishcategory"])
			$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer2/DishRecepie.text = dishinfo["dishrecept"]
			_add_assigned_row(dishinfo["dishtabl"])
			curdish["dishrecept"] = dishinfo["dishrecept"]
		var photosdir = DirAccess.open("user://alldishes/"+str(curdish["dishid"])+"res/photos")
		if photosdir != null:
			curdish["dishimages"].assign(photosdir.get_files())
		$MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/MarginContainer2/MarginContainer._load_existing_photos()
		


func _on_del_dish_button_pressed() -> void:
	Gvar._remove_dish(curdish["dishid"])
	$".".visible = false
	$"../DishList".visible = true


func _on_dish_recepie_text_changed() -> void:
	curdish["dishrecept"] = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DishInfo/DishIngridientsTable/MarginContainer2/DishRecepie.text


func _on_dish_name_text_changed() -> void:
	curdish["dishname"][0] = $MarginContainer/VBoxContainer/DishName.text


func _on_dish_category_item_selected(index: int) -> void:
	curdish["dishcategory"] = index
