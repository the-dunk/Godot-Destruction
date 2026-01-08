extends Camera3D

@export var cut_distance = 20
@export var cut_plane_scene: PackedScene

@export var spark_particle_scene:PackedScene


@export var melt_material: Material

var has_target = false
var plane: MeshInstance3D
var start_point_dot: MeshInstance3D
var end_point_dot: MeshInstance3D
var face_plane: Plane

var cut_plane
var cut_plane_actual

var spark_particles: GPUParticles3D


var raycast_result: Dictionary

var cut_direction: Vector3
var depth_to_center: Vector3
var other_side: Dictionary
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	plane = cut_plane_scene.instantiate()
	#add_child(plane)
	start_point_dot = plane.get_node("./CutPointStart")
	end_point_dot = plane.get_node("./CutPointEnd")
	plane.visible = false
	
	spark_particles = spark_particle_scene.instantiate()
	#add_child(spark_particles)
	spark_particles.emitting = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_pressed("CAM_LEFT") ||Input.is_action_pressed("CAM_RIGHT")):
		translate(Vector3(Input.get_axis("CAM_LEFT", "CAM_RIGHT") * 0.15,0,0))
		pass
	
	if(Input.is_action_pressed("CAM_BACKWARD") ||Input.is_action_pressed("CAM_FORWARD")):
		translate(Vector3(0,0,Input.get_axis("CAM_BACKWARD", "CAM_FORWARD") * -0.15))
		pass
		

