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
P = readlas(file)
PC = FileManager.las2pointcloud(file) #119.670 ms
