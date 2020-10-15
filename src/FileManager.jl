module FileManager

    using Common
	using LinearAlgebraicRepresentation
	Lar = LinearAlgebraicRepresentation
    using LasIO
    using LazIO
    using JSON

	# struct
	include("struct.jl")

	# include code
    dirs = readdir("src")
	for dir in dirs
		name = joinpath("src",dir)
    	if isdir(name)
			for (root,folders,files) in walkdir(name)
				for file in files
					head = splitdir(root)[2]
					#@show joinpath(head,file)
				 	include(joinpath(head,file))
				end
			end
		end
	end

end # module
