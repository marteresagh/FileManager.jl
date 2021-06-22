using FileManager
using Visualization
file = raw"C:\Users\marte\Documents\GEOWEB\TEST\REGISTRATION\TEST_casaletto.las"

aabb = FileManager.las2aabb(file)

using BenchmarkTools
PC = FileManager.las2pointcloud(file) #2.681 ms

Visualization.VIEW(
    [
    Visualization.points(PC.coordinates, PC.rgbs)
    ]
)