func _physics_process(delta):
	
	if(Input.is_action_just_pressed("CUT")):
		var pos = get_viewport().get_mouse_position()
		#print("attacked")
		var space = get_world_3d().direct_space_state
		
		var query = PhysicsRayQueryParameters3D.create(global_position, project_ray_normal(pos) * 50)
		
		var result = space.intersect_ray(query)
		
		
		if(result):
			has_target = true
			#Line.point(result.position, 0.1, 3)
			#print(result)
			cut_direction = global_position.direction_to(result.position)
			
			#remove_child(plane)
			if(cut_plane):
				if(raycast_result):
					print("yep")
					raycast_result.collider.remove_child(cut_plane)
					cut_plane = null
					cut_plane_actual = null
				
				
			raycast_result = result
			
			result.collider.add_child(plane)
			
			#remove_child(spark_particles)
			result.collider.add_child(spark_particles)
			spark_particles.global_position = result.position
			
			var mesh:MeshInstance3D = result.collider.get_node("./Mesh")
			plane.visible = false
			plane.mesh.size.x = 3
			#print(mesh.mesh.get_aabb())
			var size = min(cut_distance, (mesh.mesh.get_aabb().size * 1.05 * result.normal).length())
			depth_to_center = mesh.mesh.get_aabb().size * result.normal
			
			#print(size)
			#Line.point(result.position, 0.1, 3, Color.RED)
			#print(result.normal)
			plane.mesh.size.z = size
			plane.global_position = result.position
			#plane.position += result.normal * (size/2)

			face_plane = Plane(result.normal, result.position)
			plane.basis = self.basis
			plane.basis.z = result.normal
			start_point_dot.basis = self.basis
			end_point_dot.basis = self.basis
			spark_particles.emitting = true
		else:
			has_target = false
			
			#print(result)
			
	if(has_target && Input.is_action_pressed("CUT")):
		
		plane.visible = true
		
		var next_point = face_plane.intersects_segment(global_position, project_ray_normal(get_viewport().get_mouse_position()) * 50)
		var dist
		#Line.point(next_point, 0.1, 1, Color.BLUE)
		if(!next_point):
			dist = cut_distance
		else:
			dist = (next_point - (raycast_result.position)).length()
			
			plane.global_position = (next_point + raycast_result.position)/2 - depth_to_center/2
			#print(rad_to_deg(raycast_result.position.angle_to(next_point)))
			#var p1 = raycast_result.position - abs(raycast_result.normal) * raycast_result.position 
			#var p2 = next_point - abs(raycast_result.normal) * next_point
			
			var p1:Vector3 = raycast_result.position
			var p2:Vector3 = next_point
			
			start_point_dot.global_position = p1
			end_point_dot.global_position = p2
			#print(dist)
			#if(dist >= 0.9):
			spark_particles.global_position = lerp(p2 + clampf(dist, 0.0, 1.0) * p2.direction_to(p1) , p2, randf())
			
			plane.basis.x = p1.direction_to(p2)
			plane.basis.y = plane.basis.x.cross(plane.basis.z)
			start_point_dot.basis = plane.basis
			
			
			end_point_dot.basis = plane.basis
			#print(p1)
			#print(p2)
			var angle = p2.angle_to(p1)
			
			#plane.rotation = raycast_result.normal * angle
			#print()
			
			
		plane.mesh.size.x = dist
		
		pass
	elif(Input.is_action_just_released("CUT") && has_target):
		
		spark_particles.emitting = false
		#raycast_result.collider.remove_child(spark_particles)
		raycast_result.collider.remove_child(plane)
		
		cut_plane = MeshInstance3D.new()
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.RED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		var plane_mesh = PlaneMesh.new()
		var line_mesh = ImmediateMesh.new()
		line_mesh.surface_begin(Mesh.PRIMITIVE_LINES, mat)
		line_mesh.surface_add_vertex(Vector3(0,0,0))
		line_mesh.surface_add_vertex(Vector3(0,2,0))
		line_mesh.surface_end()
		var _line = MeshInstance3D.new()
		_line.mesh = line_mesh
		
		plane_mesh.size = Vector2(5,5)
		print(raycast_result.position)
		cut_plane.global_position = raycast_result.collider.to_local(raycast_result.position)
		cut_plane.basis = plane.basis
		cut_plane.basis.y = -cut_plane.basis.y
		cut_plane.add_child(_line)
		plane.basis = self.basis
		cut_plane.mesh = plane_mesh
		
		cut_plane.material_override = mat
		
		cut_plane_actual = Plane(cut_plane.basis.y, raycast_result.position)
		cut_plane.visible = true
		raycast_result.collider.add_child(cut_plane)
		
		var new_meshes = do_cut()
		
		var collider = raycast_result.collider
		var mesh: MeshInstance3D = collider.get_node("Mesh")
		
		var newMesh = ArrayMesh.new()
		#print(new_meshes[0])
		print(new_meshes)
		
		mesh.mesh= new_meshes.ABOVE_CUT_MESH
		
		
		
		has_target = false
		
	if(raycast_result && Input.is_action_just_pressed("ALT_CUT")):
		var space = get_world_3d().direct_space_state
		var coll: CollisionObject3D
		coll = raycast_result.collider
		var orig_mask = coll.collision_layer
		print(coll.collision_mask)
		
		coll.set_collision_layer_value(32, true)
		
		print(coll.collision_mask)
		var mask = coll.collision_layer
		
		print(orig_mask)
		print(mask)
		
		var start = raycast_result.position + cut_direction * cut_distance
		
		var query = PhysicsRayQueryParameters3D.create(start, raycast_result.position, 0xF0000000)
		
		var result = space.intersect_ray(query)
		if(result):
			other_side = result
			Line.point(other_side.position, 0.1, 5)
			Line.point(raycast_result.position, 0.1, 5)
			Line.line(start, raycast_result.position, Color.BLUE, 5)
		coll.collision_layer = orig_mask
		pass
		

