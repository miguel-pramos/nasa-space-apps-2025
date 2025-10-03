@tool
extends EditorScript

## A pasta onde estão seus modelos 3D (.glb, .tscn, etc)
const SOURCE_MODELS_FOLDER = "res://models/"

## A pasta onde os novos arquivos de recurso (.tres) serão salvos
const OUTPUT_RESOURCES_FOLDER = "res://structures/"

## O preço padrão para cada nova estrutura criada
const DEFAULT_PRICE = 150

func _run():
	print("Iniciando geração de recursos de Estrutura...")
	
	# Garante que a pasta de saída exista
	DirAccess.make_dir_absolute(OUTPUT_RESOURCES_FOLDER)
	
	var dir = DirAccess.open(SOURCE_MODELS_FOLDER)
	if not dir:
		print("ERRO: A pasta de modelos de origem não foi encontrada: ", SOURCE_MODELS_FOLDER)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		# Processa apenas arquivos de cena/modelo, e não diretórios
		if not dir.current_is_dir() and (file_name.ends_with(".glb") or file_name.ends_with(".tscn")):
			var model_path = SOURCE_MODELS_FOLDER.path_join(file_name)
			var resource_name = file_name.get_basename()
			var output_path = OUTPUT_RESOURCES_FOLDER.path_join(resource_name + ".tres")
			
			print("Processando modelo: ", model_path)
			
			# Cria uma nova instância do nosso recurso Structure
			var new_structure = Structure.new()
			
			# Define as propriedades
			new_structure.price = DEFAULT_PRICE
			new_structure.model = load(model_path) # Associa o modelo 3D
			
			# Salva o novo recurso .tres no disco
			var error = ResourceSaver.save(new_structure, output_path)
			if error == OK:
				print(" -> Recurso de estrutura salvo em: ", output_path)
			else:
				print(" -> ERRO ao salvar o recurso. Código: ", error)

		file_name = dir.get_next()
		
	print("Geração de recursos concluída!")
