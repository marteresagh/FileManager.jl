function volume2json(filename::String, volume::Volume)
    scale = DataStructures.OrderedDict{String,Any}(
        "x" => volume.scale[1],
        "y" => volume.scale[2],
        "z" => volume.scale[3],
    )
    position = DataStructures.OrderedDict{String,Any}(
        "x" => volume.position[1],
        "y" => volume.position[2],
        "z" => volume.position[3],
    )
    rotation = DataStructures.OrderedDict{String,Any}(
        "x" => volume.rotation[1],
        "y" => volume.rotation[2],
        "z" => volume.rotation[3],
    )
    data = DataStructures.OrderedDict{String,Any}(
        "clip" => true,
        "name" => "volume",
        "scale" => scale,
        "position" => position,
        "rotation" => rotation,
        "permitExtraction" => true,
    )
    open(filename, "w") do f
        JSON.print(f, data, 4)
    end
end


#
# """
# Save file .JSON of the boundingbox in path.
# """
# function save_AABB2json(folder::String, aabb::AABB)
# 	@assert isdir(folder) "save_AABB2json: $path not a valid directory"
# 	name = splitdir(folder)[2]
# 	filename = name*".json"
# 	scale = DataStructures.OrderedDict{String,Any}("x"=>aabb.x_max-aabb.x_min, "y"=>aabb.y_max-aabb.y_min, "z"=>aabb.z_max-aabb.z_min)
# 	position = DataStructures.OrderedDict{String,Any}("x"=>(aabb.x_max+aabb.x_min)/2, "y"=>(aabb.y_max+aabb.y_min)/2, "z"=>(aabb.z_max+aabb.z_min)/2)
# 	rotation = DataStructures.OrderedDict{String,Any}("x"=>0., "y"=>0., "z"=>0.)
# 	data = DataStructures.OrderedDict{String,Any}("clip"=>true, "name"=>name,
# 			"scale"=>scale,"position"=>position,"rotation"=>rotation,
# 			"permitExtraction"=>true)
# 	open(joinpath(folder,filename),"w") do f
#   		JSON.print(f, data,4)
# 	end
# end



# """
# {
#    "object":"plane",
#    "normal":{
# 	  "x":0.000,
# 	  "y":0.000,
# 	  "z":1.000
#    },
#    "position":{
#       "x":0.0,
#       "y":0.0,
#       "z":0.0
#    },
# }
# """
# function plane2json(plane::Plane, filename::String)
# 	pos = plane.centroid
# 	dir = plane.normal
# 	position = DataStructures.OrderedDict{String,Any}("x"=>pos[1], "y"=>pos[2], "z"=>pos[3])
# 	normal = DataStructures.OrderedDict{String,Any}("x"=>dir[1], "y"=>dir[2], "z"=>dir[3])
# 	data = DataStructures.OrderedDict{String,Any}("object"=> "plane", "position"=>position,"normal"=>normal)
# 	open(filename,"w") do f
#   		JSON.print(f, data,4)
# 	end
# end

# """
# ============================================  CAMERA
# """
# function cameraparameters(path::String)
# 	dict=Dict{String,Any}[]
# 	open(path, "r") do f
# 	    dict = JSON.parse(f)  # parse and transform data
# 	end
# 	position = dict["position"]
# 	target = dict["target"]
# 	return position, target
# end

#function viewcoordinatesystem(camera)
#     position,target = camera
# 	up = [0,0,1.]
# 	dir = target-position
# 	x = -dir/Lar.norm(dir)
# 	if x != [0,0,1] && x != [0,0,-1]
# 		y = Lar.cross(x,up)
# 		z = Lar.cross(y,x)
# 	end
#     return [y';z';x']
# end
#
#
# function coordsystemcamera(file::String)
#     mat = PointClouds.cameramatrix(file)
#     return Matrix(mat[1:3,1:3]')
# end

# """
# camera parameters from JSON.
# """
# function cameramatrix(path::String)
# 	dict = Dict{String,Any}[]
# 	open(path, "r") do f
# 	    dict = JSON.parse(f)  # parse and transform data
# 	end
# 	mat = dict["object"]["matrix"]
# 	return [mat[1] mat[5] mat[9] mat[13];
# 			mat[2] mat[6] mat[10] mat[14];
# 			mat[3] mat[7] mat[11] mat[15];
# 			mat[4] mat[8] mat[12] mat[16]]
# end
#

# ====================================  read points for polygon
# """
# extract verteces from area tools.
# """
# function vertspolygonfromareaJSON(file::String)
# 	dict = Dict{String,Any}[]
# 	open(file, "r") do f
# 	    dict = JSON.parse(f)  # parse and transform data
# 	end
# 	features = dict["features"]
# 	for feature in features
# 		type = feature["geometry"]["type"]
# 		if type == "Polygon"
# 			points = feature["geometry"]["coordinates"]
# 			V = hcat(points[1][1:end-1]...)
# 			return V
# 		end
# 	end
# end
#
#
# """
# create polygon model.
# """
# function polygon(file::String)
# 	verts = vertspolygonfromareaJSON(file)
# 	EV = [[i,i+1] for i in 1:size(verts,2)-1]
# 	push!(EV,[size(verts,2),1])
# 	axis,centroid = PointClouds.planefit(verts)
# 	if Lar.dot(axis,Lar.cross(verts[:,1]-centroid,verts[:,2]-centroid))<0
# 		axis = -axis
# 	end
# 	PointClouds.projectpointson(verts,(axis,centroid),"plane")
# 	return verts,EV
# end
