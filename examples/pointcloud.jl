using FileManager
using Visualization

potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/CUPOLA"
trie = FileManager.potree2trie(potree)
max_level = FileManager.max_depth(trie)
files = FileManager.get_files_in_potree_folder(potree,2, true)
PC = FileManager.las2pointcloud(files...)

GL.VIEW(
    [
    Visualization.points_color_from_rgb(PC.coordinates,PC.rgbs)
    ]
)
