"""
	getmodel(bbin::String)
	getmodel(bbin::Array{Float64,1})

Return LAR model (V,EV,FV) of a box, aligned or not to axes.
"""
function Common.getmodel(bbin::String)
	# path of voume json
	return json2LARvolume(bbin)
end

function Common.getmodel(bbin::Array{Float64,1})
	# input format -> bbin = [x_min y_min z_min x_max y_max z_max ]
	bb = AABB(bbin[4], bbin[1], bbin[5], bbin[2], bbin[6], bbin[3])
	return Common.getmodel(bb)
end


"""
	searchfile(path::String,key::String)

In recursive mode, search all files in `path` with `key` in filename.
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
	mkdir_project(folder::String, project_name::String)

Create a new folder `project_name` in `folder`.
"""
function mkdir_project(folder::String, project_name::String)
	@assert isdir(folder) "$folder not an existing folder"
	proj_folder = joinpath(folder,project_name)

	mkdir_if(proj_folder)

	return proj_folder
end

"""
	mkdir_if(folder::String)

Create `folder` if not exist.
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
	source2pc(source::String, lod::Union{Nothing,Int64})

Get point cloud from source.
"""
function source2pc(source::String, lod=0::Int64)

	if isdir(source) # se source è un potree
		flushprintln("Read data from: Potree struct")
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
		flushprintln("Read data from: Single file")
		PC = FileManager.las2pointcloud(source)
		return PC
	end

end

"""
	successful(test::Bool,folder::String; message=""::String)
"""
function successful(test::Bool,folder::String; message=""::String, filename = "execution.probe")
	if test
		io = open(joinpath(folder,filename),"w")
		write(io, message)
		close(io)
	end
end


# """
# Read file line by line.
# """
# function get_directories(filepath::String)
# 	return readlines(filepath)
# end

# """
# 	boxmodelfromjson(volume::String)
#
# Read volume model from a file JSON.
# """
# function boxmodel_from_json(volume::String)
# 	V,EV,FV = json2LARvolume(volume)
# 	return V,EV,FV
# end
