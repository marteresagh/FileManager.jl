const HEADER_SIZE = 227
const DATA_OFFSET = 227
const SIZE_DATARECORD = 26

"""
	loadlas(fname::String...)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read more than one file `.las` and extrapolate the LAR model and the color of each point.

"""
function loadlas(fname::String...)::Tuple{Lar.Points,Array{Array{Int64,1},1},Array{LasIO.N0f16,2}}
	Vtot = Array{Float64,2}(undef, 3, 0)
	rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
	for name in fname
		V,VV = PointClouds.las2lar(name)
		rgb = PointClouds.lascolor(name)
		Vtot = hcat(Vtot,V)
		rgbtot = hcat(rgbtot,rgb)
	end
	return Vtot,[[i] for i in 1:size(Vtot,2)],rgbtot
end

"""
	las2lar(fname::String)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read data from a file `.las`:
- generate the LAR model `(V,VV)`
- extrapolate color associated to each point
"""
function las2lar(fname::String)::Tuple{Lar.Points,Array{Array{Int64,1},1}}
	header, laspoints =  PointClouds.readpotreefile(fname)
	npoints = length(laspoints)
	x = [LasIO.xcoord(laspoints[k], header) for k in 1:npoints]
	y = [LasIO.ycoord(laspoints[k], header) for k in 1:npoints]
	z = [LasIO.zcoord(laspoints[k], header) for k in 1:npoints]
	return vcat(x',y',z'), [[i] for i in 1:npoints]
end

"""
	las2aabb(fname::String)

Return the AABB of the file `fname`.

"""
function las2aabb(fname::String)
	header, p =  PointClouds.readpotreefile(fname)
	#header = read(fname, LasIO.LasHeader)
	AABB = LasIO.boundingbox(header)
	return reshape([AABB.xmin;AABB.ymin;AABB.zmin],(3,1)),reshape([AABB.xmax;AABB.ymax;AABB.zmax],(3,1))
end

function las2aabb(header::LasHeader)
	AABB = LasIO.boundingbox(header)
	return (hcat([AABB.xmin;AABB.ymin;AABB.zmin]),hcat([AABB.xmax;AABB.ymax;AABB.zmax]))
end


"""
	lascolor(fname::String)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read data from a file `.las`:
- extrapolate color associated to each point.
"""
function lascolor(fname::String)::Array{LasIO.N0f16,2}
	header, laspoints =  PointClouds.readpotreefile(fname)
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
	savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})

save file .las in writefile.
"""
function savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})
    if ispath(writefile) #overwrite
        rm(writefile)
    end
    LasIO.FileIO.save(writefile,h,p)
end

"""
	mergelas(headers,pointdata,bb,scale)

Merge more file .las.
"""
function mergelas(headers,pointdata)
	@assert length(headers) == length(pointdata) "mergelas: inconsistent data"

	# header of merging las
	hmerge = createheader(headers,pointdata)
	data = LasIO.LasPoint[]

	# Las point data merge
	for i in 1:length(pointdata)
		for p in pointdata[i]
			laspoint = createlasdata(p,headers[i],hmerge)
			push!(data,laspoint)
		end
	end

	return hmerge,data
end

"""
 	createheader(headers,pointdata,bb,scale)

crea header coerente con i miei punti.
"""
function createheader(headers,pointdata)
	type = pointformat(headers[1])
	h = deepcopy(headers[1])
	h.records_count = sum(length.(pointdata))
	return h
end

"""
 	createlasdata(p,h,header)

Generate laspoint coerenti con il mio header (soprattutto per quanto riguarda la traslazione).
"""
function createlasdata(p,h::LasIO.LasHeader,mainHeader::LasIO.LasHeader)
	type = pointformat(h)

	x = LasIO.xcoord(xcoord(p,h),mainHeader)
	y = LasIO.ycoord(ycoord(p,h),mainHeader)
	z = LasIO.zcoord(zcoord(p,h),mainHeader)
	intensity = p.intensity
	flag_byte = p.flag_byte
	raw_classification = p.raw_classification
	scan_angle = p.scan_angle
	user_data = p.user_data
	pt_src_id = p.pt_src_id

	if type == LasIO.LasPoint0
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id
					)

	elseif type == LasIO.LasPoint1
		gps_time = p.gps_time
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time
					)

	elseif type == LasIO.LasPoint2
		red = p.red
		green = p.green
		blue = p.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id,
					red, green, blue
					)

	elseif type == LasIO.LasPoint3
		gps_time = p.gps_time
		red = p.red
		green = p.green
		blue = p.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time,
					red, green, blue
					)

	end
end

"""
	bbincremental!(coordpoint,bb)