func _input(event):
	if(event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		self.rotate_y(event.relative.x* -0.001)
		self.rotate_object_local(Vector3(1,0,0), event.relative.y * -0.001)
	if(Input.is_action_just_pressed("QUIT")):
		get_tree().quit()
		
	if(Input.is_action_just_pressed("FREE_MOUSE")):
		#print(raycast_result)
		#Line.line_with_dir(raycast_result.position - 2*cut_direction, raycast_result.position-0.5*cut_direction, Color.RED, 4, 4)
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if(Input.is_action_just_pressed("DEBUG_1")):
		if(raycast_result):
			raycast_result.collider.remove_child(cut_plane)
		
		
		
		
func do_cut():
	Line.clear_all()
	if(!raycast_result):
		return
	
	if(!cut_plane_actual):
		return
		
	
	print("Beginning the cut")
	print("Cut Plane - ", cut_plane_actual)
	
	var collider = raycast_result.collider
	var mesh: MeshInstance3D = collider.get_node("Mesh")
	var collision: CollisionShape3D = collider.get_node("Collision")
	var arr_mesh = mesh.mesh
	print(arr_mesh)
	var surface = arr_mesh.surface_get_arrays(0)
	var plane: Plane = cut_plane_actual
	
	
	var verts = surface[0]
	var indices = surface[Mesh.ARRAY_INDEX]
	#print(surface)
	print("- SURFACE -")
	
	for thing in surface.size():
		if(surface[thing]):
			print(thing, ": ", surface[thing], " - Size: ", surface[thing].size())
		else:
			print(thing, ": null")
	
	print("Verts: ", surface[0], "\n"," Size: ", surface[0].size(), "\n")
	print("Norms: ", surface[1], "\n")
	print("Tangents: ", surface[2]," Size: ", surface[2].size(), "\n")
	print("Indexes: ", surface[Mesh.ARRAY_INDEX], " Size: ", surface[Mesh.ARRAY_INDEX].size(), "\n")
	#print(surface[3])
	#print(surface[4])
	var tris = []
	
	tris.resize(indices.size() / 3)
	#print(tris.size())
	for i in tris.size():
		tris[i] = [null,null,null]
		
	var broken_tris = []
	broken_tris.resize(tris.size())
	var below_tris = broken_tris.duplicate()
	var above_tris = broken_tris.duplicate()
	#var above_verts = []
	var below_verts = broken_tris.duplicate()
	var broken = 0
	var i = 0
	for index in indices:
		var tri_ind:int = i/3
		var tri_interior_ind = i%3
		var vert = verts[index]
		
		var over = plane.is_point_over(mesh.to_global(vert))
		#print(vert)
		#print(tris[tri_ind])
	
		tris[tri_ind][tri_interior_ind] = index
		if(over):
			#print(vert)
			#print("I'm over!")
			#if(above_verts.size() == 0 || indices[above_verts.back()] != index):
				#above_verts.push_back(i)
			pass
			#Line.point(mesh.to_global(vert), 0.1, 0, Color.GREEN)
		else:
			#Line.point(mesh.to_global(vert), 0.1, 0, Color.RED)
			broken += 1
			if(below_verts[tri_ind] == null):
				#print("count me!")
				below_verts[tri_ind] = [index]
			else:
				below_verts[tri_ind].push_back(index)
		
		if(tri_interior_ind == 2):
			if(broken):
				if(broken < 3):
					broken_tris[tri_ind] = tri_ind
				else:
					below_tris[tri_ind] = tri_ind
				broken = 0
			
			else:
				
				above_tris[tri_ind] = tri_ind
				print(tri_ind)
		i+=1
	
	print("ALL TRIS: ", tris, "\n")
	print("ABOVE TRIS: ", above_tris, "\n")
	#print("ABOVE INDICES: ", above_verts,"\n")
	print("BELOW TRIS: ", below_tris, "\n")
	print("BROKEN TRIS: ", broken_tris, "\n")
	print("BELOW VERTS: ", below_verts, "\n")
	
	var dirty_segments = []
	var dirty_coords = []
	var new_tris_above = []
	var new_tris_below = []
	new_tris_above.resize(tris.size())
	new_tris_below.resize(tris.size())
	
	for t in broken_tris.size():
		if(broken_tris[t] != null):

			var pre = get_tris_from_intersect(broken_tris[t], below_verts[t], tris, verts, mesh, plane)
			dirty_segments.push_back(pre[0])
			dirty_segments.push_back(pre[1])
			dirty_coords.push_back(pre[0][0])
			dirty_coords.push_back(pre[1][0])
	var inds = []
	for coord in dirty_coords.size():
		var x = dirty_coords.find(dirty_coords[coord], coord+1)
		if(x != -1):
			inds.push_back(coord)
			inds.push_back(x)
	
	print("\nDIRTY SEGMENTS: ", dirty_segments)
	var modded_indices = []

	for ind in range(0, inds.size()-1, 2):
		var d1 = dirty_segments[inds[ind]]
		var d2 = dirty_segments[inds[ind+1]]
		print("\nD1: ", d1, " - D2: ", d2, " - Inds: ", ind, "-",ind+1)
		if(d1[1] == d2[1] || d1[1] == d2[2]):
			print("BAD\n")
			dirty_segments[inds[ind]][3] = false
			dirty_segments[inds[ind+1]][3] = false
		else:
			modded_indices.push_back(dirty_segments[inds[ind]][1])
			modded_indices.push_back(dirty_segments[inds[ind+1]][1])
			
	
	for s in dirty_segments:
		if(!s[3]):
			
			if(!modded_indices.has(s[1])):
				print(s)
				modded_indices.push_back(s[1])
				s[3] = true
	print("MODDED INDICES: ", modded_indices, "\n")
	#print("DIRTY: ", dirty_segments)
	
	var M_ABOVE = surface.duplicate(true)
	var M_BELOW = surface.duplicate(true)
	var thing = []
	print()
	for seg in dirty_segments:
		if(seg[3]):
			if(!thing.has(seg[1])):
				thing.push_back(seg[1])
			pass
	print()
	
	var to_build_above = []
	for seg in dirty_segments:
		if(seg[3]):
			var f = seg[1]
			var s = seg[2]
			var to_replace = M_ABOVE[0][f]
			if(!to_build_above.has(f)):
				to_build_above.push_back([f, seg[0]])
			#Line.point(M_ABOVE[0][f], 0.1, 0, Color.GREEN)
			for p in M_ABOVE[0].size():
				if(M_ABOVE[0][p] == to_replace):
					M_ABOVE[0][p] = seg[0]
					#Line.point(seg[0])
			#print(to_replace)
			var to_replace_below = M_BELOW[0][s]
			for p in M_BELOW[0].size():
				if(M_BELOW[0][p] == to_replace_below):
					#M_BELOW[0][p] = seg[0]
					pass
			
	#print(M_ABOVE[0])
	#print(to_build_above)
	var rem_indices = []
	var index_values = []
	var sub_by = 0
	
	var empty = []
	
	for count in tris.size():
		if(above_tris[count] != null || broken_tris[count] != null):
			empty.push_back(tris[count])
	
	print(empty)
	var new_arr = []
	new_arr.resize(empty.size() * 3)
	for el in empty.size():
		print(el)
		new_arr[el * 3] = empty[el][0]
		new_arr[el * 3 + 1] = empty[el][1]
		new_arr[el * 3 + 2]  = empty[el][2]
		
		
	M_ABOVE[Mesh.ARRAY_INDEX] = PackedInt32Array(new_arr)
	print(new_arr," -- ", new_arr.size(), "\n")
	print(M_ABOVE[0])
	print(M_ABOVE[0].size())
	print()
	#for thi in new_arr:
		#print(thi, " - - - ", M_ABOVE[0][thi])
	
	
	#print(M_ABOVE[0][5])
	#print(M_ABOVE[0][10])
	#print(M_ABOVE[0][11])
	#for tri in below_tris:
		#if(tri):
			#print(tris[tri])
			#for index in tris[tri]:
				#rem_indices.push_back(index + sub_by)
			#	index_values.push_back(index)
				
				#sub_by -=1
	
	
	for v in index_values:
		M_ABOVE[1][v] = -plane.normal
	
	#print(arr)
	#M_ABOVE[Mesh.ARRAY_INDEX] = PackedInt32Array(arr)

	
	#M_ABOVE[Mesh.ARRAY_INDEX] = PackedInt32Array(new_indices)
	#for tri in above_tris:
		#if(tri):
			#for index in tris[tri]:
				#M_BELOW[1][index] = plane.normal
				
	#print("\nM_ABOVE: ", M_ABOVE)
	#print("\nM_BELOW: ", M_BELOW)
	var mesh1 = MeshInstance3D.new()
	
	var mesh2 = MeshInstance3D.new()
	
	var arrMeshAbove = ArrayMesh.new()
	
	var uniques = []
	modded_indices.sort()
	for v in modded_indices:
		print(v, " --- ", M_ABOVE[0][v])
		if(!uniques.has(M_ABOVE[0][v])):
			uniques.push_back(M_ABOVE[0][v])
	
	print("\nUNIQUES=-- ", uniques, " -- ", uniques.size(),"\n\n")
	var norms = []
	norms.resize(uniques.size())
	var mapit = func(item):
		return -plane.normal
	norms = uniques.map(mapit)
	var cut_face_indices = []
	#cut_face_indices.resize((uniques.size() - 1)*3)
	var ind = 0
	var last = uniques.size() - 1
	
	while ind < last:
		cut_face_indices.push_back(ind)
		cut_face_indices.push_back(ind+1)
		cut_face_indices.push_back(ind+2)
		
		
		cut_face_indices.push_back(last)
		cut_face_indices.push_back(ind)
		cut_face_indices.push_back(ind+2)
		ind+=2
		pass
	
	
	var CUT_SURFACE = []
	CUT_SURFACE.resize(Mesh.ARRAY_MAX)
	CUT_SURFACE[0] = PackedVector3Array(uniques)
	CUT_SURFACE[1] = PackedVector3Array(norms)
	CUT_SURFACE[Mesh.ARRAY_INDEX] = PackedInt32Array(cut_face_indices)
	print(CUT_SURFACE)
	arrMeshAbove.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, M_ABOVE)
	arrMeshAbove.surface_set_material(0, mesh.get_active_material(0))
	arrMeshAbove.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, CUT_SURFACE)
	if(melt_material):
		arrMeshAbove.surface_set_material(1, mesh.get_active_material(0))
		#arrMeshAbove.surface_set_material(1, melt_material)
	else:
		arrMeshAbove.surface_set_material(1, mesh.get_active_material(0))
	
	mesh1.mesh = arrMeshAbove
	#var newMesh = ArrayMesh.new()
		#print(new_meshes[0])
		#newMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_meshes[0])
	
	return {
		"ABOVE_CUT_MESH": arrMeshAbove,
		"BELOW_CUT_MESH": null
	}
	#print("\nDIRTY COORDS: ", dirty_coords )
	print("\nDIRTY SEGMENTS: ", dirty_segments)
	print("\nNEW TRIS ABOVE: ", new_tris_above)
	#print(collision)
	

