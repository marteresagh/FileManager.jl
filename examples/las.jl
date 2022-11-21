using Common
using FileManager
using Visualization
file = raw"D:\pointclouds\terreni\cava.laz"

aabb = FileManager.las2aabb(file)
PC = FileManager.las2localcoords(file) #2.681 ms
aabb.x_max -= PC.offset[1]
aabb.y_max -= PC.offset[2]
aabb.z_max -= PC.offset[3]

aabb.x_min -= PC.offset[1]
aabb.y_min -= PC.offset[2]
aabb.z_min -= PC.offset[3]

V,EV, FV = Common.getmodel(aabb)
Visualization.VIEW(
    [
    Visualization.GLGrid(V, EV)
    Visualization.points(PC.coordinates, PC.rgbs)
    ]
)
