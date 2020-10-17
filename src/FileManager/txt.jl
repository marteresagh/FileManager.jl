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
