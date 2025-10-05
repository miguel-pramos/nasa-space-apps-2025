extends Node3D


var map:DataMap

var index:int = 0 # Index of structure being built

@export var structures: Array[Structure] = []
@export var selector:Node3D # The 'cursor'
@export var selector_container:Node3D # Node that holds a preview of the structure
@export var view_camera:Camera3D # Used for raycasting mouse
@export var gridmap:GridMap
@export var cash_display:Label

# LIMITES DO GRIDMAP
@export_group("Map Limits")
@export var map_min_x: int = -4
@export var map_max_x: int = 4
@export var map_min_z: int = -7
@export var map_max_z: int = 8
@export var show_limits_warning: bool = true

var plane:Plane # Used for raycasting mouse

# Move mode variables
var move_mode:bool = false
var moving_item_node:Node3D = null # O Node3D que representa o item sendo movido
var moving_structure_index:int = -1
var moving_structure_orientation:int = 0
var moving_from_position:Vector3i

func _ready():
	map = DataMap.new()
	plane = Plane(Vector3.UP, Vector3.ZERO)

	# Create new MeshLibrary dynamically, can also be done in the editor
	# See: https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html

	var meshlib = MeshLibrary.new()
	for structure in structures:
		var id = meshlib.get_last_unused_item_id()

		meshlib.create_item(id)
		meshlib.set_item_mesh(id, get_mesh(structure.model))
		meshlib.set_item_mesh_transform(id, Transform3D())

	gridmap.mesh_library = meshlib

	update_structure()
	update_cash()

func _process(delta):

	# Map position based on mouse
	var world_position = plane.intersects_ray(
		view_camera.project_ray_origin(get_viewport().get_mouse_position()),
		view_camera.project_ray_normal(get_viewport().get_mouse_position()))

	if world_position == null:
		return # Can't get mouse position, so do nothing

	var gridmap_position = Vector3(round(world_position.x), 0, round(world_position.z))
	
	# Limita a posição dentro dos bounds
	var clamped_position = clamp_to_bounds(gridmap_position)

	# Toggle selector visibility based on mode
	selector.get_child(0).visible = not move_mode

	# Cursor always follows the mouse on the ground plane (y=0)
	if selector.visible:
		selector.global_position = lerp(selector.global_position, clamped_position, min(delta * 40, 1.0))

	if not move_mode:
		# Normal Mode
		action_rotate()
		action_structure_toggle()
		action_build(clamped_position)
		action_demolish(clamped_position)
		action_enter_move_mode(clamped_position)
	else:
		# Move Mode - the item being moved follows the cursor but elevated
		if moving_item_node:
			var elevated_position = clamped_position
			elevated_position.y = 0.5 # Elevated height
			moving_item_node.position = lerp(moving_item_node.position, elevated_position, min(delta * 40, 1.0))

		action_place_moved_item(clamped_position)
		action_cancel_move()
		action_rotate_moving()

	# Save/Load work in any mode
	action_save()
	action_load()
	action_load_resources()

# Limita a posição aos bounds do mapa
func clamp_to_bounds(pos: Vector3) -> Vector3:
	var result = pos
	result.x = clamp(pos.x, map_min_x, map_max_x)
	result.z = clamp(pos.z, map_min_z, map_max_z)
	return result

# Verifica se a posição está dentro dos limites
func is_within_bounds(pos: Vector3) -> bool:
	return pos.x >= map_min_x and pos.x <= map_max_x and \
		   pos.z >= map_min_z and pos.z <= map_max_z

func get_mesh(packed_scene):
	var scene = packed_scene.instantiate()
	var queue = [scene]
	while not queue.is_empty():
		var node = queue.pop_front()
		if node is MeshInstance3D:
			var mesh = node.mesh.duplicate()
			scene.queue_free()
			return mesh
		for child in node.get_children():
			queue.append(child)
	
	scene.queue_free()
	return null

# ========== MOVE MODE ==========

# Enters move mode when clicking on an existing item
func action_enter_move_mode(gridmap_position):
	if Input.is_action_just_pressed("move"): # Assumes a "move" action is defined in Input Map
		var grid_pos = Vector3i(int(gridmap_position.x), 0, int(gridmap_position.z))
		
		# Verifica se está dentro dos limites
		if not is_within_bounds(Vector3(grid_pos)):
			if show_limits_warning:
				print("Cannot pick item: Outside map limits!")
			return
		
		var cell_item = gridmap.get_cell_item(grid_pos)

		if cell_item != -1:
			# An item exists here, let's pick it up
			move_mode = true
			moving_structure_index = cell_item
			moving_structure_orientation = gridmap.get_cell_item_orientation(grid_pos)
			moving_from_position = grid_pos

			# Create a visual Node3D to represent the item being moved (elevated)
			moving_item_node = Node3D.new()
			get_tree().root.add_child(moving_item_node)

			# Add the visual model
			var model = structures[moving_structure_index].model.instantiate()
			moving_item_node.add_child(model)

			# Initial position (on the ground)
			moving_item_node.position = Vector3(grid_pos.x, 0.0, grid_pos.z)

			# Animate upwards
			var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(moving_item_node, "position:y", 0.8, 0.2)

			# Original rotation
			var basis = gridmap.get_basis_with_orthogonal_index(moving_structure_orientation)
			moving_item_node.basis = basis

			# Now, remove it from the GridMap (the elevated visual already exists)
			gridmap.set_cell_item(grid_pos, -1)

			Audio.play("sounds/placement-a.ogg", -20)
			print("Move Mode: Picked up item ", moving_structure_index, " from ", grid_pos)

