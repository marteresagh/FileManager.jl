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
	getmodel()

@override method of Common
Return LAR model (V,EV,FV) of a box, aligned or not to axes.
"""
function Common.getmodel(bbin::String)
	return boxmodel_from_json(bbin)
end

function Common.getmodel(bbin::Array{Float64,1})
	# in questo formato gli viene passato -> bbin = [x_min y_min z_min x_max y_max z_max ]
	bb = AABB(bbin[4], bbin[1], bbin[5], bbin[2], bbin[6], bbin[3])
	return Common.boxmodel_from_aabb(bb)
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
