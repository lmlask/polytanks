tool # Needed so it runs in the editor.
extends EditorScenePostImport


func post_import(scene):
	for i in scene.get_children():
		i.translation = Vector3.ZERO
	return scene # remember to return the imported scene
