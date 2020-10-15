"""
	readcloudJSON(path::String)

Read a file `.json`.
"""
function readcloudJSON(path::String)
	dict=Dict{String,Any}[]
	open(path * "\\cloud.js", "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	dictAABB = dict["boundingBox"]
	dicttightBB = dict["tightBoundingBox"]
	AABB = (hcat([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]]),
			hcat([dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]]))
	tightBB = (hcat([dicttightBB["lx"],dicttightBB["ly"],dicttightBB["lz"]]),
				hcat([dicttightBB["ux"],dicttightBB["uy"],dicttightBB["uz"]]))

	scale = dict["scale"]
	npoints = dict["points"]
    typeofpoints = dict["pointAttributes"]
	octreeDir = dict["octreeDir"]
	hierarchyStepSize = dict["hierarchyStepSize"]
	spacing = dict["spacing"]
	return typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing
end


"""
JSON struct of PC metadata.

{
   "version": "1.7",
   "octreeDir": "data",
   "projection": "",
   "points": 2502516,
   "boundingBox": {
	   "lx": 295370.8436816006,
	   "ly": 4781124.438537028,
	   "lz": 225.44601794335939,
	   "ux": 295632.16918208889,
	   "uy": 4781385.764037516,
	   "uz": 486.77151843164065
   },
   "tightBoundingBox": {
	   "lx": 295370.8436816006,
	   "ly": 4781124.438537028,
	   "lz": 225.44601794335939,
	   "ux": 295632.16918208889,
	   "uy": 4781376.7190012,
	   "uz": 300.3583829030762
   },
   "pointAttributes": "LAS",
   "spacing": 2.2631452083587648,
   "scale": 0.001,
   "hierarchyStepSize": 5
 }
"""
function cloud_metadata(path::String)
	dict=Dict{String,Any}[]
	open(path * "\\cloud.js", "r") do f
		dict = JSON.parse(f)  # parse and transform data
	end
	version = dict["version"]
	if version == "1.7"
		octreeDir = dict["octreeDir"]
		projection = dict["projection"]
		points = dict["points"]
		dictAABB = dict["boundingBox"]
		dicttightBB = dict["tightBoundingBox"]
		boundingBox = PointClouds.AxisAlignedBoundingBox(dictAABB["ux"],dictAABB["lx"],dictAABB["uy"],dictAABB["ly"],dictAABB["uz"],dictAABB["lz"])
		tightBoundingBox = PointClouds.AxisAlignedBoundingBox(dicttightBB["ux"],dicttightBB["lx"],dicttightBB["uy"],dicttightBB["ly"],dicttightBB["uz"],dicttightBB["lz"])

		# AABB = (hcat([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]]),
		# 		hcat([dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]]))
		# tightBB = (hcat([dicttightBB["lx"],dicttightBB["ly"],dicttightBB["lz"]]),
		# 			hcat([dicttightBB["ux"],dicttightBB["uy"],dicttightBB["uz"]]))

		pointAttributes = dict["pointAttributes"]
		spacing = dict["spacing"]
		scale = dict["scale"]
		hierarchyStepSize = dict["hierarchyStepSize"]

		return CloudMetadata(
								version,
								octreeDir,
								projection,
								points,
								boundingBox,
								tightBoundingBox,
								pointAttributes,
								spacing,
								scale,
								Int32(hierarchyStepSize)
							)
	end
end
"""
	volumeJSON(path::String)

Read a file `.json` of volume model.


# Example of a volume file json structure.

```
{
   "clip":true,
   "name":"name",
   "scale":{
      "x":1.,
      "y":1.,
      "z":1.
   },
   "position":{
   	  "x":0.,
	  "y":0.,
	  "z":0.
   },
   "rotation":{
      "x":0.,
      "y":0.,
      "z":0.
   },
   "permitExtraction":true
}
```
"""
function volumeJSON(path::String)
	dict = Dict{String,Any}[]

	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end

	return dict["position"],dict["scale"],dict["rotation"]
end


"""
	volumemodelfromjson(path::String)

Return LAR model of Potree volume tools.
"""
function volumemodelfromjson(path::String)
	@assert isfile(path) "volumemodelfromjson: $path not an existing file"

	position, scale, rotation = PointClouds.volumeJSON(path)
	V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.cuboid([1,1,1],true))
	mybox = (V,CV,FV,EV)
	scalematrix = Lar.s(scale["x"],scale["y"],scale["z"])
	rx = Lar.r(2*pi+rotation["x"],0,0); ry = Lar.r(0,2*pi+rotation["y"],0); rz = Lar.r(0,0,2*pi+rotation["z"])
	rot = rx * ry * rz
	trasl = Lar.t(position["x"],position["y"],position["z"])
	model = Lar.Struct([trasl,rot,scalematrix,mybox])
	return Lar.struct2lar(model) #V,CV,FV,EV
end


