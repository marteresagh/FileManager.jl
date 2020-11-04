__precompile__()

module FileManager

    using Common
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
	include("FileManager/json.jl")
	include("FileManager/las.jl")
	#include("FileManager/ply.jl")
	include("FileManager/txt.jl")


	# load
	include("Load/hierarchy.jl")
	include("Load/txt.jl")
	include("Load/json.jl")
	include("Load/las.jl")

	export potree2trie, las2pointcloud, LasIO, LazIO, JSON, getmodel, CloudMetadata,
			HEADER_SIZE, DATA_OFFSET, SIZE_DATARECORD
end # module
