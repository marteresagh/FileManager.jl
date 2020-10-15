"""
save lar model
"""
function saveply(f::String, model::Lar.LAR)
    io = open(f,"w")
        vts,fcs = model

        nV = size(vts,2)
        nF = length(fcs)
        nface = length(fcs[1])


        # write the header
        write(io, "ply\n")
        write(io, "format ascii 1.0\n")
        write(io, "element vertex $nV\n")
        write(io, "property float x\nproperty float y\nproperty float z\n")
        write(io, "element face $nF\n")
        write(io, "property list uchar int vertex_index\n")
        write(io, "end_header\n")

        # write the vertices and faces
        for i in 1:nV
            println(io, join(vts[:,i], " "))
        end
        for i in 1:nF
            println(io, nface, " ", join(fcs[i].-1, " "))
        end
    close(io)
end

"""
save point clouds
"""
function saveply(f::String, vertices::Lar.Points; normals=nothing, rgb=nothing)
	@assert endswith(f,".ply") "saveply: not .ply"
    io = open(f,"w")

    nV = size(vertices,2)

    # write the header
    write(io, "ply\n")
    write(io, "format ascii 1.0\n")
    write(io, "element vertex $nV\n")
    write(io, "property float x\nproperty float y\nproperty float z\n")

    if !isnothing(normals)
        write(io, "property float nx\nproperty float ny\nproperty float nz\n")
    end

    if !isnothing(rgb)
        write(io, "property uchar red\nproperty uchar green\nproperty uchar blue\n")
    end
    write(io, "end_header\n")

    # write the vertices and faces
    for i in 1:nV
		if normals==rgb
			println(io, join(vertices[:,i], " "))
		elseif !isnothing(normals)
	        println(io, join(vertices[:,i], " "), " ", join(normals[:,i], " "))
		elseif !isnothing(rgb)
	        println(io, join(vertices[:,i], " "), " ", join(floor.(Int,rgb[:,i].*255), " "))
		else
			println(io, join(vertices[:,i], " "), " ", join(normals[:,i], " "), " ", join(floor.(Int,rgb[:,i].*255), " "))
		end
    end
    close(io)
end


function saveply(f::String,vertices::Lar.Points,rgb::Array{LasIO.N0f16,2})
	PointClouds.saveply(f,vertices; rgb=rgb)
end

function saveply(f::String,vertices::Lar.Points,normals::Lar.Points)
	PointClouds.saveply(f,vertices; normals=normals)
end

function saveply(f::String,vertices::Lar.Points,normals::Lar.Points,rgb::Array{LasIO.N0f16,2})
	PointClouds.saveply(f,vertices; normals = normals, rgb = rgb)
end


"""
Save a file ASCII of AABB coordinates in a single row: x_min y_min z_min x_max y_max z_max. 
"""
function aabbASCII(folder::String,aabb::Tuple{Array{Float64,2},Array{Float64,2}})
	@assert isdir(folder) "aabbASCII: $folder not a valid directory"
	min,max = (aabb[1],aabb[2])
	name = splitdir(folder)[2]*".txt"

	open(joinpath(folder,name),"w") do f
		write(f,"$(min[1]) $(min[2]) $(min[3]) $(max[1]) $(max[2]) $(max[3])")
	end
	return 1
end
