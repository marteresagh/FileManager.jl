"""
json2volume(path::String)

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
function json2volume(path::String)
	dict = Dict{String,Any}[]

	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end

	position = dict["position"]
	scale = dict["scale"]
	rotation = dict["rotation"]

	return Volume(  [scale["x"],scale["y"],scale["z"]],
					[position["x"],position["y"],position["z"]],
					[rotation["x"],rotation["y"],rotation["z"]]
				)
end


"""
	json2LARvolume(path::String)

Return LAR model of Potree volume tools.
"""
function json2LARvolume(path::String)
	@assert isfile(path) "json2LARvolume: $path not an existing file"

	volume = json2volume(path)
	return Common.getmodel(volume::Volume)
end


"""
	json2ucs(file::String)

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
function json2ucs(file::String)
	dict = Dict{String,Any}[]

	open(file, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end

	return dict
end

function ucs2matrix(file::String)
	dict = json2ucs(file)

	origin = dict["data"]["origin"]
	xAxis = dict["data"]["xAxis"]
	yAxis = dict["data"]["yAxis"]
	zAxis = dict["data"]["zAxis"]

	O = [origin["x"],origin["y"],origin["z"]]
	axis_x = [xAxis["x"],xAxis["y"],xAxis["z"]]
	axis_y = [yAxis["x"],yAxis["y"],yAxis["z"]]
	axis_z = [zAxis["x"],zAxis["y"],zAxis["z"]]
	rot = hcat(axis_x, axis_y, axis_z)
	M = Common.matrix4(rot)
	M[1:3,4] = O
	return Common.Lar.inv(M)
end

#
# """
# measure JSON from Potree 1.6
# """
# function seedPointsFromFile(path::String)
# 	dataset = Matrix[]
# 	dict=Dict{String,Any}[]
# 	open(path, "r") do f
# 	    dict = JSON.parse(f)  # parse and transform data
# 	end
#
# 	objects = dict["features"]
#
# 	for obj in objects
# 		geometry = obj["geometry"]
# 		if geometry["type"] == "Polygon"
# 			coords = []
# 			vec_coords = geometry["coordinates"][1]
# 			for element in vec_coords
# 				push!(coords,element)
# 			end
# 			mycoords = hcat(coords...)
# 			push!(dataset,mycoords)
# 		end
# 	end
# 	return dataset
# end
