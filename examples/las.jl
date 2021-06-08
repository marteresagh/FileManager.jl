using BenchmarkTools
using FileManager
using PyCall
using Common
function readlas(file::String)
	# default: 3cm distance threshold
	py"""
	import pylas
	import numpy as np

	def ReadLas(file):
		las = pylas.read(file)
		return las

	"""

	las = py"ReadLas"(file)
	return las
end

file = raw"C:\Users\marte\Documents\GEOWEB\TEST\REGISTRATION\TEST_casaletto.las"
file = raw"D:\pointclouds\geo-fly_cava.laz"
las = readlas(file)

@btime PC = FileManager.las2pointcloud(file) #119.670 ms
@btime FileManager.las2aabb(file) # 75.300 μs


function newHeader(aabb::AABB; software = "potree-julia"::String, id_format = 2, npoints=0, scale=0.001)

	py"""
	import pylas

	def createHeader(x_max,x_min,y_max,y_min,z_max,z_min,npoints,software,id_format,scale):
		return pylas.LasHeader(version=Version(1, 2),
						generating_software = software,
		 				point_format=PointFormat(id_format),
						point_count = npoints,
						x_scale = scale,
						y_scale = scale,
						z_scale = scale,
						x_offset = x_min,
						y_offset = y_min,
						z_offset = z_min,
						x_min = x_min,
						y_min = y_min,
						z_min = z_min,
						x_max = x_max,
						y_max = y_max,
						z_max = z_max)
	"""
	x_max = aabb.x_max
	x_min = aabb.x_min
	y_max = aabb.y_max
	y_min = aabb.y_min
	z_max = aabb.z_max
	z_min = aabb.z_min
	return py"createHeader"(x_max,x_min,y_max,y_min,z_max,z_min,npoints,software,id_format,scale)
end

newHeader(AABB(1,0,1,0,1,0))
