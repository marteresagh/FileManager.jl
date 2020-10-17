module FileManager

    using Common
    using LasIO
    using LazIO
    using JSON
	using DataStructures

	# struct
	include("struct.jl")

	# include code
    include("FileManager/hierarchy.jl")
	include("FileManager/json.jl")
	include("FileManager/las.jl")
	#include("FileManager/ply.jl")
	include("FileManager/txt.jl")
	include("FileManager/utilities.jl")

	export triepotree, las2pointcloud
end # module
