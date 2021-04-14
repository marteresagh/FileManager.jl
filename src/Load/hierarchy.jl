"""
	potree2trie(potree::String)

Trie data structures for Potree hierarchy:
 - each file in octree directory is stored in a node,
 - first node is `r`, root of potree.
"""
function potree2trie(potree::String)
	#potree = path to potree folder project
	metadata = CloudMetadata(potree) # metadata of potree
	tree = joinpath(potree,metadata.octreeDir,"r") # path to octree files

	trie = DataStructures.Trie{String}()

	flushprintln(" ")
	flushprintln("Search in $tree")

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
	max_depth(trie::DataStructures.Trie{String}) -> Int

Maximum depth of trie.
"""
function max_depth(trie::DataStructures.Trie{String})::Int
	if length(trie.children) == 0
		return 0
	else
		depth = Int[]
		for key in collect(keys(trie.children))
			push!(depth,max_depth(trie.children[key]))
		end
		return max(depth...) + 1
	end
end

"""
	cut_trie!(trie::DataStructures.Trie{String}, LOD::Int, l = 0::Int)

Return truncated trie.
"""
function cut_trie!(trie::DataStructures.Trie{String}, LOD::Int, l = 0::Int)
	if l >= LOD
		empty!(trie.children) #delete all children
	end
	for key in collect(keys(trie.children))
		cut_trie!(trie.children[key], LOD, l+1) # next level
	end
end

"""
	get_all_values(trie::DataStructures.Trie{String}) -> Array{String,1}

Return a collection of all values in trie.
"""
function get_all_values(trie::DataStructures.Trie{String})::Array{String,1}
	key_s = collect(keys(trie))
	data = Array{String,1}(undef,length(key_s))
	for i in 1:length(key_s)
		data[i] = trie[key_s[i]]
	end
	return data
end

"""
	sub_trie(t::DataStructures.Trie{String}, root::AbstractString) -> DataStructures.Trie

Return the subtrie with defined `root` node.
"""
function sub_trie(t::DataStructures.Trie{String}, root::AbstractString)::DataStructures.Trie
	return subtrie(t, root[2:end])
end

# =====================
"""
Return all files at that level of potree
"""
function get_files_in_potree_folder(potree::String, LOD::Int, all_prev=true::Bool)::Array{String,1}
	trie = potree2trie(potree)
	return get_files(trie, LOD, String[], 0, all_prev)
end

"""
Accumulate all values from root to defined level `LOD`.
"""
function get_files(trie::DataStructures.Trie{String}, LOD::Int, data=String[]::Array{String,1}, l = 0::Int, all_prev = true::Bool)::Array{String,1}
	if all_prev
		if l<=LOD
			push!(data,trie.value)
			for key in collect(keys(trie.children))
				get_files(trie.children[key],LOD,data,l+1,all_prev)
			end
		end
	else
		if l==LOD
			push!(data,trie.value)
		end

		if l<LOD
			for key in collect(keys(trie.children))
				get_files(trie.children[key],LOD,data,l+1,all_prev)
			end
		end
	end
	return data
end


# """
# Trie DFS.
# """
# function dfs(trie)
# 	file = t.value
# 	@show file
# 	for key in collect(keys(t.children))
# 		dfs(trie.children[key])
# 	end
# end

# """
# Read file .hrc of potree hierarchy.
# """
# function readhrc(potree::String)
#
# 	cloudmetadata = CloudMetadata(potree)
# 	tree = joinpath(potree,cloudmetadata.octreeDir,"r") # path to directory "r"
# 	hrcs = searchfile(tree,".hrc")
#
# 	for hrc in hrcs
# 		raw = read(hrc)
# 		treehrc = reshape(raw, (5, div(length(raw), 5)))
#
# 		for i in 1:size(treehrc,2)
# 			children = bitstring(UInt8(treehrc[1,i]))
# 			npoints = parse(Int, bitstring(UInt8(treehrc[5,i]))*bitstring(UInt8(treehrc[4,i]))*bitstring(UInt8(treehrc[3,i]))*bitstring(UInt8(treehrc[2,i])); base=2)
# 			#struct da finire
# 			@show children, npoints
# 		end
# 	end
#
# end
