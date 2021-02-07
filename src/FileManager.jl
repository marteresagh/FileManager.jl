__precompile__()

module FileManager

    using Common
    using LasIO
    using LazIO
    using JSON
	using PlyIO
	using DataStructures
	using Dates
	using Printf

	# util
	include("struct.jl")
	include("utilities.jl")

	# save
	include("Save/json.jl")
	include("Save/las.jl")
	include("Save/ply.jl")
	include("Save/txt.jl")


	# load
	include("Load/hierarchy.jl")
	include("Load/txt.jl")
	include("Load/json.jl")
	include("Load/ply.jl")
	include("Load/las.jl")

	export potree2trie, las2pointcloud, DataStructures, LasIO, LazIO, JSON, getmodel, CloudMetadata, Dates
			HEADER_SIZE, DATA_OFFSET, SIZE_DATARECORD
end # module