"""
function bbincremental!(coordpoint,bb)

	for i in 1:length(coordpoint)
		if coordpoint[i] < bb[1][i]
			bb[1][i] = coordpoint[i]
		end
		if coordpoint[i] > bb[2][i]
			bb[2][i] = coordpoint[i]
		end
	end

	return true
end

"""
Read Potree file: LAS or LAZ.
"""
function readpotreefile(fname::String)
	if endswith(fname,".las")
		header, laspoints = LasIO.FileIO.load(fname)
	elseif endswith(fname,".laz")
		header, laspoints = LazIO.load(fname)
	end
	return header,laspoints
end


"""
.
"""

function set_z_zero(points::Array{LasPoint2,1},header::LasIO.LasHeader)
	type = pointformat(header)
	pvec = Vector{LasPoint}()
	for p in points
		x = p.x
		y = p.y
		z = 0
		intensity = p.intensity
		flag_byte = p.flag_byte
		raw_classification = p.raw_classification
		scan_angle = p.scan_angle
		user_data = p.user_data
		pt_src_id = p.pt_src_id

		if type == LasIO.LasPoint0
			laspoint = type(x, y, z,
						intensity, flag_byte, raw_classification,
						scan_angle, user_data, pt_src_id
						)

		elseif type == LasIO.LasPoint1
			gps_time = p.gps_time
			laspoint = type(x, y, z,
						intensity, flag_byte, raw_classification,
						scan_angle, user_data, pt_src_id, gps_time
						)

		elseif type == LasIO.LasPoint2
			red = p.red
			green = p.green
			blue = p.blue
			laspoint = type(x, y, z,
						intensity, flag_byte, raw_classification,
						scan_angle, user_data, pt_src_id,
						red, green, blue
						)

		elseif type == LasIO.LasPoint3
			gps_time = p.gps_time
			red = p.red
			green = p.green
			blue = p.blue
			laspoint = type(x, y, z,
						intensity, flag_byte, raw_classification,
						scan_angle, user_data, pt_src_id, gps_time,
						red, green, blue
						)

		end
		push!(pvec,laspoint)
	end
	return pvec
end



function newHeader(aabb,software,sizePointRecord,npoints=0)

	file_source_id=UInt16(0)
	global_encoding=UInt16(0)
	guid_1=UInt32(0)
	guid_2=UInt16(0)
	guid_3=UInt16(0)
	guid_4=""
	version_major=UInt8(1)
	version_minor=UInt8(2)
	system_id=""
	software_id = software
	creation_dayofyear = UInt16(Dates.dayofyear(today()))
	creation_year = UInt16(Dates.year(today()))
	header_size=UInt16(HEADER_SIZE) # valore fisso
	data_offset=UInt16(DATA_OFFSET) #valore fisso
	n_vlr=UInt32(0)
	data_format_id=UInt8(2)
	data_record_length=UInt16(sizePointRecord) #valore variabile
	records_count=UInt32(npoints)
	point_return_count=UInt32[0,0,0,0,0]
	x_scale=0.001
	y_scale=0.001
	z_scale=0.001
	x_offset=aabb[1][1]
	y_offset=aabb[1][2]
	z_offset=aabb[1][3]
	x_max=aabb[2][1]
	x_min=aabb[1][1]
	y_max=aabb[2][2]
	y_min=aabb[1][2]
	z_max=aabb[2][3]
	z_min=aabb[1][3]
	variable_length_records=Vector{LasVariableLengthRecord}()
	user_defined_bytes=Vector{UInt8}()


	return LasIO.LasHeader(file_source_id,
    global_encoding,
    guid_1,
    guid_2,
    guid_3,
    guid_4,
    version_major,
    version_minor,
    system_id,
    software_id,
    creation_dayofyear,
    creation_year,
    header_size,
    data_offset,
    n_vlr,
    data_format_id,
    data_record_length,
    records_count,
    point_return_count,
    x_scale,
    y_scale,
    z_scale,
    x_offset,
    y_offset,
    z_offset,
    x_max,
    x_min,
    y_max,
    y_min,
    z_max,
    z_min,
    variable_length_records,
    user_defined_bytes
	)
end


function newPointRecord(laspoint::LasIO.LasPoint, header::LasIO.LasHeader, type::DataType, mainHeader::LasIO.LasHeader)

	x = LasIO.xcoord(xcoord(laspoint,header),mainHeader)
	y = LasIO.ycoord(ycoord(laspoint,header),mainHeader)
	z = LasIO.zcoord(zcoord(laspoint,header),mainHeader)
	intensity = laspoint.intensity
	flag_byte = laspoint.flag_byte
	raw_classification = laspoint.raw_classification
	scan_angle = laspoint.scan_angle
	user_data = laspoint.user_data
	pt_src_id = laspoint.pt_src_id

	if type == LasIO.LasPoint0
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id
					)

	elseif type == LasIO.LasPoint1
		gps_time = laspoint.gps_time
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time
					)

	elseif type == LasIO.LasPoint2
		red = laspoint.red
		green = laspoint.green
		blue = laspoint.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id,
					red, green, blue
					)

	elseif type == LasIO.LasPoint3
		gps_time = laspoint.gps_time
		red = laspoint.red
		green = laspoint.green
		blue = laspoint.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time,
					red, green, blue
					)

	end

end



function newPointRecord(point::Array{Float64,1}, rgb::Array{N0f16,1} , type::DataType, mainHeader::LasIO.LasHeader) #crea oggetto pointcloud con vertici e colori

	x = LasIO.xcoord(point[1],mainHeader)
	y = LasIO.ycoord(point[2],mainHeader)
	z = LasIO.zcoord(point[3],mainHeader)
	intensity = UInt16(0)
	flag_byte = UInt8(0)
	raw_classification = UInt8(0)
	scan_angle = Int8(0)
	user_data = UInt8(0)
	pt_src_id = UInt16(0)

	if type == LasIO.LasPoint0
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id
					)

	elseif type == LasIO.LasPoint1
		gps_time = Float64(0)
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time
					)

	elseif type == LasIO.LasPoint2
		red = rgb[1]
		green = rgb[2]
		blue = rgb[3]
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id,
					red, green, blue
					)

	elseif type == LasIO.LasPoint3
		gps_time = Float64(0)
		red = rgb[1]
		green = rgb[2]
		blue = rgb[3]
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time,
					red, green, blue
					)

	end

end
