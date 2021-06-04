using FileManager
using Visualization

potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/CUPOLA"
cloudMets = FileManager.CloudMetadata(potree)
trie = FileManager.potree2trie(potree)
max_level = FileManager.max_depth(trie)
files = FileManager.get_files_in_potree_folder(potree,2, true)
@time PC = FileManager.las2pointcloud(files...)

Visualization.VIEW(
    [
    Visualization.points(PC.coordinates, PC.rgbs)
    ]
)
