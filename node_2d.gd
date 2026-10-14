extends Node

var replacehttp: HTTPRequest
var searchhttp: HTTPRequest
var delreqshttp: HTTPRequest
var updatelisthttp: HTTPRequest
var getcontenthttp: HTTPRequest

var processing : bool = false
var curproc : Array[HTTPRequest] = []

# Generate an OAuth token at https://github.com/settings/tokens
const OAUTH_TOKEN: String = "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"

var srinf :Dictionary = {
	"repo_owner": "lopkauna", # https://github.com/<this>/RepoName
	"repo_name": "brnrecp", # https://github.com/UserName/<this>
	"target_file": "dish53.txt", # What file to edit
	"commit_message": "Data changes ", # Commit message
	"new_file_content": "SGVsbG8sIFdvcmxkIQ==", # What to put in the file (MUST BE ENCODED IN BASE64)
	"new_file_content_sha": "", # Only required when editing an existing file
	"commit_on_branch": "master" # Very new repos might use "main" as the default branch
}

func _ready() -> void:
	
	replacehttp = HTTPRequest.new()
	add_child(replacehttp)
	replacehttp.download_chunk_size = 4096
	
	searchhttp = HTTPRequest.new()
	add_child(searchhttp)
	searchhttp.download_chunk_size = 4096
	
	delreqshttp = HTTPRequest.new()
	add_child(delreqshttp)
	delreqshttp.download_chunk_size = 4096
	
	updatelisthttp= HTTPRequest.new()
	add_child(updatelisthttp)
	updatelisthttp.download_chunk_size = 4096
	
	getcontenthttp= HTTPRequest.new()
	add_child(getcontenthttp)
	getcontenthttp.download_chunk_size = 4096
	
	replacehttp.request_completed.connect(_response_replace)
	searchhttp.request_completed.connect(_response_find)
	updatelisthttp.request_completed.connect(_response_update)
	getcontenthttp.request_completed.connect(_response_content)
	$FileDialog2.popup()
	#get_allprojzip()
	#delreqshttp.request_completed.connect(_response_delete)
	#http.connect("request_completed", self, "response")
	
	#create_or_update_file(
	#check_file(
	#	srinf
		#"lopkauna",
		#"brnrecp",
		#"dish5.txt",
		#"Godot QA test",
		#"SGVsbG8sIFdvcmxkIQ==" # I used https://base64.guru/converter/encode to convert "Hello, World!" into Base64
	#)

func _process(_delta: float) -> void:
	$CanvasLayer/Control/Label.visible = processing
	$CanvasLayer/Control/Label.text = "Загрузка..."
	if !curproc.is_empty():
		for curreq in curproc:
			if curreq.get_http_client_status() == 7:
				var percent = int(float(curreq.get_downloaded_bytes())*100/float(curreq.get_body_size())) 
				$CanvasLayer/Control/Label.text = "Загрузка " + str(percent) + "%"

func _response_content(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
	)-> void:
	processing = false
	curproc.clear()
	if response_code >= 200 and response_code < 300:
		print("content OK:  ")
		srinf["new_file_content"] = JSON.parse_string(body.get_string_from_utf8())["content"]
		if srinf["target_file"].ends_with(".txt"):
			$CanvasLayer/Control/HBoxContainer/TextEdit.text = Marshalls.base64_to_utf8(JSON.parse_string(body.get_string_from_utf8())["content"])
		else:
			var img = Image.new()
			img.load_png_from_buffer(Marshalls.base64_to_raw(JSON.parse_string(body.get_string_from_utf8())["content"]))
			$CanvasLayer/TextureRect.texture = ImageTexture.create_from_image(img)
	else:
			print("ERROR (", response_code, "): ", result)

