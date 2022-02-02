# function save_dxf_vect3D(path_points_fitted, path_points_unfitted, path_polygons, filename)
#
# 	# leggi i vari file che ti servono e converti
# 	pc_fitted = FileManager.source2pc(path_points_fitted)
# 	points_fitted = pc_fitted.coordinates #decimare TODO
#
# 	pc_unfitted = FileManager.source2pc(path_points_unfitted)
# 	points_unfitted = pc_unfitted.coordinates #decimare TODO
#
# 	ezdxf = pyimport("ezdxf")
# 	doc = ezdxf.new()
# 	msp = doc.modelspace()
# 	fitted = "fitted"
# 	unfitted = "unfitted"
# 	model = "model"
#
# 	for i in 1:size(points_fitted,2)
# 		point = points_fitted[:,i]
# 		p = (point[1],point[2],point[3])
# 		msp.add_point(
# 		   p,
# 		   dxfattribs=py"{
# 		   		'layer': $fitted,
# 			    'color': 3,
# 		   }"o,
# 	   )
# 	end
#
# 	for i in 1:size(points_unfitted,2)
# 		point = points_unfitted[:,i]
# 		p = (point[1],point[2],point[3])
# 		msp.add_point(
# 		   p,
# 		   dxfattribs=py"{
# 				'layer': $unfitted,
# 				'color': 1,
# 		   }"o,
# 	   )
# 	end
#
# 	poly = msp.add_polyface()
# 	for dir in readdir(folder)
# 		V = FileManager.load_points(joinpath(folder,dir,"points3D.txt"))
# 		io = open(joinpath(folder,dir,"edges.txt"), "r")
# 	    LINES = readlines(io)
# 	    close(io)
# 		color = 6
# 		plane = Common.Plane(V)
#
# 		if Common.abs(Common.dot(plane.normal,[0.0,0.0,1.])) > 0.9
# 			color = 4
# 		elseif Common.abs(Common.dot(plane.normal,[.0,0.0,1.])) < 0.1
# 			color = 5
# 		end
#
# 		for line in LINES
# 			idx_cycle = parse(Int,line)
# 			points = V[:, idx_cycle]
# 			tuples = [(p[1],p[2],p[3]) for p[:] in eachcol(points)]
# 			poly.append_face(tuples, dxfattribs=py"{'layer': $model, 'color': $color}"o)
# 		end
# 	end
#
# 	doc.saveas(filename)
#
# end
