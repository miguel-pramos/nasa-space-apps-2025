extends Node3D


var map:DataMap

var index:int = 0 # Index of structure being built

@export var structures: Array = [] # REMOVED [Structure] type hint
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
@export var map_max_z: int = 7
@export var show_limits_warning: bool = true

var plane:Plane # Used for raycasting mouse

# Move mode variables
var move_mode:bool = false
var moving_item_node:Node3D = null # O Node3D que representa o item sendo movido
var moving_structure_index:int = -1
var moving_structure_orientation:int = 0
var moving_from_position:Vector3i

var is_active = false
var is_initialized = false

func _ready():
	set_active(false)

func initialize():
	if is_initialized: return
	is_initialized = true
	
	map = DataMap.new()
	# Use the node's own global Y position to define the build plane
	plane = Plane(Vector3.UP, global_position.y)

	var meshlib = MeshLibrary.new()
	for structure in structures:
		if structure == null:
			push_error("A structure in the 'structures' array of the Builder node is null. Please check the scene file.")
			continue
			
		var id = meshlib.get_last_unused_item_id()

		meshlib.create_item(id)
		meshlib.set_item_mesh(id, get_mesh(structure.model))
		meshlib.set_item_mesh_transform(id, Transform3D())

	gridmap.mesh_library = meshlib

	update_structure()
	update_cash()

func set_active(active: bool):
	is_active = active
	if selector:
		selector.visible = active

	if is_active and not is_initialized:
		initialize()

func _process(delta):
	if not is_active:
		return

	# 1. Get mouse position in the world on our construction plane
	var world_position = plane.intersects_ray(
		view_camera.project_ray_origin(get_viewport().get_mouse_position()),
		view_camera.project_ray_normal(get_viewport().get_mouse_position()))

	if world_position == null:
		return # Can't get mouse position, so do nothing

	# 2. Convert world position to the GridMap's local integer coordinates
	var local_pos = gridmap.to_local(world_position)
	var map_coords: Vector3i = gridmap.local_to_map(local_pos)

	# 2a. Clamp the map coordinates to the defined limits
	map_coords.x = clamp(map_coords.x, map_min_x, map_max_x)
	map_coords.z = clamp(map_coords.z, map_min_z, map_max_z)

	# 3. Update selector position in the world
	# (Convert clamped map coords back to world to place the selector correctly on the grid)
	var selector_local_pos = gridmap.map_to_local(map_coords)
	var selector_world_pos = gridmap.to_global(selector_local_pos)
	if selector.visible:
		selector.global_position = lerp(selector.global_position, selector_world_pos, min(delta * 40, 1.0))

	# 4. Handle actions using the (now clamped) map coordinates
	if not move_mode:
		# Normal Mode
		action_rotate()
		action_structure_toggle()
		action_build(map_coords)
		action_demolish(map_coords)
		action_enter_move_mode(map_coords)
	else:
		# Move Mode
		# The floating item follows the CLAMPED grid position, not the raw mouse position
		if moving_item_node:
			var elevated_position = selector_world_pos # Follow the clamped selector
			elevated_position.y += 0.5 # Elevated height
			moving_item_node.global_position = lerp(moving_item_node.global_position, elevated_position, min(delta * 40, 1.0))

		action_place_moved_item(map_coords)
		action_cancel_move()
		action_rotate_moving()


func get_mesh(packed_scene):
	if packed_scene == null:
		push_error("A structure's model (PackedScene) is null.")
		return null
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

func action_enter_move_mode(map_coords: Vector3i):
	if Input.is_action_just_pressed("move"):
		var cell_item = gridmap.get_cell_item(map_coords)

		if cell_item != -1:
			move_mode = true
			moving_structure_index = cell_item
			moving_structure_orientation = gridmap.get_cell_item_orientation(map_coords)
			moving_from_position = map_coords

			moving_item_node = Node3D.new()
			add_child(moving_item_node) # Add to builder so it moves with the module

			var model = structures[moving_structure_index].model.instantiate()
			moving_item_node.add_child(model)

			moving_item_node.global_position = gridmap.to_global(gridmap.map_to_local(map_coords))

			var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(moving_item_node, "position:y", moving_item_node.position.y + 0.8, 0.2)

			var basis = gridmap.get_basis_with_orthogonal_index(moving_structure_orientation)
			moving_item_node.basis = basis

			gridmap.set_cell_item(map_coords, -1)
			print("Move Mode: Picked up item ", moving_structure_index, " from ", map_coords)

