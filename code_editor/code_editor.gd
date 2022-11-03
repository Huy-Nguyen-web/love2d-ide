extends Control

var app_name = "Simple Love2d IDE"
var current_file = "Untitled"
var current_file_path
var project_path = Global.project_path
var debug_output = []

onready var debug = $HSplitContainer/VSplitContainer/Output
onready var tab_container = $HSplitContainer/VSplitContainer/TabContainer
onready var file_system = $HSplitContainer/FileSystem


func _ready() -> void:
	$SaveFileDialog.current_dir = Global.project_path
	$SaveFileDialog.set_filters(PoolStringArray(["*.lua; Lua script"]))
	$SaveFileDialog.current_file = "Untitled.lua"
	
	file_system.project_path = project_path
	update_window_title("")
	$MenuButton.get_popup().add_item("New File")
	$MenuButton.get_popup().add_item("Export..")
	$MenuButton.get_popup().add_item("Save as..")
	$MenuButton.get_popup().add_item("Save")
	$MenuButton.get_popup().add_item("Open Folder")
	$MenuButton.get_popup().add_item("Quit")
	$MenuButton.get_popup().connect("id_pressed", self, "_on_item_pressed")

	$MenuButton.get_popup().set_item_shortcut(0, set_shortcut(KEY_N))
	$MenuButton.get_popup().set_item_shortcut(1, set_shortcut(KEY_E))
	$MenuButton.get_popup().set_item_shortcut(3, set_shortcut(KEY_S))
	$MenuButton.get_popup().set_item_shortcut(5, set_shortcut(KEY_Q))
	
	$HelpMenu.get_popup().add_item("Love2D Website")
	$HelpMenu.get_popup().add_item("Love2D API")
	$HelpMenu.get_popup().add_item("Love2D Forum")
	$HelpMenu.get_popup().add_item("About Creator")
	$HelpMenu.get_popup().connect("id_pressed", self, "_on_help_item_pressed")


func set_shortcut(key):
	var shortcut = ShortCut.new()
	var inputeventkey = InputEventKey.new()
	inputeventkey.set_scancode(key)
	inputeventkey.control = true
	shortcut.set_shortcut(inputeventkey)
	return shortcut
	

func _process(delta: float) -> void:
	toggle_closetab_button()



func toggle_closetab_button():
	if tab_container.get_child_count() > 0:
		$ColorRect/CloseTabButton.disabled = false
	else:
		$ColorRect/CloseTabButton.disabled = true



func update_window_title(suffix : String):
	OS.set_window_title(app_name + " - " + current_file + suffix)
	if tab_container.get_child_count() != 0:
		tab_container.get_child(tab_container.current_tab).name = current_file.get_basename() + suffix


func _on_item_pressed(id):
	var item_name = $MenuButton.get_popup().get_item_text(id)
	match item_name:
		"New File":
			new_file()
		"Export..":
			build()
		"Save as..":
			$SaveFileDialog.popup()
		"Save":
			save_file()
		"Open Folder":
			OS.shell_open(Global.project_path)
		"Quit":
			get_tree().quit()

func _on_help_item_pressed(id):
	var item_name = $HelpMenu.get_popup().get_item_text(id)
	match item_name:
		"Love2D Website":
			OS.shell_open("https://love2d.org/")
		"Love2D API":
			OS.shell_open("https://love2d-community.github.io/love-api/")
		"Love2D Forum":
			OS.shell_open("https://love2d.org/forums/")
		"About Creator":
			OS.shell_open("https://devforfun.itch.io/")
		

func _on_FileSystem_file_changed(file, path) -> void:
	current_file = file
	current_file_path = path
	update_window_title("")
	



func new_file():
	current_file = "Untitled"
	var new_tab = preload("res://code_editor/CodeEdit.tscn").instance()
	tab_container.add_child(new_tab)
	tab_container.current_tab = tab_container.get_child_count() - 1
	
	update_window_title("")
	tab_container.get_child(tab_container.current_tab).text = ""
	tab_container.get_child(tab_container.current_tab).connect("text_changed", self, "_on_CodeEdit_text_changed")
	

func save_file():
	var file_name = current_file
	if tab_container.get_child_count() != 0:
		if file_name == "Untitled":
			$SaveFileDialog.popup()
		else:
			var f = File.new()
			if f.file_exists(current_file_path):
				f.open(current_file_path, 2)
				f.store_string(tab_container.get_child(tab_container.current_tab).text)
				f.close()
				update_window_title("")
			else:
				$WarningDialog.popup()
				current_file = "Untitled"
				current_file_path = null
				update_window_title("")
		