# Places the item being moved in the new position
func action_place_moved_item(gridmap_position):
	if Input.is_action_just_pressed("build"):
		var grid_pos = Vector3i(int(gridmap_position.x), 0, int(gridmap_position.z))
		
		# Verifica se está dentro dos limites
		if not is_within_bounds(Vector3(grid_pos)):
			if show_limits_warning:
				print("Cannot place item: Outside map limits!")
			return
		
		var existing_item = gridmap.get_cell_item(grid_pos)

		# Only place if the position is empty
		if existing_item == -1:
			# Animate downwards
			var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(moving_item_node, "position:y", 0.0, 0.2)
			await tween.finished

			# Get the current orientation of the item being moved
			var final_orientation = gridmap.get_orthogonal_index_from_basis(moving_item_node.basis)

			# Place on the GridMap
			gridmap.set_cell_item(grid_pos, moving_structure_index, final_orientation)

			# Remove the elevated visual node
			moving_item_node.queue_free()
			moving_item_node = null

			# Exit move mode
			move_mode = false

			Audio.play("sounds/placement-a.ogg", -20)
			print("Move Mode: Item placed at ", grid_pos)

# Cancels move mode and returns the item to its original position
func action_cancel_move():
	if Input.is_action_just_pressed("cancel_move"):
		if not moving_item_node: return

		# Animate back to original position (from elevated height)
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		var target_pos = Vector3(moving_from_position.x, 0, moving_from_position.z)
		tween.tween_property(moving_item_node, "position", target_pos, 0.3)
		await tween.finished

		# Return item to original position on gridmap
		gridmap.set_cell_item(moving_from_position, moving_structure_index, moving_structure_orientation)

		# Remove the elevated visual node
		if moving_item_node:
			moving_item_node.queue_free()
			moving_item_node = null

		# Exit move mode
		move_mode = false

		Audio.play("sounds/removal-a.ogg", -20)
		print("Move Mode: Canceled, item returned to ", moving_from_position)

# Rotates the item being moved
func action_rotate_moving():
	if Input.is_action_just_pressed("rotate"):
		if moving_item_node:
			moving_item_node.rotate_y(deg_to_rad(90))
			Audio.play("sounds/rotate.ogg", -30)

# ========== NORMAL MODE ==========

# Build (place) a structure
func action_build(gridmap_position):
	if Input.is_action_just_pressed("build"):
		
		# Verifica se está dentro dos limites
		if not is_within_bounds(gridmap_position):
			if show_limits_warning:
				print("Cannot build: Outside map limits!")
			return

		var previous_tile = gridmap.get_cell_item(gridmap_position)
		gridmap.set_cell_item(gridmap_position, index, gridmap.get_orthogonal_index_from_basis(selector.basis))

		if previous_tile != index:
			map.cash -= structures[index].price
			update_cash()

		Audio.play("sounds/placement-a.ogg", -20)

# Demolish (remove) a structure
func action_demolish(gridmap_position):
	if Input.is_action_just_pressed("demolish"):
		# Verifica se está dentro dos limites
		if not is_within_bounds(gridmap_position):
			return
		
		if gridmap.get_cell_item(gridmap_position) != -1:
			gridmap.set_cell_item(gridmap_position, -1)

			Audio.play("sounds/removal-a.ogg", -20)

# Rotates the 'cursor' 90 degrees
func action_rotate():
	if Input.is_action_just_pressed("rotate"):
		selector.rotate_y(deg_to_rad(90))

		Audio.play("sounds/rotate.ogg", -30)

# Toggle between structures to build
func action_structure_toggle():
	var changed = false
	if Input.is_action_just_pressed("structure_next"):
		index = wrap(index + 1, 0, structures.size())
		changed = true
	
	if Input.is_action_just_pressed("structure_previous"):
		index = wrap(index - 1, 0, structures.size())
		changed = true

	if changed:
		Audio.play("sounds/toggle.ogg", -30)
		update_structure()

# Update the structure visual in the 'cursor'
func update_structure():
	# Clear previous structure preview in selector
	for n in selector_container.get_children():
		selector_container.remove_child(n)
		n.queue_free()

	# Create new structure preview in selector
	var _model = structures[index].model.instantiate()
	selector_container.add_child(_model)
	_model.position.y += 0.25

func update_cash():
	cash_display.text = "$" + str(map.cash)

# ========== SAVING/LOADING ==========

func action_save():
	if Input.is_action_just_pressed("save"):
		print("Saving map...")

		map.structures.clear()
		for cell in gridmap.get_used_cells():

			var data_structure:DataStructure = DataStructure.new()

			data_structure.position = Vector2i(cell.x, cell.z)
			data_structure.orientation = gridmap.get_cell_item_orientation(cell)
			data_structure.structure = gridmap.get_cell_item(cell)

			map.structures.append(data_structure)

		ResourceSaver.save(map, "user://map.res")

func action_load():
	if Input.is_action_just_pressed("load"):
		print("Loading map...")

		gridmap.clear()

		map = ResourceLoader.load("user://map.res")
		if not map:
			map = DataMap.new()
		for cell in map.structures:
			gridmap.set_cell_item(Vector3i(cell.position.x, 0, cell.position.y), cell.structure, cell.orientation)

		update_cash()

func action_load_resources():
	if Input.is_action_just_pressed("load_resources"):
		print("Loading map...")

		gridmap.clear()

		map = ResourceLoader.load("res://sample map/map.res")
		if not map:
			map = DataMap.new()
		for cell in map.structures:
			gridmap.set_cell_item(Vector3i(cell.position.x, 0, cell.position.y), cell.structure, cell.orientation)

		update_cash()