func get_tris_from_intersect(_broken_tri_index:int, _below_verts:Array, _tris:Array, _verts:PackedVector3Array, _mesh, _plane: Plane):
	
	var intersect = [[Vector3.ZERO,0,0, true], [Vector3.ZERO,0,0, true]]
	
	var globalize = func(vec: Vector3):
		return _mesh.to_global(vec)
		
	var get_edges = func(above, below):
		var _c = 0
		var e = [[null,null], [null,null]]
		#print("\nABOVE: ", above, "BELOW: ", below)
		for ind in above:
			for ind2 in below:
				e[_c] = [ind, ind2]
				print(_verts[ind]," , ",_verts[ind2])
				_c += 1
		return e
		
		pass
	var above_verts = []
	
	for ind in _tris[_broken_tri_index]:
		if(_below_verts.has(ind)):
			pass
		else:
			above_verts.push_back(ind)
	
	
	var edges = get_edges.call(above_verts, _below_verts)
	var _i = 0
	for edge in edges:
		intersect[_i][0] = _mesh.to_local(_plane.intersects_segment(globalize.call(_verts[edge[0]]), globalize.call(_verts[edge[1]])))
		#Above point (this is the point that *shifts* position for that shape, i.e. the segment 0-1 w/ 0 above and 1 below and with breakpoint x forms 2 edges, 0-x (above), x-1 (below))
		intersect[_i][1] = edge[1]
		# Below point
		intersect[_i][2] = edge[0]
		#intersect[_i][3] = true
		
		_i += 1
	
	print(intersect)
	
	# What do we gotta do here-- taking the broken tris, we know which tris have been broken up.
	# We then take the below verts and know which ones of those are below-- we then construct
	# the edge(s) between the below verts and non-below verts to know which edges are broken.
	# Then, we convert the points in those edges to global relative to the mesh
	
	
	
	# Finally, we check where those edges intersect the plane. We now have the intersection point(s).
	# Now, we just reconstruct the tri, replacing the missing verts with our intersection points.
	
	
	
	return intersect	
	pass