func _on_CodeEdit_text_changed() -> void:
	update_window_title(" (*)")
	

func _on_tab_closed(tab):
	pass



func _on_TabContainer_tab_selected(tab: int) -> void:
	if tab_container.get_children()[tab].get_meta("path") != null:
		current_file_path = tab_container.get_children()[tab].get_meta("path")
		current_file = tab_container.get_child(tab).get_meta("name")
	else:
		current_file = "Untitled"


func existing_tab(tab_path) -> int:
	var count = 0
	for tab in tab_container.get_children():
		if tab.get_meta("path") == tab_path:
			return count
		count += 1
	
	return -1


func _on_FileSystem_item_activated() -> void:
	var path = file_system.get_selected().get_meta("path")
	if path:
		var f = File.new()
		var file_name = file_system.get_selected().get_meta("name")
		f.open(path, 1)
		if (tab_container.get_child_count() == 0) or (tab_container.get_children()[tab_container.current_tab].name.ends_with("(*)")):
			# Create a new tab if there aren't any existing tab
			if existing_tab(path) == -1:
				var new_tab = preload("res://code_editor/CodeEdit.tscn").instance()
				tab_container.add_child(new_tab)
				tab_container.current_tab = tab_container.get_child_count() - 1
			
		if not existing_tab(path) == -1:
			tab_container.current_tab = existing_tab(path)
		
		
		tab_container.get_children()[tab_container.current_tab].name = file_name.get_basename()
		tab_container.get_children()[tab_container.current_tab].set_meta("path", path)
		tab_container.get_child(tab_container.current_tab).set_meta("name", file_name)
		tab_container.get_children()[tab_container.current_tab].text = f.get_as_text()
		tab_container.get_child(tab_container.current_tab).connect("text_changed", self, "_on_CodeEdit_text_changed")
		current_file_path = path
		current_file = file_name
		f.close()


func _on_SaveFileDialog_file_selected(path: String) -> void:
	var f = File.new()
	f.open(path, 2)
	f.store_string(tab_container.get_children()[tab_container.current_tab].text)
	tab_container.get_child(tab_container.current_tab).name = path.get_file().get_basename()
	tab_container.get_child(tab_container.current_tab).set_meta("path", path)
	tab_container.get_child(tab_container.current_tab).set_meta("name", path.get_file())
#	tab_container.get_child(tab_container.current_tab).text = f.get_as_text()
	f.close()
	file_system.update_dir(project_path)
	


func _on_PlaySceneButton_pressed() -> void:
	# TODO: Remember to move the love folder to the export
	var love_directory = str(OS.get_executable_path().get_base_dir()) + "/love/love.exe"
	OS.execute("cmd.exe",["/C",love_directory, Global.project_path], true, debug_output, true)
	for i in debug_output:
		debug.text = "Debug: " + i


# Export
func build():
	OS.execute("cmd.exe",["/C", OS.get_executable_path().get_base_dir() + "/love/boon.exe", "init"], true, debug_output, true)
	OS.execute("cmd.exe", ["/C", OS.get_executable_path().get_base_dir() + "/love/boon.exe", "love","download", "11.3"], true, debug_output, true)
	OS.execute("cmd.exe", ["/C", OS.get_executable_path().get_base_dir() + "/love/boon.exe", "build", Global.project_path, "--target", "all"], true, debug_output, true)
	
	
	for i in debug_output:
		debug.text = i
	# Open folder when the building finished
	OS.shell_open(Global.project_path + "/release")


func move_dll_and_love():
	var dir = Directory.new()
	if dir.open(OS.get_executable_path().get_base_dir() + "/love") == OK:
		dir.list_dir_begin(true, true)
		dir.copy(OS.get_executable_path().get_base_dir() + "/love/love.exe", Global.project_path + "/builds/" + "love.exe")
		var file_name = dir.get_next()
		while (file_name != "" && file_name != "." && file_name != ".."):
			if file_name.get_extension() == "dll":
				print(file_name)
				
				dir.copy(OS.get_executable_path().get_base_dir() + "/love/" + file_name, Global.project_path + "/builds/" + file_name)
			file_name = dir.get_next()
	
	
func _on_RefreshButton_pressed() -> void:
	file_system.update_dir(Global.project_path)


func _on_CloseTabButton_pressed() -> void:
	tab_container.get_child(tab_container.current_tab).queue_free()
	if tab_container.get_child_count() > 0:
		# Change the current tab to the last one that still open
		tab_container.current_tab = tab_container.get_child_count() - 1
