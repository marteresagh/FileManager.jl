using FileManager

file = raw"C:\Users\marte\Documents\GEOWEB\TEST\REGISTRATION\TEST_casaletto.las"

aabb = FileManager.las2aabb(file)

using BenchmarkTools
@btime V = FileManager.las2pointcloud(file) #2.681 ms
