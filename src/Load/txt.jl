"""
	load_segment(filename::String) -> LAR

Return segment from file.
"""
function load_segment(filename::String)::Common.LAR
    io = open(filename, "r")
    LINES = readlines(io)
    close(io)

    b = [tryparse.(Float64,split(LINES[i], " ")) for i in 1:length(LINES)]
    dim = Int(length(b[1])/2)
    V = hcat(reshape.(b,dim,2)...)
    EV = [[i,i+1] for i in range(1, size(V,2), step=2)]
    return V,EV
end

"""
	load_points(filename::String) -> Points

Return points from file.
"""
function load_points(filename::String)::Points
    io = open(filename, "r")
    point = readlines(io)
    close(io)

    b = [tryparse.(Float64,split(point[i], " ")) for i in 1:length(point)]
    V = hcat(b...)
    return V
end

"""
	load_cells(filename::String) -> Cells

Return cells from file.
"""
function load_cells(filename::String)::Cells
    io = open(filename, "r")
    cells = readlines(io)
    close(io)

    b = [tryparse.(Int64,split(cells[i], " ")) for i in 1:length(cells)]
    return b
end


# function load_hyperplane(filename::String)::Hyperplane
#     io = open(filename, "r")
#     point = readlines(io)
#     close(io)
#
#     b = [tryparse.(Float64,split(point[i], " ")) for i in 1:length(point)]
#     V = hcat(b...)
#
#     hyperplane = Hyperplane(PointCloud(V[:,3:end]), V[:,1],V[:,2])
#     return hyperplane
# end

# """
# 	load_connected_components(filename::String) -> Cells
#
# Load edges.
# """
# function load_connected_components(filename::String)::Cells
# 	EV = Array{Int64,1}[]
# 	io = open(filename, "r")
#     string_conn_comps = readlines(io)
#     close(io)
#
# 	conn_comps = [tryparse.(Float64,split(string_conn_comps[i], " ")) for i in 1:length(string_conn_comps)]
# 	for comp in conn_comps
# 		for i in 1:(length(comp)-1)
# 			push!(EV, [comp[i],comp[i+1]])
# 		end
# 		push!(EV,[comp[end],comp[1]])
# 	end
# 	return EV
# end
