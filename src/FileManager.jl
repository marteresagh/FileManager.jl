__precompile__()

module FileManager

	# using PlyIO
	# using PyCall
    using Common
	import Common.AABB,Common.Cells,Common.Points,Common.Point
	import Common.getmodel
    using LasIO
    using LazIO
    using JSON
	using DataStructures
	using Dates
	using Printf

	# util
	include("struct.jl")
	include("utilities.jl")

	# save
	include("Save/json.jl")
	include("Save/las.jl")
	# include("Save/ply.jl")
	include("Save/txt.jl")
	#
	# load
	include("Load/hierarchy.jl")
	include("Load/txt.jl")
	include("Load/json.jl")
	# include("Load/ply.jl")
	include("Load/las.jl")
	#
	export potree2trie, las2pointcloud, getmodel, CloudMetadata # funs and structs
	export LasIO, LazIO, JSON, Dates, DataStructures # module
	export HEADER_SIZE, DATA_OFFSET, SIZE_DATARECORD # las global constant
end # module
