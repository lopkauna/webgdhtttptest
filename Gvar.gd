extends Node

var debug : bool = false
#allcategories.txt
var allcats : Array[String] = [
	"Без категории",
	"Завтрак",
	"Первое",
	"Горячее",
	"Закуски",
	"Стритфуд",
	"Пицца",
	"Салаты",
	"Холодные закуски",
	"Блюда на компанию",
	"Соусы",
	"Десерты",
	"Магазин",
	"Азия"
]
#dishid dir

#alldishes.txt
var alldishes : Array[Dictionary]# = [
#	{"did" = dishinfo["dishid"],"dn" = dishinfo["dishname"][0],"dc" = dishinfo["dishcategory"]}
#]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_alldishes()
	#var ndish : Dictionary = {
	#"dishid" = 1,
	#"dishname" = ["Курица","Ципленок","Куряка"],
	#"dishcategory" = 1,
	#"dishtbl" = ["","","",""]
	#}
	#_add_dish(ndish)
	#ndish = {
	#"dishid" = 18,
	#"dishname" = ["Мороженное"],
	#"dishcategory" = 0
	#}
	#_add_dish(ndish)
	#pass # Replace with function body.

func _load_alldishes() -> void:
	if FileAccess.file_exists("user://alldishes.txt"):
		var alldishfile = FileAccess.open("user://alldishes.txt", FileAccess.READ)
		alldishes.assign(str_to_var(alldishfile.get_as_text()))
	if FileAccess.file_exists("user://allcats.txt"):
		var allcatsfile = FileAccess.open("user://allcats.txt", FileAccess.READ)
		allcats.assign(str_to_var(allcatsfile.get_as_text()))


func _add_dish(ndish : Dictionary) -> void:#dishid : int,dishname : Array[String],Dishcat : int,) -> void:
	var dir = DirAccess.open("user://")
	dir.make_dir_recursive("user://alldishes/"+str(ndish["dishid"])+"res/photos")
	var dishfile = FileAccess.open("user://alldishes/"+str(ndish["dishid"])+"res/"+str(ndish["dishid"])+".txt", FileAccess.WRITE)
	var alldishsfile = FileAccess.open("user://alldishes.txt", FileAccess.WRITE)
	var alldishscatsfile = FileAccess.open("user://allcats.txt", FileAccess.WRITE)
	var dishinfo : Dictionary = {
		"dishid" = ndish["dishid"],
		"dishname" = ndish["dishname"],
		"dishcategory" = ndish["dishcategory"]
	}
	#dishinfo.assign(ndish)
	if alldishes.size()<ndish["dishid"]+1:
		alldishes.resize(ndish["dishid"]+1)
	alldishes[ndish["dishid"]] = dishinfo
	dishfile.store_string(str(ndish))
	alldishsfile.store_string(str(alldishes))
	alldishscatsfile.store_string(str(allcats))

func _remove_dish(dishid) -> void:
	if not alldishes.size()<dishid+1:
		alldishes[dishid] = {}
	var photosdir = DirAccess.open("user://alldishes/"+str(dishid)+"res/photos")
	var dishdir = DirAccess.open("user://alldishes/"+str(dishid)+"res/")
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://alldishes/"+str(dishid)+"res/"):
		return
	if not dishdir.dir_exists("photos"):
		return
	for photo in photosdir.get_files():
		photosdir.remove(photo)
	dishdir.remove("user://alldishes/"+str(dishid)+"res/photos")
	dishdir.remove("user://alldishes/"+str(dishid)+"res/"+str(dishid)+".txt")
	dir.remove("user://alldishes/"+str(dishid)+"res/")