func _response_update(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
	)-> void:
		processing = false
		curproc.clear()
		$CanvasLayer/TextureRect.texture = null
		$CanvasLayer/Control/HBoxContainer/TextEdit.text = ""
		$CanvasLayer/Control/HBoxContainer/VBoxContainer/LineEdit.text = ""
		for chld in $CanvasLayer/Control/HBoxContainer/VBoxContainer2.get_children():
			chld.queue_free()
		
		if response_code >= 200 and response_code < 300:
			var save_file = FileAccess.open("user://savedata.zip", FileAccess.WRITE)
			save_file.store_line(updatelisthttp.download_file)
			print("find OK:  ")
			$MainMenu/MarginContainer/Label.text = str("find OK:  ", save_file.get_path_absolute())
			
			extract_all_from_zip("user://main.zip")
			#ZIPPacker
			#ZIPReader
			#print(body.get_string_from_utf8())
			
			#for itr in JSON.parse_string(body.get_string_from_utf8()).size():
				##print(JSON.parse_string(body.get_string_from_utf8())[itr].keys())
				#var btn = Button.new()
				##print(JSON.parse_string(body.get_string_from_utf8())[itr])
				#btn.connect("pressed",_btnmpressed.bind(JSON.parse_string(body.get_string_from_utf8())[itr]["name"]))
				#btn.text = JSON.parse_string(body.get_string_from_utf8())[itr]["name"]
				#$CanvasLayer/Control/HBoxContainer/VBoxContainer2.add_child(btn)
				##if srinf["target_file"] == JSON.parse_string(body.get_string_from_utf8())[itr]["name"]:
				##	srinf["new_file_content_sha"] = JSON.parse_string(body.get_string_from_utf8())[itr]["sha"]
			##create_or_update_file(srinf)
				##if JSON.parse_string(body.get_string_from_utf8())[itr].has("content"):
				##	print(JSON.parse_string(body.get_string_from_utf8())[itr]["content"]["name"])
		
		else:
			$MainMenu/MarginContainer/Label.text = str("ERROR (", response_code, "): ", result)
			print("ERROR (", response_code, "): ", result)

func _btnmpressed(nm:String):
	if processing:
		return
	$CanvasLayer/Control/HBoxContainer/VBoxContainer/LineEdit.text = nm
	srinf["target_file"] = nm
	getcontenthttp.request("https://api.github.com/repos/lopkauna/brnrecp/contents/"+nm)
	processing = true
	curproc.append(getcontenthttp)

func _response_find(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
	)-> void:
		processing = false
		curproc.clear()
		if response_code >= 200 and response_code < 300:
			print("find OK:  ")
			for itr in JSON.parse_string(body.get_string_from_utf8()).size():
				#print(JSON.parse_string(body.get_string_from_utf8())[itr].keys())
				if srinf["target_file"] == JSON.parse_string(body.get_string_from_utf8())[itr]["name"]:
					srinf["new_file_content_sha"] = JSON.parse_string(body.get_string_from_utf8())[itr]["sha"]
			
			create_or_update_file(srinf)
				#if JSON.parse_string(body.get_string_from_utf8())[itr].has("content"):
				#	print(JSON.parse_string(body.get_string_from_utf8())[itr]["content"]["name"])
		else:
			print("ERROR (", response_code, "): ", result)

func check_file(arwf:Dictionary
	#repo_owner: String, # https://github.com/<this>/RepoName
	#repo_name: String, # https://github.com/UserName/<this>
	#target_file: String, # What file to edit
	#commit_message: String, # Commit message
	#new_file_content: String, # What to put in the file (MUST BE ENCODED IN BASE64)
	#new_file_content_sha: String = "", # Only required when editing an existing file
	#commit_on_branch: String = "master" # Very new repos might use "main" as the default branch
) -> void:
	var request_url := "https://api.github.com/repos/{owner}/{repo}/contents/{path}".format(
			{"owner": arwf["repo_owner"], "repo": arwf["repo_name"], "path": arwf["target_file"]})
	#print(request_url)
	var headers = PackedStringArray([
		#"authToken: " + OAUTH_TOKEN
		"Authorization: token " + OAUTH_TOKEN
	])
	searchhttp.request("https://api.github.com/repos/lopkauna/brnrecp/contents/")
	processing = true
	curproc.append(searchhttp)

