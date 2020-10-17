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
	V,CV,FV,EV = PointClouds.volumemodelfromjson(volume)
	return V,EV,FV
end

"""
Return LAR model of the aligned axis box defined by `aabb`.
"""
function boxmodel_from_aabb(aabb::AABB)
	min,max = aabb
	V = [	aabb.x_min  aabb.x_min  aabb.x_min  aabb.x_min  aabb.x_max  aabb.x_max  aabb.x_max  aabb.x_max;
		 	aabb.y_min  aabb.y_min  aabb.y_max  aabb.y_max  aabb.y_min  aabb.y_min  aabb.y_max  aabb.y_max;
		 	aabb.z_min  aabb.z_max  aabb.z_min  aabb.z_max  aabb.z_min  aabb.z_max  aabb.z_min  aabb.z_max ]
	EV = [[1, 2],  [3, 4], [5, 6],  [7, 8],  [1, 3],  [2, 4],  [5, 7],  [6, 8],  [1, 5],  [2, 6],  [3, 7],  [4, 8]]
	FV = [[1, 2, 3, 4],  [5, 6, 7, 8],  [1, 2, 5, 6],  [3, 4, 7, 8],  [1, 3, 5, 7],  [2, 4, 6, 8]]
	return V,EV,FV
end

"""
	getmodel()

Return LAR model (V,EV,FV) of a box, aligned or not to axes.
"""
function getmodel(bbin::String)
	return boxmodel_from_json(bbin)
end

function getmodel(bbin::Array{Float64,1})
	# in questo formato gli viene passato -> bbin = [x_min y_min z_min x_max y_max z_max ]
	bb = AABB(bbin[4], bbin[1], bbin[5], bbin[2], bbin[6], bbin[3])
	return boxmodel_from_aabb(bb)
end

function getmodel(bbin::AABB)
	# in questo formato gli viene passato -> bbin = [x_min y_min z_min x_max y_max z_max ]
	return boxmodel_from_aabb(bbin)
end
"""
file tfw
"""
function save_tfw(output::String, GSD::Float64, lx::Float64, uy::Float64)
	fname = splitext(output)[1]
	io = open(fname*".tfw","w")
	write(io, "$(Float64(GSD))\n")
	write(io, "0.000000000000000\n")
	write(io, "0.000000000000000\n")
	write(io, "-$(Float64(GSD))\n")
	write(io, "$lx\n")
	write(io, "$uy\n")
	close(io)
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