func action_place_moved_item(map_coords: Vector3i):
	if Input.is_action_just_pressed("build"):
		var existing_item = gridmap.get_cell_item(map_coords)

		if existing_item == -1:
			var target_pos = gridmap.to_global(gridmap.map_to_local(map_coords))
			var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(moving_item_node, "global_position", target_pos, 0.2)
			await tween.finished

			var final_orientation = gridmap.get_orthogonal_index_from_basis(moving_item_node.basis)
			gridmap.set_cell_item(map_coords, moving_structure_index, final_orientation)

			moving_item_node.queue_free()
			moving_item_node = null
			move_mode = false
			print("Move Mode: Item placed at ", map_coords)

func action_cancel_move():
	if Input.is_action_just_pressed("cancel_move"):
		if not moving_item_node: return

		var target_pos = gridmap.to_global(gridmap.map_to_local(moving_from_position))
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(moving_item_node, "global_position", target_pos, 0.3)
		await tween.finished

		gridmap.set_cell_item(moving_from_position, moving_structure_index, moving_structure_orientation)

		if moving_item_node:
			moving_item_node.queue_free()
			moving_item_node = null

		move_mode = false
		print("Move Mode: Canceled, item returned to ", moving_from_position)

func action_rotate_moving():
	if Input.is_action_just_pressed("rotate"):
		if moving_item_node:
			moving_item_node.rotate_y(deg_to_rad(90))

# ========== NORMAL MODE ==========

func action_build(gridmap_position):
	if Input.is_action_just_pressed("build"):
		var previous_tile = gridmap.get_cell_item(gridmap_position)
		gridmap.set_cell_item(gridmap_position, index, gridmap.get_orthogonal_index_from_basis(selector.basis))

		if previous_tile != index:
			Global.resources.money -= structures[index].price
			if structures[index].kitchen:
				Global.resources.kitchen += structures[index].volume
				Global.resources.food += structures[index].weight
			if structures[index].bedroom:
				Global.resources.beddrom += structures[index].volume
			if structures[index].bathrom:
				Global.resources.bathdroom += structures[index].volume
				Global.resources.hygine += structures[index].weight
				
		Audio.play("sounds/placement-a.ogg", -20)

# Demolish (remove) a structure
func action_demolish(gridmap_position):
	if Input.is_action_just_pressed("demolish"):
		var cell_item_index = gridmap.get_cell_item(gridmap_position)
		if cell_item_index != -1:
			if structures[cell_item_index].kitchen:
				Global.resources.kitchen -= 10
			if structures[cell_item_index].bedroom:
				Global.resources.beddrom -= 10
			if structures[cell_item_index].bathrom:
				Global.resources.bathdroom -= 10
				Global.resources.hygine -= 10
			gridmap.set_cell_item(gridmap_position, -1)

			Audio.play("sounds/removal-a.ogg", -20)

func action_rotate():
	if Input.is_action_just_pressed("rotate"):
		selector.rotate_y(deg_to_rad(90))

func action_structure_toggle():
	var changed = false
	if Input.is_action_just_pressed("structure_next"):
		index = wrap(index + 1, 0, structures.size())
		changed = true
	
	if Input.is_action_just_pressed("structure_previous"):
		index = wrap(index - 1, 0, structures.size())
		changed = true

	if changed:
		update_structure()

func update_structure():
	if structures.is_empty() or index >= structures.size():
		print_debug("No structures defined or index out of bounds.")
		return
		
	for n in selector_container.get_children():
		selector_container.remove_child(n)
		n.queue_free()

	var _model = structures[index].model.instantiate()
	selector_container.add_child(_model)
	_model.position.y += 0.25

func update_cash():
	cash_display.text = "$" + str(map.cash)
