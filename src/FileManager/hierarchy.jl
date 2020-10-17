"""
Trie data structures for Potree hierarchy.
"""
function potree2trie(potree::String)
	metadata = CloudMetadata(potree) # useful parameters
	tree = potree*"\\"*metadata.octreeDir*"\\r" # path to directory "r"

	trie = DataStructures.Trie{String}()

	flushprintln("search in $tree ")

	# 2.- check all file
	if metadata.pointAttributes == "LAS"
		files = searchfile(tree,".las")
	elseif metadata.pointAttributes == "LAZ"
		files = searchfile(tree,".laz")
	else
		throw(DomainError(metadata.pointAttributes,"Format not yet allowed"))
	end

	for file in files
		name = rsplit(splitdir(file)[2],".")[1]
		trie[name] = file
	end

	return trie.children['r']
end




"""

"""
function read_file_in_potree_folder(path::String, lev::Int, allprev=true)
	metadata = CloudMetadata(path) # useful parameters
	pathr = path*"\\"*metadata.octreeDir*"\\r" # path to directory "r"

	println("==== Start search in $pathr ====")

	# 2.- check all file
	all_files = String[]

	for (root, dirs, files) in walkdir(pathr)
		for file in files
			if endswith(file, ".las") || endswith(file, ".laz")
				name = rsplit(file,".")[1]
				level = []
				for i in name
					if isnumeric(i)
						push!(level,i)
					end
				end
				if !allprev
					if length(level)==lev
						push!(all_files,joinpath(root, file))
					end
				else
					if length(level)<=lev
						push!(all_files,joinpath(root, file))
					end
				end
			end
		end
	end
	return all_files
end



# """
# Read file .hrc of potree hierarchy.
# """
# function readhrc(potree::String)
#
# 	typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters togli quelli che non usi
# 	tree = joinpath(potree,octreeDir,"r") # path to directory "r"
# 	hrcs = PointClouds.searchfile(tree,".hrc")
#
# 	for hrc in hrcs
# 		raw = read(hrc)
# 		treehrc = reshape(raw, (5, div(length(raw), 5)))
#
# 		for i in 1:size(treehrc,2)
# 			children = bitstring(UInt8(treehrc[1,i]))
# 			npoints = parse(Int, bitstring(UInt8(treehrc[5,i]))*bitstring(UInt8(treehrc[4,i]))*bitstring(UInt8(treehrc[3,i]))*bitstring(UInt8(treehrc[2,i])); base=2)
# 			#struct da finire
# 		end
# 	end
#
# 	return treehrc
# end
