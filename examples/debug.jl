using Common
using FileManager
using Visualization

file = "C:/Users/marte/Documents/GEOWEB/wrapper_file/sezioni/sezioneUIPotree_CC.las"
PC = FileManager.las2pointcloud(file)

GL.VIEW([
	Visualization.points_color_from_rgb(Common.apply_matrix(Lar.t(-Common.centroid(PC.coordinates)...),PC.coordinates), PC.rgbs)
])


NAME_PROJ = "MURI"
folder = "C:/Users/marte/Documents/GEOWEB/TEST"

function read_data_vect2D(folder::String,NAME_PROJ::String)
	OBBs = Volume[]
	hyperplanes = Hyperplane[]
	alpha_shapes = Lar.LAR[]
	for (root, dirs, files) in walkdir(joinpath(folder,NAME_PROJ))
		for dir in dirs
			if dir!="PLANES"
				folder_plane = joinpath(root,dir)

				io = open(joinpath(folder_plane,"finite_plane.txt"), "r")
				lines = readlines(io)
				close(io)

				b = [tryparse.(Float64,split(lines[i], " ")) for i in 1:length(lines)]
				normal = [b[1][1],b[1][2],b[1][3]]
				centroid = normal*b[1][4]
				inliers = FileManager.load_points(joinpath(folder_plane,"inliers.txt"))

				hyperplane = Hyperplane(PointCloud(inliers[1:3,:],inliers[4:6,:]), normal, centroid)
				OBB = Volume([b[2][1],b[2][2],b[2][3]],[b[3][1],b[3][2],b[3][3]],[b[4][1],b[4][2],b[4][3]])

				V = FileManager.load_points(joinpath(folder_plane,"boundary_points.txt"))
				EV = FileManager.load_connected_components(joinpath(folder_plane,"boundary_edges.txt")) #FileManager.load_cells(joinpath(folder_plane,"boundary_edges.txt"))
				model = (V,EV)
				push!(hyperplanes,hyperplane)
				push!(OBBs,OBB)
				push!(alpha_shapes,model)
			end
		end
	end

	las_full_inliers = FileManager.searchfile(joinpath(joinpath(folder,NAME_PROJ),"PLANES"),".las")

	###############################################################
	# for file in las_full_inliers
	# 	h,_ = LasIO.FileIO.load(file)
	# 	if h.records_count > 1000
	# 		PC = FileManager.las2pointcloud(file)
	# 		points = PC.coordinates
	# 		aabb = Common.boundingbox(points)
	# 		obb = Common.ch_oriented_boundingbox(points)
	# 		plane = Plane(points)
	# 		push!(planes,plane)
	# 		push!(AABBs,aabb)
	# 		push!(OBBs,obb)
	# 	end
	# end
	###############################################################

	return hyperplanes, OBBs, alpha_shapes, las_full_inliers
end

hyperplanes, OBBs, alpha_shapes = FileManager.read_data_vect2D(folder::String,NAME_PROJ::String)

V,FV = Common.DrawPlanes(hyperplanes; box_oriented = false)
centroid = Common.centroid(V)

GL.VIEW([
	GL.GLGrid(Common.apply_matrix(Lar.t(-centroid...),V),FV,GL.COLORS[1],0.8)
])
