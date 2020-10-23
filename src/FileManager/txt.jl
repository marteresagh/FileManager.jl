function save_points_txt(filename::String,V::Lar.Points)
	io = open(filename,"w")

	for i in 1:size(V,2)
		write(io, "$(V[1,i]) $(V[2,i]) $(V[3,i])\n")
	end

	close(io)
end

"""
save points of segment by row
"""
function save_lines_txt(filename::String, lines::Array{Hyperplane,1}, quota = 0.0)
	io = open(filename,"w")
	for line in lines
		V,_ = Common.DrawLine(line,0.0)
		V3D = vcat(V,(quota.*ones(size(V,2)))')
		write(io, "$(V3D[1,1]) $(V3D[2,1]) $(V3D[3,1]) $(V3D[1,2]) $(V3D[2,2]) $(V3D[3,2])\n")
	end

	close(io)
end

"""
"""
#TODO da scrivire generica
function savePlane(hyperplane::Hyperplane, filename::String)
	# plane2json(plane::Plane, filename::String)  JSON FORMAT
	io = open(filename,"w")
	write(io, "$(plane.normal[1]) $(plane.normal[2]) $(plane.normal[3]) ")
	write(io, "$(plane.centroid[1]) $(plane.centroid[2]) $(plane.centroid[3])")
	close(io)
end


function save_points_rgbs_txt(filename::String, PC::PointCloud)
	io = open(filename,"w")
	RGB = convert(Array{Int32,2},floor.(PC.rgbs*255))
	for i in 1:PC.n_points
		V = PC.coordinates
		write(io, "$(V[1,i]) $(V[2,i]) $(V[3,i]) $(RGB[1,i]) $(RGB[2,i]) $(RGB[3,i])\n")
	end

	close(io)
end
