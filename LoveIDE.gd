extends Control


func _on_ProjectsList_change_scene(project_name, path) -> void:
	$ProjectsList.hide()
	var directory = Directory.new()
	if directory.open(Global.project_path) == OK:
		directory.list_dir_begin(true, true)
		
		if not directory.file_exists("main.lua"):
			directory.copy(OS.get_executable_path().get_base_dir() + "/template" + "/main.lua", Global.project_path + "/main.lua")
#		if not directory.file_exists("build.lua"):
#			directory.copy(OS.get_executable_path().get_base_dir() + "/template" + "/build.lua", Global.project_path + "/build.lua")
	var code_editor = preload("res://code_editor/code_editor.tscn").instance()
	self.add_child(code_editor)
	

