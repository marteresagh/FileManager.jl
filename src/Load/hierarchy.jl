"""
Trie data structures for Potree hierarchy.
"""
function potree2trie(potree::String)
	#potree = path to potree folder project
	metadata = CloudMetadata(potree) # metadata of potree
	tree = potree*"\\"*metadata.octreeDir*"\\r" # path to directory "r"

	trie = DataStructures.Trie{String}()

	flushprintln("search in $tree ")

	# search all files
	if metadata.pointAttributes == "LAS"
		files = searchfile(tree,".las")
	elseif metadata.pointAttributes == "LAZ"
		files = searchfile(tree,".laz")
	else
		throw(DomainError(metadata.pointAttributes,"Format not yet allowed"))
	end

	# build trie from filename
	for file in files
		name = rsplit(splitdir(file)[2],".")[1]
		trie[name] = file
	end

	# root of potree
	return trie.children['r']
end

"""
maximum depth of trie
"""
function max_depth(trie::DataStructures.Trie{String})
	if length(trie.children) == 0
		return 0
	else
		depth = []
		for key in collect(keys(trie.children))
			push!(depth,max_depth(trie.children[key]))
		end
		return max(depth...) + 1
	end
end

"""
Return all files at that level of potree
"""
function truncate_trie(trie::DataStructures.Trie{String}, LOD::Int, data=String[]::Array{String,1}, l = 0::Int, all_prev = true::Bool)
	if all_prev
		if l<=LOD
			push!(data,trie.value)
			for key in collect(keys(trie.children))
				truncate_trie(trie.children[key],LOD,data,l+1,all_prev)
			end
		end
	else
		if l==LOD
			push!(data,trie.value)
		end
		for key in collect(keys(trie.children))
			truncate_trie(trie.children[key],LOD,data,l+1,all_prev)
		end
	end
	return data
end


"""
API
"""
function get_files_in_potree_folder(potree::String, LOD::Int, all_prev=true::Bool)
	trie = potree2trie(potree)
	return truncate_trie(trie, LOD, String[], 0, all_prev)
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
