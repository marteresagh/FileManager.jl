"""
Read file line by line.
"""
function get_directories(filepath::String)
	return readlines(filepath)
end

"""
	boxmodelfromjson(volume::String)

Read volume model from a file JSON.
"""
function boxmodel_from_json(volume::String)
	V,EV,FV = json2LARvolume(volume)
	return V,EV,FV
end

"""
Return LAR model (V,EV,FV) of a box, aligned or not to axes.
"""
# overload method of Common
function Common.getmodel(bbin::String)
	# path of voume json
	return boxmodel_from_json(bbin)
end

function Common.getmodel(bbin::Array{Float64,1})
	# in questo formato gli viene passato -> bbin = [x_min y_min z_min x_max y_max z_max ]
	bb = AABB(bbin[4], bbin[1], bbin[5], bbin[2], bbin[6], bbin[3])
	return Common.getmodel(bb)
end


"""
In recursive mode, search all files with key in filename.
"""
function searchfile(path::String,key::String)
	files = String[]
	for (root, _, _) in walkdir(path)
		thisfiles = filter(x->occursin(key,x), readdir(root,join=true))
		union!(files,thisfiles)
	end
	return files
end


"""
create folder of prject
"""
function mkdir_project(folder::String, project_name::String)
	@assert isdir(folder) "$folder not an existing folder"
	proj_folder = joinpath(folder,project_name)

	mkdir_if(proj_folder)

	return proj_folder
end

"""
folder
"""
function mkdir_if(folder::String)
	if !isdir(folder)
		mkdir(folder)
	end
end

"""
	clearfolder(folder::String)

Clear the given `folder`.
"""
function clearfolder(folder::String)
	root, dirs, files = first(walkdir(folder))
	for dir in dirs
		rm(joinpath(root,dir),recursive=true)
	end
	for file in files
		rm(joinpath(root,file))
	end
	return 1
end


"""
generate input point cloud
"""
function source2pc(source::String, lod::Union{Nothing,Int64})

	if isdir(source) # se source è un potree
		flushprintln("Potree struct")
		cloud_metadata = CloudMetadata(source)

		if lod == -1
			trie = potree2trie(source)
			max_level = FileManager.max_depth(trie)
			all_files = FileManager.get_all_values(trie)
			PC = FileManager.las2pointcloud(all_files...)
			return PC
		else
			all_files = FileManager.get_files_in_potree_folder(source,lod)
			PC = FileManager.las2pointcloud(all_files...)
			return PC
		end

	elseif isfile(source) # se source è un file
		PC = FileManager.las2pointcloud(source)
		return PC
	end

end

############################################# LOAD VECT 2D ################################
function get_plane_folders(folder::String,NAME_PROJ::String)
	folders = String[]
	for (root, dirs, files) in walkdir(joinpath(folder,NAME_PROJ))
		for dir in dirs
			folder_plane = joinpath(root,dir)
			push!(folders, folder_plane)
		end
	end
	return folders
end

function get_hyperplanes(folders::Array{String,1})
	hyperplanes = Hyperplane[]
	n_planes = length(folders)
	OBBs = Volume[]
	for i in 1:n_planes
		println("$i of $n_planes" )
		io = open(joinpath(folders[i],"finite_plane.txt"), "r")
		lines = readlines(io)
		close(io)

		b = [tryparse.(Float64,split(lines[i], " ")) for i in 1:length(lines)]
		normal = [b[1][1],b[1][2],b[1][3]]
		centroid = normal*b[1][4]
		inliers = FileManager.load_points(joinpath(folders[i],"inliers.txt"))

		hyperplane = Hyperplane(PointCloud(inliers[1:3,:],inliers[4:6,:]), normal, centroid)
		OBB = Volume([b[2][1],b[2][2],b[2][3]],[b[3][1],b[3][2],b[3][3]],[b[4][1],b[4][2],b[4][3]])
		push!(hyperplanes,hyperplane)
		push!(OBBs,OBB)
	end
	return hyperplanes, OBBs
end

function get_boundary(folders::Array{String,1})
	boundary = Lar.LAR[]
	full_boundary = Lar.LAR[]
	n_planes = length(folders)
	for i in 1:n_planes
		println("$i of $n_planes" )

		V = FileManager.load_points(joinpath(folders[i],"boundary_points.txt"))
		EV = FileManager.load_connected_components(joinpath(folders[i],"boundary_edges.txt"))
		model = (V,EV)
		push!(boundary,model)

		point_file = joinpath(folders[i],"full_boundary_points.txt")
		if isfile(point_file)
			V = FileManager.load_points(joinpath(folders[i],"full_boundary_points.txt"))
			EV = FileManager.load_connected_components(joinpath(folders[i],"full_boundary_edges.txt"))
			model = (V,EV)
			push!(full_boundary,model)
		end
	end

	return boundary, full_boundary
end

function get_all_inliers(folders::Array{String,1})
	las_full_inliers = String[]

	n_planes = length(folders)
	for i in 1:n_planes
		println("$i of $n_planes" )

		full_inliers = 	joinpath(folders[i],"full_inliers.las")
		if isfile(full_inliers)
			push!(las_full_inliers,full_inliers)
		end
	end

	return las_full_inliers
end

"""
	Read all data in vectorized_2D folder results.
"""
function read_all_data(folder::String,NAME_PROJ::String)
	OBBs = Volume[]
	hyperplanes = Hyperplane[]
	alpha_shapes = Lar.LAR[]
	full_alpha_shapes = Lar.LAR[]

	las_full_inliers = String[]

	folders = get_plane_folders(folder,NAME_PROJ)

	n_planes = length(folders)
	for i in 1:n_planes
		println("$i of $n_planes" )
		io = open(joinpath(folders[i],"finite_plane.txt"), "r")
		lines = readlines(io)
		close(io)

		b = [tryparse.(Float64,split(lines[i], " ")) for i in 1:length(lines)]
		normal = [b[1][1],b[1][2],b[1][3]]
		centroid = normal*b[1][4]
		inliers = FileManager.load_points(joinpath(folders[i],"inliers.txt"))

		hyperplane = Hyperplane(PointCloud(inliers[1:3,:],inliers[4:6,:]), normal, centroid)
		OBB = Volume([b[2][1],b[2][2],b[2][3]],[b[3][1],b[3][2],b[3][3]],[b[4][1],b[4][2],b[4][3]])

		V = FileManager.load_points(joinpath(folders[i],"boundary_points.txt"))
		EV = FileManager.load_connected_components(joinpath(folders[i],"boundary_edges.txt")) #FileManager.load_cells(joinpath(folder_plane,"boundary_edges.txt"))
		model = (V,EV)
		push!(hyperplanes,hyperplane)
		push!(OBBs,OBB)
		push!(alpha_shapes,model)

		full_inliers = 	joinpath(folders[i],"full_inliers.las")
		if isfile(full_inliers)
			push!(las_full_inliers,full_inliers)
		end

		full_shapes = 	joinpath(folders[i],"full_boundary_points.txt")
		if isfile(full_shapes)
			V = FileManager.load_points(joinpath(folders[i],"full_boundary_points.txt"))
			EV = FileManager.load_connected_components(joinpath(folders[i],"full_boundary_edges.txt")) #FileManager.load_cells(joinpath(folder_plane,"boundary_edges.txt"))
			model = (V,EV)
			push!(full_alpha_shapes,model)
		end
	end

	return folders, hyperplanes, OBBs, alpha_shapes, las_full_inliers, full_alpha_shapes
end

############################################# END LOAD VECT 2D ################################
