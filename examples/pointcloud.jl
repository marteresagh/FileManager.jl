using FileManager
using Visualization
using Common

## descrizione degli octree relativi ai file che gli passo
function view_octree(files, affineMatrix)
    mesh = []
    for file in files
        octree = FileManager.las2aabb(file)
        V,EV,FV = Common.getmodel(octree)
        PC = FileManager.las2pointcloud(file)
        push!(mesh,Visualization.points(Common.apply_matrix(affineMatrix,PC.coordinates), PC.rgbs))
        push!(mesh,Visualization.GLGrid(Common.apply_matrix(affineMatrix,V),EV,Visualization.COLORS[7]))
    end
    return mesh
end

potree = raw"D:\potreeDirectory\pointclouds\CUPOLA"
cloudMets = FileManager.CloudMetadata(potree)

vector_t = [cloudMets.boundingBox.x_min,cloudMets.boundingBox.y_min,cloudMets.boundingBox.z_min]

trie = FileManager.potree2trie(potree)
max_level = FileManager.max_depth(trie)
files = FileManager.get_files_in_potree_folder(potree, 5, false)
leaves = FileManager.get_leaf(trie)
# PC = FileManager.las2pointcloud(files...)
affineMatrix = Common.t(-vector_t...)

mesh = view_octree(leaves,affineMatrix)
# V,EV,FV = Common.getmodel(cloudMets.boundingBox)
# push!(mesh,Visualization.GLGrid(Common.apply_matrix(affineMatrix,V),EV,Visualization.COLORS[3]))

Visualization.VIEW(mesh)
