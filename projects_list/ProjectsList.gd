extends Control

const PATH = "user://saved_projects.json"

var projects_list = []
var project_selected


signal change_scene(project_name, path)

func _ready() -> void:
	load_data()
#	var icon = load("res://love_icon.png")
#	for project in projects_list:
#		if project != null:
#			$HSplitContainer/Panel/ItemList.add_item(project["project_name"] + " (Location: " + project["project_path"] + ")", icon)


func save_data():
	var f = File.new()
	f.open(PATH, File.WRITE)
	f.store_line(to_json(projects_list))
	f.close()
	
	
func load_data():
	var f = File.new()
	if not f.file_exists(PATH):
		save_data()
		return
	
	projects_list.empty()
	f.open(PATH, File.READ)
	projects_list = parse_json(f.get_as_text())
	f.close()
	
	var dir = Directory.new()
	for i in range(projects_list.size(), 0, -1):
		if not dir.dir_exists(projects_list[i-1]["path"]):
			projects_list.remove(i-1)
	
	save_data()
	
	
	var icon = load("res://love_icon.png")
	for project in projects_list:
		$HSplitContainer/Panel/ItemList.add_item(project["project_name"] + "(Location: " + project["path"] + ")", icon)
	
	

# Create new project
func _on_NewProjectButton_pressed() -> void:
	$AcceptDialog.popup()
	

func _on_ChoosePathButton_pressed() -> void:
	$NewProjectDialog.popup_centered()
	

func _on_NewProjectDialog_dir_selected(dir: String) -> void:
	$AcceptDialog/GridContainer/Path.text = dir
	if not check_blank_folder(dir):
		$AcceptDialog/VBoxContainer/Warning3.show()
	else:
		$AcceptDialog/VBoxContainer/Warning3.hide()


func _on_CreateProjectButton_pressed() -> void:
	if $AcceptDialog/GridContainer/ProjectName.text == "":
		$AcceptDialog/VBoxContainer/Warning1.show()
	else:
		$AcceptDialog/VBoxContainer/Warning1.hide()
		
	if $AcceptDialog/GridContainer/Path.text == "":
		$AcceptDialog/VBoxContainer/Warning2.show()
	else:
		$AcceptDialog/VBoxContainer/Warning2.hide()
		add_project($AcceptDialog/GridContainer/ProjectName.text, $AcceptDialog/GridContainer/Path.text)
		$AcceptDialog.hide()
#		$AcceptDialog/VBoxContainer/Warning3.hide()


func check_blank_folder(path):
	print(path)
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		if file_name != "":
			print(file_name)
			return false
			
		return true
	else:
		print("Cannot open the folder")
				

func add_project(project_name, path):
#	$HSplitContainer/Panel/ItemList.clear()
	var logo = load("res://love_icon.png")
	projects_list.append({
		"project_name" : project_name,
		"path" : path
	})
	save_data()
	$HSplitContainer/Panel/ItemList.add_item(project_name + " (Location: " + path + ")", logo)
	


# Open existing project
func _on_OpenProjectButton_pressed() -> void:
	$OpenProjectWindow.popup()


func _on_OpenProject_ChoosePathButton_pressed() -> void:
	$OpenProjectDialog.popup()


func _on_OpenProjectDialog_file_selected(path: String) -> void:
	$OpenProjectWindow/GridContainer/Path.text = path.get_base_dir()
	$OpenProjectWindow/VBoxContainer/Warning3.hide()


func _on_Confirm_OpenProjectButton_pressed() -> void:
	if $OpenProjectWindow/GridContainer/ProjectName.text == "":
		$OpenProjectWindow/VBoxContainer/Warning1.show()
	else:
		$OpenProjectWindow/VBoxContainer/Warning1.hide()
		
	if $OpenProjectWindow/GridContainer/Path.text == "":
		$OpenProjectWindow/VBoxContainer/Warning2.show()
	else:
		$OpenProjectWindow/VBoxContainer/Warning2.hide()
		add_project($OpenProjectWindow/GridContainer/ProjectName.text, $OpenProjectWindow/GridContainer/Path.text)
		$OpenProjectWindow.hide()


# Delete project
func _on_ItemList_item_selected(index: int) -> void:
	$HSplitContainer/ColorRect/VBoxContainer/DeleteProjectButton.disabled = false
	project_selected = index
	Global.project_path = projects_list[project_selected]["path"]


func _on_ItemList_nothing_selected() -> void:
	$HSplitContainer/ColorRect/VBoxContainer/DeleteProjectButton.disabled = true
	$HSplitContainer/Panel/ItemList.unselect_all()


func _on_DeleteProjectButton_pressed() -> void:
	$DeleteConfirmationDialog.popup()
	$DeleteConfirmationDialog.dialog_text = "Are you sure you want to delete " + projects_list[project_selected]["project_name"]
	

func _on_DeleteConfirmationDialog_confirmed() -> void:
	projects_list.remove(project_selected)
	save_data()
	$HSplitContainer/Panel/ItemList.clear()
	load_data()
	


# Open up a project, open code editor
func _on_ItemList_item_activated(index: int) -> void:
	emit_signal("change_scene", projects_list[project_selected]["project_name"], projects_list[project_selected]["path"])



