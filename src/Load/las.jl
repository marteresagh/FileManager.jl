"""
las2pointcloud(fnames::String...) -> PointCloud

Read more than one file `.las` and extrapolate the LAR model and the color of each point.
"""
function las2pointcloud(fnames::String...)::PointCloud
	Vtot = Array{Float64,2}(undef, 3, 0)
	rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
	for fname in fnames
		V = las2larpoints(fname)
		rgb = las2color(fname)
		Vtot = hcat(Vtot,V)
		rgbtot = hcat(rgbtot,rgb)
	end
	return PointCloud(Vtot,rgbtot)
end

"""
Return coordinates of points in file.
"""
function las2larpoints(file::String)::Lar.Points
	header, laspoints = read_LAS_LAZ(file)
	npoints = length(laspoints)
	x = [LasIO.xcoord(laspoints[k], header) for k in 1:npoints]
	y = [LasIO.ycoord(laspoints[k], header) for k in 1:npoints]
	z = [LasIO.zcoord(laspoints[k], header) for k in 1:npoints]
	return vcat(x',y',z')
end

"""
Return the AABB of the file.
"""
function las2aabb(file::String)::AABB
	header, p = read_LAS_LAZ(file)
	#header = LasIO.read(fname, LasIO.LasHeader)
	aabb = LasIO.boundingbox(header)
	return AABB(aabb.xmax, aabb.xmin, aabb.ymax, aabb.ymin, aabb.zmax, aabb.zmin)
end

function las2aabb(header::LasHeader)::AABB
	aabb = LasIO.boundingbox(header)
	return AABB(aabb.xmax, aabb.xmin, aabb.ymax, aabb.ymin, aabb.zmax, aabb.zmin)
end


"""
Return color associated to each point in file.
"""
function las2color(file::String)::Lar.Points
	header, laspoints =  read_LAS_LAZ(file)
	npoints = length(laspoints)
	type = LasIO.pointformat(header)
	if type != LasPoint0 && type != LasPoint1
		r = LasIO.ColorTypes.red.(laspoints)
		g = LasIO.ColorTypes.green.(laspoints)
		b = LasIO.ColorTypes.blue.(laspoints)
		return vcat(r',g',b')
	end
	return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end

function color(p::LasPoint, header::LasHeader)
	type = LasIO.pointformat(header)
	if type != LasPoint0 && type != LasPoint1
		r = LasIO.ColorTypes.red(p)
		g = LasIO.ColorTypes.green(p)
		b = LasIO.ColorTypes.blue(p)
		return vcat(r',g',b')
	end
	return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end

"""
	 xyz(p::LasPoint, h::LasHeader)

Return coords of this laspoint p.
"""
function xyz(p::LasPoint, h::LasHeader)
	return [LasIO.xcoord(p, h); LasIO.ycoord(p, h); LasIO.zcoord(p, h)]
end


"""
Read point cloud files.
"""
function read_LAS_LAZ(fname::String)
	if endswith(fname,".las")
		header, laspoints = LasIO.FileIO.load(fname)
	elseif endswith(fname,".laz")
		header, laspoints = LazIO.load(fname)
	end
	return header,laspoints
end
