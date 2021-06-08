using BenchmarkTools
using FileManager
using PyCall

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
las = readlas(file)
@btime PC = FileManager.las2pointcloud(file) #119.670 ms

function las2aabb(file::String)::AABB
	py"""
	import pylas

	def ReadHeader(file)
		with fs.open(file, 'rb') as f:
	     print(f.header.x_max)
	"""

	py"ReadHeader"(file)
	
	return AABB(aabb.xmax, aabb.xmin, aabb.ymax, aabb.ymin, aabb.zmax, aabb.zmin)
end
