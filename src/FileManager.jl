module FileManager

    using Common
    using LasIO
    using LazIO
    using JSON

	# struct
	include("struct.jl")

	# include code
    include("FileManager/hierarchy.jl")
	include("FileManager/json.jl")
	include("FileManager/las.jl")
	#include("FileManager/ply.jl")
	include("FileManager/utilities.jl")

	export triepotree
end # module