"""
Save file .JSON of the boundingbox in path.
"""
function savebbJSON(path::String, aabb::Tuple{Array{Float64,2},Array{Float64,2}})
	@assert isdir(path) "savebbJSON: $path not a valid directory"
	min,max = (aabb[1],aabb[2])
	name = splitdir(path)[2]*".json"
	scale = DataStructures.OrderedDict{String,Any}("x"=>max[1]-min[1], "y"=>max[2]-min[2], "z"=>max[3]-min[3])
	position = DataStructures.OrderedDict{String,Any}("x"=>(max[1]+min[1])/2, "y"=>(max[2]+min[2])/2, "z"=>(max[3]+min[3])/2)
	rotation = DataStructures.OrderedDict{String,Any}("x"=>0., "y"=>0., "z"=>0.)
	data = DataStructures.OrderedDict{String,Any}("clip"=>true, "name"=>name,
			"scale"=>scale,"position"=>position,"rotation"=>rotation,
			"permitExtraction"=>true)
	open(joinpath(path,name),"w") do f
  		JSON.print(f, data,4)
	end
end


"""
camera parameters from JSON.
"""
function cameraparameters(path::String)
	dict=Dict{String,Any}[]
	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	position = dict["position"]
	target = dict["target"]
	return position, target
end


"""
camera parameters from JSON.
"""
function cameramatrix(path::String)
	dict = Dict{String,Any}[]
	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	mat = dict["object"]["matrix"]
	return [mat[1] mat[5] mat[9] mat[13];
			mat[2] mat[6] mat[10] mat[14];
			mat[3] mat[7] mat[11] mat[15];
			mat[4] mat[8] mat[12] mat[16]]
end

"""
extract verteces from area tools.
"""
function vertspolygonfromareaJSON(file::String)
	dict = Dict{String,Any}[]
	open(file, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	features = dict["features"]
	for feature in features
		type = feature["geometry"]["type"]
		if type == "Polygon"
			points = feature["geometry"]["coordinates"]
			V = hcat(points[1][1:end-1]...)
			return V
		end
	end
end


"""
create polygon model.
"""
function polygon(file::String)
	verts = vertspolygonfromareaJSON(file)
	EV = [[i,i+1] for i in 1:size(verts,2)-1]
	push!(EV,[size(verts,2),1])
	axis,centroid = PointClouds.planefit(verts)
	if Lar.dot(axis,Lar.cross(verts[:,1]-centroid,verts[:,2]-centroid))<0
		axis = -axis
	end
	PointClouds.projectpointson(verts,(axis,centroid),"plane")
	return verts,EV
end


"""
	ucsJSON(path::String)

Read a file `.json` of UCS.


# Example of a UCS file json structure.

```
{

	"id":"270b6b7a-d00c-46f6-ba58-1c76310558aa",

	"data":{

		"plane":{

			"A":0,

			"B":0,

			"C":0

		},

		"xAxis":{

			"x":0.21194956712662227,

			"y":-0.9771563332378362,

			"z":-0.015584652964510243

		},

		"yAxis":{

			"x":0.007193328934240251,

			"y":-0.014386657868480502,

			"z":0.9998706316790285

		},

		"zAxis":{

			"x":-0.9772541312338778,

			"y":-0.21203425310209192,

			"z":0.003979761017532582

		},

		"origin":{

			"x":2.250469923019409,

			"y":-6.521675497293472,

			"z":-1.4895449578762054

		}

	},

	"name":"XY_PIANO_FINESTRA"

}
```
"""
function readUcsJSON(file::String)
	dict = Dict{String,Any}[]

	open(file, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end

	return dict
end

function ucsJSON2matrix(file::String)
	dict = readUcsJSON(file)

	origin = dict["data"]["origin"]
	xAxis = dict["data"]["xAxis"]
	yAxis = dict["data"]["yAxis"]
	zAxis = dict["data"]["zAxis"]
	M =  zeros(4,4)

	M[1,1] = xAxis["x"]
	M[1,2] = xAxis["y"]
	M[1,3] = xAxis["z"]

	M[2,1] = yAxis["x"]
	M[2,2] = yAxis["y"]
	M[2,3] = yAxis["z"]

	M[3,1] = zAxis["x"]
	M[3,2] = zAxis["y"]
	M[3,3] = zAxis["z"]

	O = M[1:3, 1:3] * -[origin["x"], origin["y"], origin["z"]]
	M[1,4] = O[1]
	M[2,4] = O[2]
	M[3,4] = O[3]

	M[4,4] = 1.0
	return M
end



"""
measure JSON from Potree 1.6
"""
function seedPointsFromFile(path::String)
	dataset = Matrix[]
	dict=Dict{String,Any}[]
	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end

	objects = dict["features"]

	for obj in objects
		geometry = obj["geometry"]
		if geometry["type"] == "Polygon"
			coords = []
			vec_coords = geometry["coordinates"][1]
			for element in vec_coords
				push!(coords,element)
			end
			mycoords = hcat(coords...)
			push!(dataset,mycoords)
		end
	end
	return dataset
end


"""
{
   "object":"plane",
   "normal":{
	  "x":0.000,
	  "y":0.000,
	  "z":1.000
   },
   "position":{
      "x":0.0,
      "y":0.0,
      "z":0.0
   },
}
"""
function plane2json(plane::Plane, filename::String)
	pos = plane.centroid
	dir = plane.normal
	position = DataStructures.OrderedDict{String,Any}("x"=>pos[1], "y"=>pos[2], "z"=>pos[3])
	normal = DataStructures.OrderedDict{String,Any}("x"=>dir[1], "y"=>dir[2], "z"=>dir[3])
	data = DataStructures.OrderedDict{String,Any}("object"=> "plane", "position"=>position,"normal"=>normal)
	open(filename,"w") do f
  		JSON.print(f, data,4)
	end
end
