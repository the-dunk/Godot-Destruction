extends Node
var def_mat: ORMMaterial3D
var base_child: Node3D
var child_added = false
func _ready():
	print("weehoo")
	base_child = Node3D.new()
	base_child.name = "Line Drawer"
	def_mat = ORMMaterial3D.new()
	def_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	def_mat.albedo_color = Color.RED
	pass



func _on_timer_timeout(timer): 
	#print("yahoo?")
	timer.queue_free()
	
	
func _on_dir_timeout(): 
	#print("yahoo?")
	var t = base_child.find_children("_DIR_TIMER_DELETE*", "", true, false)
	
	for x in t:
		x.queue_free()
	

func clear_all():
	if(child_added):
		for node in base_child.get_children():
			node.queue_free()

func _line_internal(p1, p2, col, duration,mat) -> MeshInstance3D:
	if(!child_added):
		get_tree().get_root().add_child(base_child)
		child_added =true
	var material = mat.duplicate()
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	#print(col)
	material.albedo_color = col
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
	immediate_mesh.surface_add_vertex(p1)
	immediate_mesh.surface_add_vertex(p2)
	immediate_mesh.surface_end()
	
	
	return mesh_instance

func line(p1, p2, col=Color.WHITE_SMOKE, duration=0,mat=def_mat) -> MeshInstance3D:
	var mesh_instance = _line_internal(p1,p2,col,duration,mat)
	if(duration):
		#print("yahoo?")
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = duration
		timer.autostart = true
		timer.timeout.connect(_on_timer_timeout)
		#timer.connect("timeout", _on_timer_timeout)
		
		timer.add_child(mesh_instance)
		timer.name = ("_POINT_TIMER_DELETE") 
		base_child.add_child(timer, true)
	
	
	if(!duration):
		base_child.add_child(mesh_instance)
		
	return mesh_instance

func line_with_dir(p1, p2, col=Color.WHITE_SMOKE, point_dur=0, duration=0,mat=def_mat) -> MeshInstance3D:
	
	var material = mat.duplicate()
	material.albedo_color = col
	var mesh_instance = _line_internal(p1,p2,col,duration,material)
	var arrow_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	arrow_instance.cast_shadow = arrow_instance.SHADOW_CASTING_SETTING_OFF
	arrow_instance.mesh = immediate_mesh
	
	var dir = p1.direction_to(p2)
	var pnt1 = (Vector3.ONE - abs(dir)) * 0.1
	var pnt2 = pnt1.rotated(dir, 1.5)
	var pnt3 = -pnt1
	var pnt4 = pnt3.rotated(dir, 1.5)
	#print(pnt1,pnt2,pnt3,pnt4)
	dir *=0.5
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
	
	#print(pnt1,pnt3,pnt2)
	#immediate_mesh.surface_add_vertex(Vector3(-0.1,0.1,0))
	#immediate_mesh.surface_add_vertex(Vector3(-0.1,-0.1,0))
	#immediate_mesh.surface_add_vertex(Vector3(0.1,-0.1,0))
	immediate_mesh.surface_add_vertex(pnt2)
	immediate_mesh.surface_add_vertex(pnt3)
	immediate_mesh.surface_add_vertex(pnt1)
	
	#immediate_mesh.surface_add_vertex(Vector3(0.1,-0.1,0))
	#immediate_mesh.surface_add_vertex(Vector3(0.1,0.1,0))
	#immediate_mesh.surface_add_vertex(Vector3(-0.1,0.1,0))
	immediate_mesh.surface_add_vertex(pnt3)
	immediate_mesh.surface_add_vertex(pnt4)
	immediate_mesh.surface_add_vertex(pnt1)
	
	immediate_mesh.surface_add_vertex(pnt1)
	immediate_mesh.surface_add_vertex(pnt4)
	immediate_mesh.surface_add_vertex(dir)
	
	immediate_mesh.surface_add_vertex(pnt4)
	immediate_mesh.surface_add_vertex(pnt3)
	immediate_mesh.surface_add_vertex(dir)

	immediate_mesh.surface_add_vertex(pnt3)
	immediate_mesh.surface_add_vertex(pnt2)
	immediate_mesh.surface_add_vertex(dir)

	immediate_mesh.surface_add_vertex(pnt2)
	immediate_mesh.surface_add_vertex(pnt1)
	immediate_mesh.surface_add_vertex(dir)
	
	immediate_mesh.surface_end()
	
	
	arrow_instance.position = p2
	
	

	if(point_dur):
		var tim = Timer.new()
		tim.one_shot = true
		tim.wait_time = duration
		tim.autostart = true
		tim.timeout.connect(_on_dir_timeout)
		tim.name = ("_DIR_TIMER_DELETE")
		tim.add_child(arrow_instance)
		mesh_instance.add_child(tim)
	else:
		mesh_instance.add_child(arrow_instance)
	
	if(duration):
		#print("yahoo?")
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = duration
		timer.autostart = true
		timer.timeout.connect(_on_timer_timeout)
		#timer.connect("timeout", _on_timer_timeout)
		
		timer.add_child(mesh_instance)
		timer.name = ("_POINT_TIMER_DELETE") 
		base_child.add_child(timer, true)
		
	
	if(!duration):
		base_child.add_child(mesh_instance)
		
	return mesh_instance


func point(p, size=0.2, duration=0, col=Color.RED, mat=def_mat) -> MeshInstance3D:
	if(!child_added):
		get_tree().get_root().add_child(base_child)
		child_added =true
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	var material = mat.duplicate()
	material.albedo_color = col
	mesh_instance.mesh = sphere
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	mesh_instance.position = p
	
	sphere.radius = size
	sphere.height = 2*size
	sphere.material = material
	
	
	
	if(duration):
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = duration
		timer.autostart = true
		timer.timeout.connect(_on_timer_timeout.bind(timer))
		#timer.connect("timeout", _on_timer_timeout)
		
		timer.add_child(mesh_instance)
		timer.name = ("_POINT_TIMER_DELETE") 
		base_child.add_child(timer, true)
	if(!duration):
		base_child.add_child(mesh_instance)
	return mesh_instance
	
	
	
	
