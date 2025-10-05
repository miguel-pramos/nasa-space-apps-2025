@tool
extends Node3D
@export var player:CharacterBody3D
#--- Wall geometry
@export var cutMesh:MeshInstance3D

@export_range(0,2) var noiseSize:float
@export_range(0,5) var noiseSpeed:float
@export_range(0,3) var noiseStrength:float
@export_range(0,20) var sphereRadius:float
@export_range(0,1) var borderSize:float
@export_color_no_alpha var borderColor:Color
@export var followPlayer:bool

func _process(_delta: float) -> void:
	var shaderMat:ShaderMaterial = cutMesh.material_override
	shaderMat.set_shader_parameter("spherePos",global_position)
	shaderMat.set_shader_parameter("sphereRadius",sphereRadius)
	shaderMat.set_shader_parameter("borderSize",borderSize)
	shaderMat.set_shader_parameter("borderColor",borderColor)
	shaderMat.set_shader_parameter("noiseSize",noiseSize)
	shaderMat.set_shader_parameter("noiseSpeed",noiseSpeed)
	shaderMat.set_shader_parameter("noiseStrength",noiseStrength)

#func _physics_process(_delta: float) -> void:
	#if followPlayer: 
		#global_position = player.global_position
		#
