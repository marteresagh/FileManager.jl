const HEADER_SIZE = 227
const DATA_OFFSET = 227
const SIZE_DATARECORD = 26


# """
# save file .las
# """
# function save_new_las(filename::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})
#     if ispath(filename) #overwrite
#         rm(filename)
#     end
#     LasIO.FileIO.save(filename,h,p)
# end


"""
create a header
"""
function newHeader(aabb::AABB, software::String, sizePointRecord, npoints=0; scale=0.001)

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
	x_scale=scale
	y_scale=scale
	z_scale=scale
	x_offset = aabb.x_min
	y_offset = aabb.y_min
	z_offset = aabb.z_min
	x_max = aabb.x_max
	x_min = aabb.x_min
	y_max = aabb.y_max
	y_min = aabb.y_min
	z_max = aabb.z_max
	z_min = aabb.z_min
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

"""
create a new point record for las file.
"""
function newPointRecord(laspoint::LasIO.LasPoint, header::LasIO.LasHeader, type::DataType, mainHeader::LasIO.LasHeader; affineMatrix = Matrix{Float64}(Common.I,4,4))

	point = Common.apply_matrix(affineMatrix,[LasIO.xcoord(laspoint,header), LasIO.ycoord(laspoint,header), LasIO.zcoord(laspoint,header)])
	x = LasIO.xcoord(point[1],mainHeader)
	y = LasIO.ycoord(point[2],mainHeader)
	z = LasIO.zcoord(point[3],mainHeader)
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


function newPointRecord(point::Point, rgb::Array{LasIO.N0f16,1} , type::LasIO.DataType, mainHeader::LasIO.LasHeader) #crea oggetto laspoint con vertici e colori

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

"""
Save a point cloud in las format
"""
function save_pointcloud(filename::String, pc::PointCloud,  software::String)

	if pc.dimension == 2
		points = vcat(pc.coordinates,zeros(pc.n_points)')
	else
		points = pc.coordinates # .+pc.offset
	end

	rgbs = pc.rgbs
	npoints = pc.n_points

	aabb = AABB(points)
	header = newHeader(aabb,software,SIZE_DATARECORD,npoints)

	pvec = Array{LasPoint,1}(undef,npoints)
	for i in 1:npoints
		point = newPointRecord(points[:,i], rgbs[:,i], LasIO.LasPoint2, header)
		pvec[i] = point
	end

	LasIO.FileIO.save(filename,header,pvec)
end

#
# """
#  	createlasdata(p,h,header)
#
# create LasPoint from coordinates.
# """
# function createlasdata(p,h::LasIO.LasHeader,mainHeader::LasIO.LasHeader)
# 	type = pointformat(h)
#
# 	x = LasIO.xcoord(xcoord(p,h),mainHeader)
# 	y = LasIO.ycoord(ycoord(p,h),mainHeader)
# 	z = LasIO.zcoord(zcoord(p,h),mainHeader)
# 	intensity = p.intensity
# 	flag_byte = p.flag_byte
# 	raw_classification = p.raw_classification
# 	scan_angle = p.scan_angle
# 	user_data = p.user_data
# 	pt_src_id = p.pt_src_id
#
# 	if type == LasIO.LasPoint0
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id
# 					)
#
# 	elseif type == LasIO.LasPoint1
# 		gps_time = p.gps_time
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id, gps_time
# 					)
#
# 	elseif type == LasIO.LasPoint2
# 		red = p.red
# 		green = p.green
# 		blue = p.blue
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id,
# 					red, green, blue
# 					)
#
# 	elseif type == LasIO.LasPoint3
# 		gps_time = p.gps_time
# 		red = p.red
# 		green = p.green
# 		blue = p.blue
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id, gps_time,
# 					red, green, blue
# 					)
#
# 	end
# end

# """
# 	bbincremental!(coordpoint,bb)
#
# """
# function bbincremental!(coordpoint,bb)
#
# 	for i in 1:length(coordpoint)
# 		if coordpoint[i] < bb[1][i]
# 			bb[1][i] = coordpoint[i]
# 		end
# 		if coordpoint[i] > bb[2][i]
# 			bb[2][i] = coordpoint[i]
# 		end
# 	end
#
# 	return true
# end

# """
# .
# """
#
# function set_z_zero(points::Array{LasPoint2,1},header::LasIO.LasHeader)
# 	type = pointformat(header)
# 	pvec = Vector{LasPoint}()
# 	for p in points
# 		x = p.x
# 		y = p.y
# 		z = 0
# 		intensity = p.intensity
# 		flag_byte = p.flag_byte
# 		raw_classification = p.raw_classification
# 		scan_angle = p.scan_angle
# 		user_data = p.user_data
# 		pt_src_id = p.pt_src_id
#
# 		if type == LasIO.LasPoint0
# 			laspoint = type(x, y, z,
# 						intensity, flag_byte, raw_classification,
# 						scan_angle, user_data, pt_src_id
# 						)
#
# 		elseif type == LasIO.LasPoint1
# 			gps_time = p.gps_time
# 			laspoint = type(x, y, z,
# 						intensity, flag_byte, raw_classification,
# 						scan_angle, user_data, pt_src_id, gps_time
# 						)
#
# 		elseif type == LasIO.LasPoint2
# 			red = p.red
# 			green = p.green
# 			blue = p.blue
# 			laspoint = type(x, y, z,
# 						intensity, flag_byte, raw_classification,
# 						scan_angle, user_data, pt_src_id,
# 						red, green, blue
# 						)
#
# 		elseif type == LasIO.LasPoint3
# 			gps_time = p.gps_time
# 			red = p.red
# 			green = p.green
# 			blue = p.blue
# 			laspoint = type(x, y, z,
# 						intensity, flag_byte, raw_classification,
# 						scan_angle, user_data, pt_src_id, gps_time,
# 						red, green, blue
# 						)
#
# 		end
# 		push!(pvec,laspoint)
# 	end
# 	return pvec
# end

# """
# 	mergelas(headers,pointdata,bb,scale)
#
# Merge more file .las.
# """
# function mergelas(headers,pointdata)
# 	@assert length(headers) == length(pointdata) "mergelas: inconsistent data"
#
# 	# header of merging las
# 	hmerge = createheader(headers,pointdata)
# 	data = LasIO.LasPoint[]
#
# 	# Las point data merge
# 	for i in 1:length(pointdata)
# 		for p in pointdata[i]
# 			laspoint = createlasdata(p,headers[i],hmerge)
# 			push!(data,laspoint)
# 		end
# 	end
#
# 	return hmerge,data
# end

# """
#  	createheader(headers,pointdata,bb,scale)
#
# crea header coerente con i miei punti.
# """
# function createheader(headers,pointdata)
# 	type = pointformat(headers[1])
# 	h = deepcopy(headers[1])
# 	h.records_count = sum(length.(pointdata))
# 	return h
# end
