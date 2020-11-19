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
Save extrema points of segment by row.
"""
function save_3D_lines_txt(filename::String, lines::Array{Hyperplane,1}, affine_matrix::Matrix)
	io = open(filename,"w")
	for line in lines
		V,_ = Common.DrawLine(line,0.0)
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
		V,_ = Common.DrawLine(line,0.0)
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
