using Common
using FileManager
using Detection
using LightGraphs
using AlphaStructures
using Visualization

source = "C:/Users/marte/Documents/potreeDirectory/pointclouds/LACONTEA"
INPUT_PC = FileManager.source2pc(source,1)

centroid = Common.centroid(INPUT_PC.coordinates)

NAME_PROJ = "LA_CONTEA_LOD3"
folder = "C:/Users/marte/Documents/GEOWEB/TEST"

function boundary_points(folder,NAME_PROJ)
	hyperplanes = Hyperplane[]
	out = Array{Lar.Struct,1}()
	for (root, dirs, files) in walkdir(joinpath(folder,NAME_PROJ))
		for dir in dirs
			folder_plane = joinpath(root,dir)

			inliers = FileManager.load_points(joinpath(folder_plane,"inliers.txt"))[1:3,:]

			io = open(joinpath(folder_plane,"finite_plane.txt"), "r")
			point = readlines(io)
			close(io)
			b = [tryparse.(Float64,split(point[i], " ")) for i in 1:length(point)]
			plane = b[1]
			normal = [plane[1],plane[2],plane[3]]

			hyperplane = Hyperplane(PointCloud(inliers), normal, plane[4]*normal)
			push!(hyperplanes,hyperplane)

			W = FileManager.load_points(joinpath(folder_plane,"boundary_points.txt"))
			EW = FileManager.load_connected_components(joinpath(folder_plane,"boundary_edges.txt"))
			out = push!(out, Lar.Struct([(W, EW)]))


			# schiacciarli di nuovo

			break

		end
	end
	out = Lar.Struct(out)
	W,EW = Lar.struct2lar(out)
	return hyperplanes, W, EW
end


hyperplanes, W, EW = boundary_points(folder,NAME_PROJ)

i = 1
hyperplane = hyperplanes[i]
plane = Plane(hyperplane.direction,hyperplane.centroid)
points = Common.apply_matrix(plane.matrix,hyperplane.inliers.coordinates)[1:2,:]

GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,Common.apply_matrix(Lar.t(-centroid...),W)')),
	GL.GLGrid(Common.apply_matrix(Lar.t(-centroid...),W),EW,GL.COLORS[1],1.0),
])

V,FV = Common.DrawPlanes(hyperplanes, nothing, 0.0)

GL.VIEW([
	#Visualization.points_color_from_rgb(Common.apply_matrix(Lar.t(-centroid...),INPUT_PC.coordinates),INPUT_PC.rgbs),
	#GL.GLGrid(Common.apply_matrix(Lar.t(-centroid...),V),FV,GL.COLORS[1],0.8),
	GL.GLPoints(convert(Lar.Points,points'))
])



DT = Common.delaunay_triangulation(points)
filtration = AlphaStructures.alphaFilter(points,DT);
threshold = 0.5
threshold = Common.estimate_threshold(hyperplanes[1].inliers,5)
_, _, FV = AlphaStructures.alphaSimplex(points, filtration, threshold)

# 3. estrai bordo
EV_boundary = Common.get_boundary_edges(points,FV)
V,EV = Lar.simplifyCells(points,EV_boundary)

GL.VIEW([
	#Visualization.points_color_from_rgb(Common.apply_matrix(Lar.t(-centroid...),INPUT_PC.coordinates),INPUT_PC.rgbs),
	GL.GLGrid(V,EV,GL.COLORS[1],0.8),
	#GL.GLPoints(convert(Lar.Points,Common.apply_matrix(Lar.t(-centroid...),points)'))
])


# bug salvataggio o caricamento delle componenti

function indici(V,EV)
	indices = []
	g = Common.model2graph(V,EV)
	conn_comps = Common.LightGraphs.connected_components(g)
	for comp in conn_comps
		subgraph,vmap = Common.LightGraphs.induced_subgraph(g, comp)
		path = Common.LightGraphs.dfs_tree(subgraph, 1)
		edges = Common.LightGraphs.topological_sort_by_dfs(path)
		inds = vmap[edges]
		push!(indices,inds)
	end
	return indices
end

# problemi di componenti connesse in questi casi molto sporchi
indices = indici(V,EV)
FileManager.save_connected_components("prova.txt", V,EV)

EW = FileManager.load_connected_components("prova.txt")


GL.VIEW([
	#Visualization.points_color_from_rgb(Common.apply_matrix(Lar.t(-centroid...),INPUT_PC.coordinates),INPUT_PC.rgbs),
	GL.GLGrid(V,EV,GL.COLORS[2],0.8),
	GL.GLGrid(V,EW,GL.COLORS[1],0.8),
	#GL.GLPoints(convert(Lar.Points,Common.apply_matrix(Lar.t(-centroid...),points)'))
])


## Esempio di test grafo con loop

V = [8. 2 5 14 12 10 7 12; 2 5 10 9 2 4 6 8]
EV = [[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,6],[1,6]]
# EV = [[1,2],[2,3],[3,4],[4,5],[5,6],[6,1]]
