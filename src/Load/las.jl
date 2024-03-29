"""
	las2pointcloud(fnames::String...) -> PointCloud

Read more than one file `.las` and extrapolate the LAR model and the color of each point.
"""
# function las2pointcloud(fnames::String...)::PointCloud
# 	Vtot = Array{Float64,2}(undef, 3, 0)
# 	rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
# 	for fname in fnames
# 		V = las2larpoints(fname)
# 		rgb = las2color(fname)
# 		Vtot = hcat(Vtot,V)
# 		rgbtot = hcat(rgbtot,rgb)
# 	end
# 	return PointCloud(Vtot,rgbtot)
# end


function las2pointcloud(fnames::String...)::PointCloud
    Vtot = Array{Float64,2}(undef, 3, 0)
    rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)

    for fname in fnames
        header, laspoints = read_LAS_LAZ(fname)
        npoints = length(laspoints)

        # COORDS
        x = [LasIO.xcoord(laspoints[k], header) for k = 1:npoints]
        y = [LasIO.ycoord(laspoints[k], header) for k = 1:npoints]
        z = [LasIO.zcoord(laspoints[k], header) for k = 1:npoints]
        V = vcat(x', y', z')

        # RGB
        type = LasIO.pointformat(header)
        rgb = Array{LasIO.N0f16,2}(undef, 3, 0)
        if type != LasPoint0 && type != LasPoint1
            r = LasIO.ColorTypes.red.(laspoints)
            g = LasIO.ColorTypes.green.(laspoints)
            b = LasIO.ColorTypes.blue.(laspoints)
            rgb = vcat(r', g', b')
        end

        Vtot = hcat(Vtot, V)
        rgbtot = hcat(rgbtot, rgb)
    end

    return PointCloud(Vtot, rgbtot)
end


"""
	las2larpoints(file::String) -> Points

Return coordinates of points in LAS file.
"""
function las2larpoints(file::String)::Points
    header, laspoints = read_LAS_LAZ(file)
    npoints = length(laspoints)
    x = [LasIO.xcoord(laspoints[k], header) for k = 1:npoints]
    y = [LasIO.ycoord(laspoints[k], header) for k = 1:npoints]
    z = [LasIO.zcoord(laspoints[k], header) for k = 1:npoints]
    return vcat(x', y', z')
end

"""
	las2aabb(file::String) -> AABB

Return LAS file's bounding box.
"""
function las2aabb(file::String)::AABB
    header = nothing
    open(file, "r") do s
        LasIO.skiplasf(s)
        header = read(s, LasHeader)
    end
    #header = LasIO.read(fname, LasIO.LasHeader)
    aabb = LasIO.boundingbox(header)
    return AABB(
        aabb.xmax,
        aabb.xmin,
        aabb.ymax,
        aabb.ymin,
        aabb.zmax,
        aabb.zmin,
    )
end

function las2aabb(header::LasHeader)::AABB
    aabb = LasIO.boundingbox(header)
    return AABB(
        aabb.xmax,
        aabb.xmin,
        aabb.ymax,
        aabb.ymin,
        aabb.zmax,
        aabb.zmin,
    )
end


"""
	las2color(file::String)::Points

Return color, rgb, associated to each point in LAS file.
"""
function las2color(file::String)::Points
    header, laspoints = read_LAS_LAZ(file)
    npoints = length(laspoints)
    type = LasIO.pointformat(header)
    if type != LasPoint0 && type != LasPoint1
        r = LasIO.ColorTypes.red.(laspoints)
        g = LasIO.ColorTypes.green.(laspoints)
        b = LasIO.ColorTypes.blue.(laspoints)
        return vcat(r', g', b')
    end
    return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end

"""
	color(p::LasPoint, header::LasHeader)

Return color of one point in LAS file.
"""
function color(p::LasPoint, header::LasHeader)
    type = LasIO.pointformat(header)
    if type != LasPoint0 && type != LasPoint1
        r = LasIO.ColorTypes.red(p)
        g = LasIO.ColorTypes.green(p)
        b = LasIO.ColorTypes.blue(p)
        return vcat(r', g', b')
    end
    return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end

"""
	 xyz(p::LasPoint, h::LasHeader)

Return coords of this point `p`.
"""
function xyz(p::LasPoint, h::LasHeader)
    return [LasIO.xcoord(p, h); LasIO.ycoord(p, h); LasIO.zcoord(p, h)]
end


"""
	read_LAS_LAZ(fname::String)

Read point cloud files: LAS or LAZ.
"""
function read_LAS_LAZ(fname::String)
    if endswith(fname, ".las")
        header, laspoints = LasIO.FileIO.load(fname)
    elseif endswith(fname, ".laz")
        header, laspoints = LazIO.load(fname)
    end
    return header, laspoints
end


function las2localcoords(fname::String)::PointCloud

    "X coordinate (Float64), apply scale and offset according to the header"
    xcoord(p::LasPoint, h::LasHeader) = p.x * h.x_scale
    "Y coordinate (Float64), apply scale and offset according to the header"
    ycoord(p::LasPoint, h::LasHeader) = p.y * h.y_scale
    "Z coordinate (Float64), apply scale and offset according to the header"
    zcoord(p::LasPoint, h::LasHeader) = p.z * h.z_scale


    header, laspoints = read_LAS_LAZ(fname)
    npoints = length(laspoints)
    offset = [header.x_offset, header.y_offset, header.z_offset]

    # COORDS
    x = [xcoord(laspoints[k], header) for k = 1:npoints]
    y = [ycoord(laspoints[k], header) for k = 1:npoints]
    z = [zcoord(laspoints[k], header) for k = 1:npoints]
    V = vcat(x', y', z')

    # RGB
    type = LasIO.pointformat(header)
    rgb = Array{LasIO.N0f16,2}(undef, 3, 0)
    if type != LasPoint0 && type != LasPoint1
        r = LasIO.ColorTypes.red.(laspoints)
        g = LasIO.ColorTypes.green.(laspoints)
        b = LasIO.ColorTypes.blue.(laspoints)
        rgb = vcat(r', g', b')
    end

    return PointCloud(V, rgb, offset)
end


function potree2localcoords(potree::String, LOD:: Int64)::PointCloud

    "X coordinate (Float64), apply scale and offset according to the header"
    xcoord(p::LasPoint, h::LasHeader, x_offset) = p.x * h.x_scale + x_offset
    "Y coordinate (Float64), apply scale and offset according to the header"
    ycoord(p::LasPoint, h::LasHeader, y_offset) = p.y * h.y_scale + y_offset
    "Z coordinate (Float64), apply scale and offset according to the header"
    zcoord(p::LasPoint, h::LasHeader, z_offset) = p.z * h.z_scale + z_offset

    trie = potree2trie(potree)

    # reference to r
    r_file = trie.value
    header = nothing
    open(r_file, "r") do s
        LasIO.skiplasf(s)
        header = read(s, LasHeader)
    end
    offset_r = [header.x_offset, header.y_offset, header.z_offset]

    if LOD!=-1
        cut_trie!(trie, LOD)
    end
    
    Vtot = Array{Float32,2}(undef, 3, 0)
    rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)

    all_files = FileManager.get_all_values(trie)
    for file in all_files

        header, laspoints = read_LAS_LAZ(file)
        npoints = length(laspoints)
        offset = [header.x_offset,header.y_offset,header.z_offset] - offset_r
        # COORDS
        x = [xcoord(laspoints[k], header, offset[1]) for k = 1:npoints]
        y = [ycoord(laspoints[k], header, offset[2]) for k = 1:npoints]
        z = [zcoord(laspoints[k], header, offset[3]) for k = 1:npoints]
        V = vcat(x', y', z')

        # RGB
        type = LasIO.pointformat(header)
        rgb = Array{LasIO.N0f16,2}(undef, 3, 0)
        if type != LasPoint0 && type != LasPoint1
            r = LasIO.ColorTypes.red.(laspoints)
            g = LasIO.ColorTypes.green.(laspoints)
            b = LasIO.ColorTypes.blue.(laspoints)
            rgb = vcat(r', g', b')
        end

        Vtot = hcat(Vtot, V)
        rgbtot = hcat(rgbtot, rgb)
    end

    return PointCloud(convert(Matrix{Float32},Vtot), rgbtot, offset_r)
end
