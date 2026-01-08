extends MeshInstance3D

var tool: MeshDataTool
var stool: SurfaceTool
var surf
var verts = []
var norms = []
var inds = []
var sz = -1
var pos = 0

@export var testing = false

@export var offset = Vector3.ZERO

func reload():
	tool = MeshDataTool.new()
	stool = SurfaceTool.new()
	tool.create_from_surface(mesh, 0)
	#stool.create_from(mesh, 0)
	#stool.index()
	#mesh = stool.commit()
	surf = mesh.surface_get_arrays(0)
	verts = surf[0]
	norms = surf[1]
	
		
	#print()
	#print(tool.get_vertex_count())
	inds = surf[ArrayMesh.ARRAY_MAX-1]
	sz = inds.size()

var skip = true
# Called when the node enters the scene tree for the first time.
func _ready():
	reload()
	#print(sz)
	#print(tool.to_string())
	#for vert in tool.get_vertex_count():
		#print(tool.get_vertex(vert))
		
	#print(tool.get_format())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if(Input.is_action_just_pressed("CAMERA_ADJUST")):
		#print("I did the thing.")
		#for vert in surf[0].size():
		#	var start = surf[0][vert]
			#var end = surf[1][vert]
			#Line.line_with_dir(start, (start + end), Color.SKY_BLUE)
			#Line.point(start + end, 0.1)
	if(testing && Input.is_action_just_pressed("DEBUG_2")):
		#Line.clear_all()
		if(pos < sz):
			#print(pos)
			if(skip):
				Line.point(verts[inds[pos]] + offset , 0.1)
				pos+=1
				skip = false
				pass
			else:
				Line.line_with_dir(verts[inds[pos-1]] + offset, verts[inds[pos]]+ offset , Color.RED, 4)
				Line.point(verts[inds[pos]] +offset, 0.1)
				pos+=1
				if(pos % 3 == 0):
					skip = true
					Line.line_with_dir(verts[inds[pos-1]]+ offset , verts[inds[pos-3]]+ offset , Color.GREEN, 4)
					#Line.point(verts[inds[pos]] + norms[inds[pos]], 0.1)
				pass
			
	if(Input.is_action_just_pressed("DEBUG_1")):
		Line.clear_all()
		
		pos = 0
		skip = true
	if(Input.is_action_just_pressed("DEBUG_3")):
		reload()
				
		
	pass
