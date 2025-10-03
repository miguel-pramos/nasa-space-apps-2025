@tool # Essencial para rodar no editor
extends EditorScript

# CONFIGURE AQUI
const SOURCE_FOLDER = "res://models/" # Pasta com seus arquivos .glb/.gltf
const OUTPUT_PATH = "res://buildings.meshlib"   # Onde salvar a MeshLibrary final

func _run():
	print("Iniciando geração da MeshLibrary (versão robusta)...")
	var mesh_lib = MeshLibrary.new()
	var dir = DirAccess.open(SOURCE_FOLDER)
	
	if not dir:
		print("ERRO: Pasta de origem não encontrada: ", SOURCE_FOLDER)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var item_id = 0

	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".glb") or file_name.ends_with(".gltf")):
			var model_path = SOURCE_FOLDER.path_join(file_name)
			print("Processando: ", model_path)
			
			var scene = load(model_path)
			if scene:
				var instance = scene.instantiate()
				
				var mesh_instance = null
				var collision_shape = null
				
				var nodes_to_check = []
				nodes_to_check.append_array(instance.get_children())
				
				while not nodes_to_check.is_empty():
					var current_node = nodes_to_check.pop_front()
					
					if current_node is MeshInstance3D and not mesh_instance:
						mesh_instance = current_node
					
					if current_node is CollisionShape3D and not collision_shape:
						collision_shape = current_node

					# Se já achamos os dois, podemos parar de procurar
					if mesh_instance and collision_shape:
						break
					
					# Adiciona os filhos do nó atual na fila para checagem
					nodes_to_check.append_array(current_node.get_children())
				# --- FIM DA NOVA LÓGICA ---

				if mesh_instance and mesh_instance.mesh:
					mesh_lib.create_item(item_id)
					mesh_lib.set_item_mesh(item_id, mesh_instance.mesh)
					
					if collision_shape and collision_shape.shape:
						var shapes = [collision_shape.shape]
						mesh_lib.set_item_shapes(item_id, shapes)
					else:
						print("AVISO: Nenhuma CollisionShape3D encontrada em ", file_name)

					mesh_lib.set_item_name(item_id, file_name.get_basename())
					item_id += 1
				else:
					print("AVISO: Nenhuma MeshInstance3D encontrada em ", file_name)
				
				instance.queue_free()

		file_name = dir.get_next()

	var error = ResourceSaver.save(mesh_lib, OUTPUT_PATH)
	if error == OK:
		print("SUCESSO! MeshLibrary salva em: ", OUTPUT_PATH)
	else:
		print("ERRO ao salvar a MeshLibrary. Código de erro: ", error)