func _response_replace(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	processing = false
	curproc.clear()
	if response_code >= 200 and response_code < 300:
		print("replace OK:  ")
		#print(JSON.parse_string(body.get_string_from_utf8()))
		#print("==================================================")
		#for nm in JSON.parse_string(body.get_string_from_utf8()):
			#if JSON.parse_string(body.get_string_from_utf8()).has("content"):
		print(JSON.parse_string(body.get_string_from_utf8()))
			#	print("==================================================")
		#print(JSON.parse_string(body.get_string_from_utf8()).keys())
		#for chls in JSON.parse_string(body.get_string_from_utf8()):
		#	print(JSON.parse_string(body.get_string_from_utf8())[chls])
		
	else:
		print("ERROR (", response_code, "): ", result)

func create_or_update_file(arwf:Dictionary
	#repo_owner: String, # https://github.com/<this>/RepoName
	#repo_name: String, # https://github.com/UserName/<this>
	#target_file: String, # What file to edit
	#commit_message: String, # Commit message
	#new_file_content: String, # What to put in the file (MUST BE ENCODED IN BASE64)
	#new_file_content_sha: String = "", # Only required when editing an existing file
	#commit_on_branch: String = "master" # Very new repos might use "main" as the default branch
) -> void:
	# PUT /repos/{owner}/{repo}/contents/{path}
	var request_url := "https://api.github.com/repos/{owner}/{repo}/contents/{path}".format(
			{"owner": arwf["repo_owner"], "repo": arwf["repo_name"], "path": arwf["target_file"]})
	print(request_url)
	var headers = PackedStringArray([
		#"authToken: " + OAUTH_TOKEN
		"Authorization: token " + OAUTH_TOKEN
	])
	var request_data := {
		"message": str(arwf["commit_message"]) + Time.get_date_string_from_system(false),
		"content": arwf["new_file_content"],
		"sha": arwf["new_file_content_sha"]
		#"branch": commit_on_branch
	}
	#curl -X PUT -H 'Authorization: token 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' -d '{"message": "Initial Commit","content": "SGVsbG8sIFdvcmxkIQ=="}' https://api.github.com/repos/lopkauna/brnrecp/contents/test-file2.txt
	print(request_data)
	replacehttp.request(request_url, headers, HTTPClient.METHOD_PUT, JSON.stringify(request_data))
	processing = true
	curproc.append(replacehttp)


func _on_line_edit_text_changed(new_text: String) -> void:
	srinf["target_file"] = new_text + ".txt"


func _on_text_edit_text_changed() -> void:
	srinf["new_file_content"] = Marshalls.utf8_to_base64($CanvasLayer/Control/HBoxContainer/TextEdit.text)


func _on_button_pressed() -> void:
	if processing:
		return
	var request_url := "https://api.github.com/repos/{owner}/{repo}/contents/{path}".format(
		{"owner": srinf["repo_owner"], "repo": srinf["repo_name"], "path": srinf["target_file"]})
	#print(request_url)
	var headers = PackedStringArray([
		#"authToken: " + OAUTH_TOKEN
		#"Accept: application/vnd.github.v3.raw",
		#"Accept: application/vnd.github.raw+json",
		"Accept: application/vnd.github.object+json",
		"Authorization: token " + OAUTH_TOKEN
	])
	#updatelisthttp.download_file = "prd.zip"
	#updatelisthttp.request("https://api.github.com/repos/lopkauna/brnrecp/contents/")
	updatelisthttp.download_file = "user://main.zip"
	updatelisthttp.request("https://github.com/lopkauna/brnrecp/archive/refs/heads/main.zip")
		#"https://api.github.com/repos/lopkauna/brnrecp/contents/",headers)
	processing = true
	curproc.append(updatelisthttp)

func get_allprojzip():
	updatelisthttp.download_file = "user://main.zip"
	updatelisthttp.request("https://github.com/lopkauna/brnrecp/archive/refs/heads/main.zip")
		#"https://api.github.com/repos/lopkauna/brnrecp/contents/",headers)
	processing = true
	curproc.append(updatelisthttp)


func _on_button_4_pressed() -> void:
	if processing:
		return
	$FileDialog.popup()


func _on_file_dialog_file_selected(path: String) -> void:
	#print(path)
	pass


func _on_file_dialog_files_selected(paths: PackedStringArray) -> void:
	if processing:
		return
	var img : Image = Image.load_from_file(paths[0])
	#img.decompress()
	srinf["new_file_content"] = Marshalls.raw_to_base64(img.save_png_to_buffer())
	#print(Marshalls.raw_to_base64(img.save_jpg_to_buffer()))#Marshalls.utf8_to_base64(img.to_string()))
	srinf["target_file"] = "image1.png"
	check_file(srinf)
	#$TextureRect.texture = ImageTexture.create_from_image(img)
	#print(paths[0])


func _on_button_2_pressed() -> void:
	pass
	#$TextureRect.texture = ImageTexture.create_from_image(img)


func extract_all_from_zip(archpath : String):
	var reader = ZIPReader.new()
	reader.open(archpath)
	var root_dir = DirAccess.open("user://")
	var files = reader.get_files()
	for file_path in files:
		print(file_path)
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
