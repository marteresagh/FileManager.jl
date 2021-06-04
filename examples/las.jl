using BenchmarkTools
using FileManager
using PyCall

function las2larpoints(file::String)
	# default: 3cm distance threshold
	py"""
	import pylas
	import numpy as np

	def ReadLas(file):
		las = pylas.read(file)
		return las

	"""

	las = py"ReadLas"(file)
	x = las.x
	y = las.y
	z = las.z
	return vcat(x',y',z')
end

file = raw"C:\Users\marte\Documents\GEOWEB\TEST\REGISTRATION\TEST_casaletto.las"

@btime aabb = FileManager.las2aabb(file) #66.400 μs

@btime P = load(file) #1.375 s
@btime P = readlas(file) #17.592 ms

P = load(file) #1.375 s
L = readlas(file) #17.592 ms

@btime V = FileManager.las2larpoints(file) #1.364 s
@btime V = las2larpoints(file) #68.525 ms


@btime V = FileManager.las2color(file) #1.406 s
@btime V = las2color(file) #31.809 ms


@btime V = FileManager.las2pointcloud(file) #2.681 s
@btime V = las2pointcloud(file) #119.670 ms
