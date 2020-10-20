__precompile__()

module FileManager

    using Common
    using LasIO
    using LazIO
    using JSON
	using DataStructures
	using Dates

	# struct
	include("struct.jl")

	# include code
    include("FileManager/hierarchy.jl")
	include("FileManager/json.jl")
	include("FileManager/las.jl")
	#include("FileManager/ply.jl")
	include("FileManager/txt.jl")
	include("FileManager/utilities.jl")

	export potree2trie, las2pointcloud, LasIO, LazIO, JSON, getmodel, CloudMetadata,
			HEADER_SIZE, DATA_OFFSET, SIZE_DATARECORD
end # module
