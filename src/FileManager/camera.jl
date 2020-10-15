function viewcoordinatesystem(camera)
    position,target = camera
	up = [0,0,1.]
	dir = target-position
	x = -dir/Lar.norm(dir)
	if x != [0,0,1] && x != [0,0,-1]
		y = Lar.cross(x,up)
		z = Lar.cross(y,x)
	end
    return [y';z';x']
end


function coordsystemcamera(file::String)
    mat = PointClouds.cameramatrix(file)
    return Matrix(mat[1:3,1:3]')
end
