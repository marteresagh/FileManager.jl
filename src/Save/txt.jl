
"""
Save points by row in file .txt.
"""
function save_points_txt(filename::String,V::Lar.Points)
	io = open(filename,"w")

	for i in 1:size(V,2)
		for j in 1:size(V,1)

			if j == size(V,1)
				write(io, "$(V[j,i])")
			else
				write(io, "$(V[j,i]) ")
			end

		end
		write(io, "\n")
	end

	close(io)
end

"""
Save cells by row in file .txt.
"""
function save_cells_txt(filename::String,EV::Lar.Cells)
	io = open(filename,"w")
	dim_cell = length(EV[1])

	for i in 1:length(EV)
		for j in 1:dim_cell

			if j == dim_cell
				write(io, "$(EV[i][j])")
			else
				write(io, "$(EV[i][j]) ")
			end

		end
		write(io, "\n")
	end

	close(io)
end

"""
Save extrema points of segment by row.
"""
function save_3D_lines_txt(filename::String, lines::Array{Hyperplane,1}, affine_matrix::Matrix)
	io = open(filename,"w")
	for line in lines
		V,_ = Common.DrawLines(line)
		V1 = vcat(V,(zeros(size(V,2)))')
		V3D = Common.apply_matrix(affine_matrix,V1)
		write(io, "$(V3D[1,1]) $(V3D[2,1]) $(V3D[3,1]) $(V3D[1,2]) $(V3D[2,2]) $(V3D[3,2])\n")
	end

	close(io)
end

"""
Save extrema points of segment by row.
"""
function save_2D_lines_txt(filename::String, lines::Array{Hyperplane,1})
	io = open(filename,"w")
	for line in lines
		V,_ = Common.DrawLines(line)
		write(io, "$(V[1,1]) $(V[2,1]) $(V[1,2]) $(V[2,2])\n")
	end

	close(io)
end


"""
Save point cloud by row: "x y z r g b".
"""
function save_points_rgbs_txt(filename::String, PC::PointCloud)
	io = open(filename,"w")
	RGB = convert(Array{Int32,2},floor.(PC.rgbs*255))
	for i in 1:PC.n_points
		V = PC.coordinates
		for j in 1:PC.dimension
			write(io, "$(V[j,i]) ")
		end
		for j in 1:3
			if j == 3
				write(io, "$(RGB[j,i])")
			else
				write(io, "$(RGB[j,i]) ")
			end
		end
		write(io, "\n")
	end

	close(io)
end


"""
file tfw
"""
function save_tfw(output::String, GSD::Float64, lx::Float64, uy::Float64)
	fname = splitext(output)[1]
	io = open(fname*".tfw","w")
	write(io, "$(Float64(GSD))\n")
	write(io, "0.000000000000000\n")
	write(io, "0.000000000000000\n")
	write(io, "-$(Float64(GSD))\n")
	L=@sprintf("%f", lx)
	U=@sprintf("%f", uy)
	write(io, "$L\n")
	write(io, "$U\n")
	close(io)
end
#
# """
# """
# function save_hyperplane(filename::String, hyperplane::Hyperplane)
# 	V = hyperplane.inliers.coordinates
# 	dir = hyperplane.direction
# 	cen = hyperplane.centroid
# 	dim = length(dir)
#
# 	io = open(filename,"w")
#
# 	for j in 1:dim
# 		if j == dim
# 			write(io, "$(dir[j])")
# 		else
# 			write(io, "$(dir[j]) ")
# 		end
# 	end
#
# 	write(io, "\n")
#
# 	for j in 1:dim
# 		if j == dim
# 			write(io, "$(cen[j])")
# 		else
# 			write(io, "$(cen[j]) ")
# 		end
# 	end
#
# 	write(io, "\n")
#
# 	for i in 1:size(V,2)
# 		for j in 1:size(V,1)
#
# 			if j == size(V,1)
# 				write(io, "$(V[j,i])")
# 			else
# 				write(io, "$(V[j,i]) ")
# 			end
#
# 		end
# 		write(io, "\n")
# 	end
#
# 	close(io)
# end
#


"""
	 save_connected_components(filename::String, V::Lar.Points, EV::Lar.Cells)

Saves connected components of model by row.
"""
function save_connected_components(filename::String, V::Lar.Points, EV::Lar.Cells)

	io = open(filename,"w")

	graph = Common.model2graph_edge2edge(V,EV)
	comps = LightGraphs.connected_components(graph)

	points = Int64[]
	for comp in comps
		ext = Common.get_boundary_points(V,EV[comp])
		if length(ext) == 2
			push!(points,ext...)
			# push!(EV,ext)
		end
	end


	T = V[:,points]
	kdtree = Common.KDTree(T)
	for p in 1:length(points)
		idxs,dists = Common.knn(kdtree, T[:,p], 1, true, i -> i == p)
		push!(EV,[points[p],points[idxs[1]]])
	end


	g = Common.model2graph(V,EV)

	conn_comps = Common.LightGraphs.connected_components(g)
	for comp in conn_comps
		subgraph,vmap = LightGraphs.induced_subgraph(g, comp)
		dg = Common.makes_direct(subgraph,1)
		cycles = LightGraphs.simplecycles(dg)
		for cycle in cycles
			inds = vmap[cycle]
			for ind in inds[1:end-1]
				write(io,"$ind ")
			end
			write(io,"$(inds[end])\n")
		end
	end

	close(io)
end
