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
	return boxmodel_from_json(bbin)
end

function Common.getmodel(bbin::Array{Float64,1})
	# in questo formato gli viene passato -> bbin = [x_min y_min z_min x_max y_max z_max ]
	bb = AABB(bbin[4], bbin[1], bbin[5], bbin[2], bbin[6], bbin[3])
	return Common.boxmodel_from_aabb(bb)
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

	if !isdir(proj_folder)
		mkdir(proj_folder)
	end

	return proj_folder
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
